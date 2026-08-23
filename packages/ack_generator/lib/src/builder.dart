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
/// Phase 2 delegates structural field mapping to json_serializable so generated
/// models keep the familiar `.g.dart` / `_$XFromJson` contract and can coexist
/// with a consumer's own json_serializable usage. The cost is a second resolve
/// pass, required-nullable restore in Ack glue, passthrough strip/re-add for
/// `additionalProperties`, and value-root boxing through a synthetic `value`
/// map. A future simplification pass should not undo that split without
/// replacing those contracts.
///
/// [options] are ignored so consumer `json_serializable` settings cannot
/// change Ack runtime-map semantics.
Builder ackJsonSerializableBuilder(BuilderOptions options) {
  return SharedPartBuilder([
    AckJsonSerializableGenerator(),
  ], 'ack_json_serializable');
}
