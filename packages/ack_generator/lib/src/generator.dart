import 'package:ack_annotations/ack_annotations.dart';
import 'package:analyzer/dart/element/element2.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:source_gen/source_gen.dart';

import 'analyzer/schema_ast_analyzer.dart';
import 'builders/class_builder.dart';
import 'models/model_info.dart';

/// Generates immutable model classes for top-level schemas annotated with
/// `@AckType`.
final class AckSchemaGenerator extends Generator {
  @override
  String generate(LibraryReader library, BuildStep buildStep) {
    final annotatedVariables = <TopLevelVariableElement2>[];
    final annotatedGetters = <GetterElement>[];

    for (final element in library.allElements) {
      if (element is ClassElement2 && _hasAckTypeAnnotation(element)) {
        throw InvalidGenerationSource(
          '@AckType can only be applied to top-level schema variables or getters, not classes.',
          element: element,
          todo:
              'Remove @AckType from the class and annotate a top-level schema variable or getter instead.',
        );
      }

      if (element is TopLevelVariableElement2 &&
          _hasAckTypeAnnotation(element)) {
        annotatedVariables.add(element);
      } else if (element is GetterElement && _hasAckTypeAnnotation(element)) {
        final isTopLevel = element.enclosingElement2 is LibraryElement2;
        if (!isTopLevel) {
          throw InvalidGenerationSource(
            '@AckType can only be applied to top-level schema variables or getters.',
            element: element,
            todo:
                'Move this getter to the library level or annotate a top-level schema variable instead.',
          );
        }

        if (!element.isSynthetic) {
          annotatedGetters.add(element);
        }
      }
    }

    for (final classElement in library.classes) {
      for (final getter in classElement.getters) {
        if (_hasAckTypeAnnotation(getter)) {
          throw InvalidGenerationSource(
            '@AckType can only be applied to top-level schema variables or getters.',
            element: getter,
            todo:
                'Move this getter to the library level or annotate a top-level schema variable instead.',
          );
        }
      }
    }

    if (annotatedVariables.isEmpty && annotatedGetters.isEmpty) {
      return '';
    }

    final analyzer = SchemaAstAnalyzer();
    final models = <ModelInfo>[];

    for (final variable in annotatedVariables) {
      try {
        final model = analyzer.analyzeSchemaVariable(
          variable,
          customTypeName: _extractAckTypeName(variable),
        );
        if (model != null) models.add(model);
      } catch (error) {
        throw InvalidGenerationSource(
          'Failed to analyze schema variable "${variable.name3}": $error',
          element: variable,
          todo:
              'Ensure the variable uses statically analyzable Ack schema syntax.',
        );
      }
    }

    for (final getter in annotatedGetters) {
      try {
        final model = analyzer.analyzeSchemaGetter(
          getter,
          customTypeName: _extractAckTypeName(getter),
        );
        if (model != null) models.add(model);
      } catch (error) {
        throw InvalidGenerationSource(
          'Failed to analyze schema getter "${getter.name3}": $error',
          element: getter,
          todo:
              'Ensure the getter returns a statically analyzable Ack schema.',
        );
      }
    }

    final linkedModels = _linkDiscriminatedModels(models);
    _validateGeneratedClassNames(library, linkedModels);

    final classBuilder = AckClassBuilder()
      ..setAckImportPrefix(_resolveAckImportPrefix(library));

    final List<Spec> classes;
    try {
      classes = classBuilder.buildClasses(linkedModels);
    } catch (error) {
      final element = linkedModels.isEmpty
          ? null
          : _findAnnotatedSchemaElement(
              linkedModels.first.schemaClassName,
              annotatedVariables,
              annotatedGetters,
            );
      throw InvalidGenerationSource(
        'Ack model class generation failed: $error',
        element: element,
        todo:
            'Check generated-name collisions, nullable root schemas, and unsupported schema shapes.',
      );
    }

    if (classes.isEmpty) return '';

    // SharedPartBuilder owns the generated header, `part of` directive, and
    // target-language formatting. Generators return declarations only.
    final generatedLibrary = Library((b) => b.body.addAll(classes));
    return generatedLibrary
        .accept(
          DartEmitter(
            allocator: Allocator.none,
            orderDirectives: true,
            useNullSafetySyntax: true,
          ),
        )
        .toString();
  }

  void _validateGeneratedClassNames(
    LibraryReader library,
    List<ModelInfo> models,
  ) {
    final existingNames = {
      for (final element in library.classes)
        if (element.name3 case final name?) name,
    };

    final generatedNames = <String>{};
    for (final model in models) {
      if (!generatedNames.add(model.className)) {
        throw InvalidGenerationSource(
          'Multiple @AckType declarations generate "${model.className}".',
          todo: 'Give one declaration a unique @AckType(name: ...) value.',
        );
      }
      if (existingNames.contains(model.className)) {
        throw InvalidGenerationSource(
          'Generated class "${model.className}" conflicts with an existing class in this library.',
          todo:
              'Rename the existing class or set a unique @AckType(name: ...) value.',
        );
      }
    }
  }

  List<ModelInfo> _linkDiscriminatedModels(List<ModelInfo> models) {
    final linked = List<ModelInfo>.from(models);
    final modelIndexBySchemaClassName = <String, int>{
      for (var i = 0; i < linked.length; i++) linked[i].schemaClassName: i,
    };
    final branchOwnerByCanonicalIdentity = <String, String>{};

    for (var i = 0; i < linked.length; i++) {
      final baseModel = linked[i];
      if (!baseModel.isDiscriminatedBaseDefinition) continue;

      final discriminatorKey = baseModel.discriminatorKey;
      final subtypeNames = baseModel.subtypeNames;
      if (discriminatorKey == null || subtypeNames == null) continue;

      for (final entry in subtypeNames.entries) {
        final branchSchemaClassName = entry.value;
        final branchIndex = modelIndexBySchemaClassName[branchSchemaClassName];
        if (branchIndex == null) {
          throw InvalidGenerationSource(
            'Could not resolve discriminated branch "$branchSchemaClassName" for base "${baseModel.schemaClassName}".',
            todo:
                'Ensure every branch references an @AckType schema in the same library.',
          );
        }

        final branchModel = linked[branchIndex];
        final canonicalIdentity =
            branchModel.schemaIdentity ?? branchSchemaClassName;
        final existingOwner = branchOwnerByCanonicalIdentity[canonicalIdentity];
        if (existingOwner != null &&
            existingOwner != baseModel.schemaClassName) {
          throw InvalidGenerationSource(
            'Branch schema "$branchSchemaClassName" is mapped to multiple discriminated bases: "$existingOwner" and "${baseModel.schemaClassName}".',
            todo: 'A branch schema can belong to only one discriminated base.',
          );
        }
        branchOwnerByCanonicalIdentity[canonicalIdentity] =
            baseModel.schemaClassName;

        linked[branchIndex] = _copyModelInfo(
          branchModel,
          discriminatorKey: discriminatorKey,
          discriminatorValue: entry.key,
          discriminatedBaseClassName: baseModel.className,
        );
      }
    }

    return linked;
  }

  ModelInfo _copyModelInfo(
    ModelInfo model, {
    String? discriminatorKey,
    String? discriminatorValue,
    Map<String, String>? subtypeNames,
    String? discriminatedBaseClassName,
  }) {
    return ModelInfo(
      className: model.className,
      schemaClassName: model.schemaClassName,
      description: model.description,
      fields: model.fields,
      additionalProperties: model.additionalProperties,
      discriminatorKey: discriminatorKey ?? model.discriminatorKey,
      discriminatorValue: discriminatorValue ?? model.discriminatorValue,
      subtypeNames: subtypeNames ?? model.subtypeNames,
      schemaIdentity: model.schemaIdentity,
      discriminatedBaseClassName:
          discriminatedBaseClassName ?? model.discriminatedBaseClassName,
      representationType: model.representationType,
      isNullableSchema: model.isNullableSchema,
    );
  }

  bool _hasAckTypeAnnotation(Element2 element) {
    return TypeChecker.typeNamed(AckType).hasAnnotationOfExact(element);
  }

  String? _extractAckTypeName(Element2 element) {
    final annotation = TypeChecker.typeNamed(
      AckType,
    ).firstAnnotationOfExact(element);
    if (annotation == null) return null;

    final nameField = ConstantReader(annotation).peek('name');
    return nameField != null && !nameField.isNull
        ? nameField.stringValue
        : null;
  }

  Element2? _findAnnotatedSchemaElement(
    String schemaName,
    List<TopLevelVariableElement2> variables,
    List<GetterElement> getters,
  ) {
    for (final variable in variables) {
      if (variable.name3 == schemaName) return variable;
    }
    for (final getter in getters) {
      if (getter.name3 == schemaName) return getter;
    }
    return null;
  }

  String? _resolveAckImportPrefix(LibraryReader library) {
    for (final import in library.element.firstFragment.libraryImports2) {
      if (!_isAckImport(import)) continue;
      final prefix = import.prefix2?.element.name3;
      return prefix == null || prefix.isEmpty ? null : prefix;
    }
    return null;
  }

  bool _isAckImport(LibraryImport import) {
    final importedLibrary = import.importedLibrary2;
    if (importedLibrary?.uri.toString() == 'package:ack/ack.dart') {
      return true;
    }
    return import.uri.toString().contains('package:ack/ack.dart');
  }
}
