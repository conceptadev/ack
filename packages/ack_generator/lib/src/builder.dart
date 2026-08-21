import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'generator.dart';
import 'json/ack_json_generator.dart';

/// Creates the dedicated-part builder for Ack model generation.
Builder ackGenerator(BuilderOptions options) {
  return PartBuilder([AckSchemaGenerator()], '.ack.dart', options: options);
}

/// Creates the cache-only JSON fragment builder for Ack-marked models.
///
/// [options] are ignored so consumer `json_serializable` settings cannot
/// change Ack runtime-map semantics.
Builder ackJsonSerializableBuilder(BuilderOptions options) {
  return SharedPartBuilder([
    AckJsonSerializableGenerator(),
  ], 'ack_json_serializable');
}
