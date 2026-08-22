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
  static const _ackTypeChecker = TypeChecker.typeNamed(AckType);

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
      ackPrefix: _importPrefix(library, 'package:ack/ack.dart'),
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
        if (directive.uri.stringValue case final uri?) uri,
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

  String? _importPrefix(LibraryReader library, String uri) {
    for (final import in library.element.firstFragment.libraryImports) {
      if (import.importedLibrary?.uri.toString() != uri) continue;
      return import.prefix?.element.name;
    }
    return null;
  }

  /// Resolves the visible `AckType` qualifier for generated JSON markers.
  ///
  /// Uses import namespaces so barrel re-exports and `show` combinators work.
  /// Prefixed imports win over unprefixed ones, in import order.
  String? _ackTypeQualifier(LibraryReader library, Element annotatedElement) {
    String? prefixed;
    var hasUnprefixed = false;
    for (final import in library.element.firstFragment.libraryImports) {
      if (import.isSynthetic || (import.prefix?.isDeferred ?? false)) {
        continue;
      }
      final prefix = import.prefix?.element.name;
      final candidate = prefix == null
          ? import.namespace.get2('AckType')
          : import.namespace.getPrefixed2(prefix, 'AckType');
      if (candidate == null || !_ackTypeChecker.isExactly(candidate)) {
        continue;
      }
      if (prefix != null && prefix.isNotEmpty) {
        prefixed ??= prefix;
      } else {
        hasUnprefixed = true;
      }
    }
    if (prefixed != null) {
      return prefixed;
    }
    if (hasUnprefixed) {
      return null;
    }
    throw InvalidGenerationSource(
      'Generated @AckType.jsonSerializable requires a visible exact AckType '
      'import in this library.',
      element: annotatedElement,
      todo:
          'Import AckType from ack_annotations, using the same prefix as '
          '@AckType() when one is present.',
    );
  }
}
