import 'package:ack_annotations/ack_annotations.dart';
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
    await _requireAckPartDirective(buildStep, annotated.first);

    final graph = await SchemaModelGraphBuilder(library).build(annotated);
    final specs = AckModelEmitter(
      ackPrefix: _ackImportPrefix(library),
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
      TypeChecker.typeNamed(AckType).hasAnnotationOfExact(element);

  Future<void> _requireAckPartDirective(
    BuildStep buildStep,
    Element annotatedElement,
  ) async {
    final inputName = buildStep.inputId.pathSegments.last;
    final baseName = inputName.substring(0, inputName.length - '.dart'.length);
    final expectedPart = '$baseName.ack.dart';
    final unit = await buildStep.resolver.compilationUnitFor(buildStep.inputId);
    final hasExpectedPart = unit.directives.whereType<PartDirective>().any(
      (directive) => directive.uri.stringValue == expectedPart,
    );
    if (hasExpectedPart) return;
    throw InvalidGenerationSource(
      "Ack model generation requires `part '$expectedPart';` in this library.",
      element: annotatedElement,
      todo: "Add `part '$expectedPart';` next to the library's directives.",
    );
  }

  String? _ackImportPrefix(LibraryReader library) {
    for (final import in library.element.firstFragment.libraryImports) {
      if (import.importedLibrary?.uri.toString() != 'package:ack/ack.dart') {
        continue;
      }
      return import.prefix?.element.name;
    }
    return null;
  }
}
