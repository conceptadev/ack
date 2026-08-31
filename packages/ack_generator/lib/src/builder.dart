import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'json/ack_json_generator.dart';
import 'model_generator.dart';

/// Creates the Ack model part that holds the generated classes and schemas.
///
/// This phase writes `.ack.dart` to source, so the JSON phase can resolve the
/// generated model classes as ordinary library members.
Builder ackModelBuilder(BuilderOptions options) {
  return PartBuilder([AckModelGenerator()], '.ack.dart', options: options);
}

/// Creates the JSON phase that runs after `.ack.dart` exists.
///
/// The output is a shared part, so `source_gen`'s combining builder merges it
/// into the ordinary `.g.dart` file next to any `json_serializable` output the
/// same library produces.
Builder ackModelJsonBuilder(BuilderOptions options) {
  // A shared part cannot take consumer options. The Ack JSON configuration is
  // fixed by the generated marker, so there is nothing for a consumer to set.
  return SharedPartBuilder([AckJsonSerializableGenerator()], 'ack_model_json');
}
