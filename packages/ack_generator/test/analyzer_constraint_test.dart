import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  test('ack_generator pins Analyzer to the supported 10.x line', () {
    final pubspec = File(
      p.join(
        Directory.current.path.endsWith('ack_generator')
            ? Directory.current.path
            : p.join(Directory.current.path, 'packages', 'ack_generator'),
        'pubspec.yaml',
      ),
    ).readAsStringSync();

    expect(pubspec, contains('analyzer: ">=10.0.0 <11.0.0"'));
  });
}
