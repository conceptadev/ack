import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'generator.dart';

/// Creates the dedicated-part builder for Ack model generation.
Builder ackGenerator(BuilderOptions options) {
  return PartBuilder([AckSchemaGenerator()], '.ack.dart', options: options);
}
