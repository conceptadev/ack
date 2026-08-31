import 'package:ack_annotations/ack_annotations.dart';
import 'package:ack_annotations/ack_generator_support.dart';
import 'package:test/test.dart';

void main() {
  test('public barrel exposes AckInfer', () {
    const modern = AckInfer(name: 'User');
    expect(modern.name, 'User');
    expect(AckInfer.jsonSerializable, isA<AckGeneratedJson>());
  });

  test('support barrel exposes the marker with fixed null omission', () {
    const marker = AckGeneratedJson();
    expect(marker.config.includeIfNull, isFalse);

    final generated = AckInfer.jsonSerializable as AckGeneratedJson;
    expect(generated.config.includeIfNull, isFalse);
    expect(
      identical(AckInfer.jsonSerializable, const AckGeneratedJson()),
      isTrue,
    );
  });
}
