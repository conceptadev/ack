import 'package:ack_annotations/ack_annotations.dart';
import 'package:ack/ack.dart' show AckModelAdapter, SchemaResult;
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:source_gen/source_gen.dart';

import 'analyzer/schema_model_graph_builder.dart';
import 'builders/model_emitter.dart';

/// Generates immutable model classes for top-level schemas annotated with
/// `@AckType`.
final class AckSchemaGenerator extends Generator {
  static const _ackTypeChecker = TypeChecker.typeNamed(
    AckType,
    inPackage: 'ack_annotations',
  );
  static const _ackModelAdapterChecker = TypeChecker.typeNamed(
    AckModelAdapter,
    inPackage: 'ack',
  );
  static const _schemaResultChecker = TypeChecker.typeNamed(
    SchemaResult,
    inPackage: 'ack',
  );

  @override
  Future<String> generate(LibraryReader library, BuildStep buildStep) async {
    final annotated = <Element>[];

    for (final element in library.allElements) {
      if (!_hasAckType(element)) continue;
      if (element is ClassElement) {
        throw InvalidGenerationSource(
          '@AckType can only be applied to top-level schema variables or getters, not classes.',
          element: element,
        );
      }
      if (element is TopLevelVariableElement) {
        annotated.add(element);
      } else if (element is GetterElement && element.isOriginDeclaration) {
        if (element.enclosingElement is! LibraryElement) {
          throw InvalidGenerationSource(
            '@AckType can only be applied to top-level schema variables or getters.',
            element: element,
          );
        }
        annotated.add(element);
      }
    }

    for (final classElement in library.classes) {
      for (final getter in classElement.getters) {
        if (_hasAckType(getter)) {
          throw InvalidGenerationSource(
            '@AckType can only be applied to top-level schema variables or getters.',
            element: getter,
          );
        }
      }
    }

    if (annotated.isEmpty) return '';
    await _requirePartDirectives(buildStep, annotated.first);

    final graph = await SchemaModelGraphBuilder(library).build(annotated);
    final specs = AckModelEmitter(
      ackPrefix: _ackRuntimeQualifier(library, annotated.first),
      ackTypePrefix: _ackTypeQualifier(library, annotated.first),
    ).emit(graph);
    return Library((b) => b.body.addAll(specs))
        .accept(
          DartEmitter(
            allocator: Allocator.none,
            orderDirectives: true,
            useNullSafetySyntax: true,
          ),
        )
        .toString();
  }

  bool _hasAckType(Element element) =>
      _ackTypeChecker.hasAnnotationOfExact(element);

  Future<void> _requirePartDirectives(
    BuildStep buildStep,
    Element annotatedElement,
  ) async {
    final inputName = buildStep.inputId.pathSegments.last;
    final baseName = inputName.substring(0, inputName.length - '.dart'.length);
    final expectedAckPart = '$baseName.ack.dart';
    final expectedJsonPart = '$baseName.g.dart';
    final unit = await buildStep.resolver.compilationUnitFor(buildStep.inputId);
    final parts = {
      for (final directive in unit.directives.whereType<PartDirective>())
        if (directive.uri.stringValue case final uri?)
          Uri.parse(uri).pathSegments.last,
    };
    if (parts.contains(expectedAckPart) && parts.contains(expectedJsonPart)) {
      return;
    }
    throw InvalidGenerationSource(
      "Ack model generation requires `part '$expectedAckPart';` and "
      "`part '$expectedJsonPart';` in this library.",
      element: annotatedElement,
      todo:
          "Add `part '$expectedAckPart';` and `part '$expectedJsonPart';` "
          "next to the library's directives.",
    );
  }

  /// Resolves the qualifier that exposes Ack's generated-model support types.
  ///
  /// Looking through import namespaces supports package barrels, local barrels,
  /// prefixes, and combinators without tying generation to one exact URI.
  String? _ackRuntimeQualifier(
    LibraryReader library,
    Element annotatedElement,
  ) => _visibleQualifier(
    library,
    annotatedElement,
    requiredTypes: const {
      'AckModelAdapter': _ackModelAdapterChecker,
      'SchemaResult': _schemaResultChecker,
    },
    message:
        'Generated Ack models require visible exact AckModelAdapter and '
        'SchemaResult imports in this library.',
    todo:
        'Import package:ack/ack.dart, directly or through a barrel, and '
        'ensure AckModelAdapter and SchemaResult are exposed.',
  );

  /// Resolves the visible `AckType` qualifier for generated JSON markers.
  ///
  /// Uses import namespaces so barrel re-exports and `show` combinators work.
  /// Prefixed imports win over unprefixed ones, in import order.
  String? _ackTypeQualifier(
    LibraryReader library,
    Element annotatedElement,
  ) => _visibleQualifier(
    library,
    annotatedElement,
    requiredTypes: const {'AckType': _ackTypeChecker},
    message:
        'Generated @AckType.jsonSerializable requires a visible exact AckType '
        'import in this library.',
    todo:
        'Import AckType from ack_annotations, using the same prefix as '
        '@AckType() when one is present.',
  );

  String? _visibleQualifier(
    LibraryReader library,
    Element annotatedElement, {
    required Map<String, TypeChecker> requiredTypes,
    required String message,
    required String todo,
  }) {
    String? prefixed;
    var hasUnprefixed = false;
    for (final import in library.element.firstFragment.libraryImports) {
      if (import.isSynthetic || (import.prefix?.isDeferred ?? false)) {
        continue;
      }
      final prefix = import.prefix?.element.name;
      final exposesRequiredTypes = requiredTypes.entries.every((entry) {
        final candidate = prefix == null
            ? import.namespace.get2(entry.key)
            : import.namespace.getPrefixed2(prefix, entry.key);
        return candidate != null && entry.value.isExactly(candidate);
      });
      if (!exposesRequiredTypes) continue;
      if (prefix != null && prefix.isNotEmpty) {
        prefixed ??= prefix;
      } else {
        hasUnprefixed = true;
      }
    }
    if (prefixed != null) return prefixed;
    if (hasUnprefixed) return null;
    throw InvalidGenerationSource(
      message,
      element: annotatedElement,
      todo: todo,
    );
  }
}
