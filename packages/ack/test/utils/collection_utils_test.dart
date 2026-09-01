import 'package:ack/ack.dart';
import 'package:test/test.dart';

void main() {
  test('deepUnmodifiableJsonMap snapshots nested maps, lists, and sets', () {
    final nestedMap = <String, Object?>{'enabled': true};
    final nestedList = <Object?>[nestedMap];
    final nestedSet = <Object?>{'first', nestedList};
    final source = <String, Object?>{
      'map': nestedMap,
      'list': nestedList,
      'set': nestedSet,
    };

    final snapshot = deepUnmodifiableJsonMap(source);

    source['later'] = true;
    nestedMap['enabled'] = false;
    nestedList.add('later');
    nestedSet.add('later');

    expect(snapshot, {
      'map': {'enabled': true},
      'list': [
        {'enabled': true},
      ],
      'set': {
        'first',
        [
          {'enabled': true},
        ],
      },
    });
    expect(() => snapshot['later'] = true, throwsUnsupportedError);
    expect(
      () => (snapshot['map']! as Map<String, Object?>)['later'] = true,
      throwsUnsupportedError,
    );
    expect(
      () => (snapshot['list']! as List<Object?>).add('later'),
      throwsUnsupportedError,
    );
    expect(
      () => (snapshot['set']! as Set<Object?>).add('later'),
      throwsUnsupportedError,
    );
  });

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

  test('deep map keys preserve scalar types and the hash contract', () {
    final equivalentPairs = <(Object?, Object?)>[
      (<num, String>{1: 'one'}, <num, String>{1: 'one'}),
      (
        <Object?, Object?>{
          'nested': <num, Object?>{
            1: <Object?>['value'],
          },
        },
        <Object?, Object?>{
          'nested': <num, Object?>{
            1: <Object?>['value'],
          },
        },
      ),
      (
        <String, Object?>{
          'nested': <Object?>[
            <String, Object?>{
              'values': <Object?>{1, 'one'},
            },
          ],
        },
        <String, Object?>{
          'nested': <Object?>[
            <String, Object?>{
              'values': <Object?>{'one', 1},
            },
          ],
        },
      ),
    ];

    for (final (left, right) in equivalentPairs) {
      expect(deepEquals(left, right), isTrue);
      expect(
        deepHashCode(left),
        deepHashCode(right),
        reason: 'deep-equal values must have the same hash code',
      );
    }

    expect(
      deepEquals(<num, String>{1: 'one'}, <num, String>{1.0: 'one'}),
      isFalse,
      reason: 'map keys follow the same type-sensitive scalar semantics',
    );
  });
}
