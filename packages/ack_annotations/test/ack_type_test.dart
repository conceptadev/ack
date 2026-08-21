import 'package:ack_annotations/ack_annotations.dart';
import 'package:ack_annotations/ack_generator_support.dart';
import 'package:test/test.dart';

void main() {
  test('public barrel exposes AckType', () {
    const annotation = AckType();
    expect(annotation.name, isNull);
    expect(AckType.jsonSerializable, isA<AckGeneratedJson>());
  });

  test('support barrel exposes the marker with fixed null omission', () {
    const marker = AckGeneratedJson();
    expect(marker.config.includeIfNull, isFalse);

    final generated = AckType.jsonSerializable as AckGeneratedJson;
    expect(generated.config.includeIfNull, isFalse);
    expect(
      identical(AckType.jsonSerializable, const AckGeneratedJson()),
      isTrue,
    );
  });
}
