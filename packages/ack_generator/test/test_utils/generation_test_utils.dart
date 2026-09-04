import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:test/test.dart';

Future<void> expectGenerationFailure({
  required Builder builder,
  required Map<String, String> assets,
  required String expectedMessage,
  Map<String, Object>? expectedOutputs,
}) async {
  var sawExpectedError = false;
  await testBuilder(
    builder,
    assets,
    outputs: expectedOutputs ?? const {},
    onLog: (log) {
      if (log.level.name == 'SEVERE' && log.message.contains(expectedMessage)) {
        sawExpectedError = true;
      }
    },
  );
  expect(
    sawExpectedError,
    isTrue,
    reason: 'Expected SEVERE log containing "$expectedMessage"',
  );
}
