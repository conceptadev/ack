import 'dart:convert';

import 'package:flutter/painting.dart';
import 'package:flutter_codec/flutter_codec.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('README workflow works through the public package entry point', () {
    final decoration = BoxDecoration(
      color: const Color(0xFF2196F3),
      border: Border.all(color: const Color(0xFFFF0000), width: 2),
      borderRadius: BorderRadius.circular(8),
      gradient: const LinearGradient(
        colors: [Color(0xFFFF0000), Color(0xFF0000FF)],
      ),
    );

    final encoded = boxDecorationCodec.safeEncode(decoration);
    expect(encoded.isOk, isTrue);

    final json = jsonDecode(jsonEncode(encoded.getOrNull()));
    final decoded = boxDecorationCodec.safeParse(json);

    expect(decoded.getOrNull(), decoration);
    expect(jsonEncode(boxDecorationCodec.toJsonSchema()), isNotEmpty);
  });
}
