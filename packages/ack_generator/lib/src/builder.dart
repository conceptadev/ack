import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'generator.dart';

/// Creates the shared-part builder for Ack model generation.
Builder ackGenerator(BuilderOptions options) {
  return SharedPartBuilder(
    [AckSchemaGenerator()],
    'ack',
  );
}
