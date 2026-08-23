import 'package:ack_annotations/ack_generator_support.dart';
import 'package:build/build.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:json_serializable/json_serializable.dart';
import 'package:source_gen/source_gen.dart';

import 'ack_runtime_type_helper.dart';

/// Delegates Ack-marked model classes to json_serializable.
///
/// Consumer builder options are ignored. The class configuration comes from
/// the Ack-owned marker (`includeIfNull: false`) plus the same fixed
/// generator default.
final class AckJsonSerializableGenerator extends Generator {
  AckJsonSerializableGenerator()
    : _delegate = JsonSerializableGenerator.withDefaultHelpers(const [
        AckRuntimeTypeHelper(),
      ], config: const JsonSerializable(includeIfNull: false));

  final JsonSerializableGenerator _delegate;

  static const _marker = TypeChecker.typeNamed(
    AckGeneratedJson,
    inPackage: 'ack_annotations',
  );

  @override
  String generate(LibraryReader library, BuildStep buildStep) {
    final annotated = library.annotatedWith(_marker).toList();
    if (annotated.isEmpty) return '';

    final output = <String>[];
    for (final item in annotated) {
      output.addAll(
        _delegate.generateForAnnotatedElement(
          item.element,
          item.annotation.read('config'),
          buildStep,
        ),
      );
    }
    return output.join('\n\n');
  }
}
