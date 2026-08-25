import 'package:ack/ack.dart';
import 'package:test/test.dart';

void main() {
  test(
    'deepEquals and deepHashCode stay consistent for nested collections',
    () {
      final left = {
        'tags': ['a', 'b'],
        'scores': {'x': 1, 'y': 2},
        'flags': {'on', 'off'},
      };
      final right = {
        'tags': ['a', 'b'],
        'scores': {'y': 2, 'x': 1},
        'flags': {'off', 'on'},
      };
      final different = {
        'tags': ['a', 'c'],
        'scores': {'x': 1, 'y': 2},
        'flags': {'on', 'off'},
      };

      expect(deepEquals(left, right), isTrue);
      expect(deepHashCode(left), deepHashCode(right));
      expect(deepEquals(left, different), isFalse);
      expect(deepEquals([1], [1.0]), isFalse);
      expect(deepHashCode([1]), isNot(deepHashCode([1.0])));
    },
  );

  test('deep collection semantics ignore concrete collection wrappers', () {
    final growable = <Object?>[
      1,
      <String, Object?>{
        'items': <String>['a', 'b'],
      },
    ];
    final wrapped = List<Object?>.unmodifiable([
      1,
      Map<String, Object?>.unmodifiable({
        'items': List<String>.unmodifiable(['a', 'b']),
      }),
    ]);

    expect(deepEquals(growable, wrapped), isTrue);
    expect(deepHashCode(growable), deepHashCode(wrapped));
    expect(deepEquals([1], [1.0]), isFalse);
  });
}
