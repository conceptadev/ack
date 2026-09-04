import 'package:ack/ack.dart';
import 'package:flutter/widgets.dart' show Key, ValueKey;

import '../json_readers.dart';

const _valueKeyType = 'value';

enum _ValueKeyValueType { string, int, double, bool }

/// Codec for portable [Key] values.
///
/// Only the exact scalar [ValueKey] types are supported. Identity-based keys
/// (`ObjectKey`, `UniqueKey`, and `GlobalKey` variants) cannot be serialized
/// because their equality depends on object identity or Flutter runtime state.
/// [ValueKey] subclasses such as `PageStorageKey` are also rejected on encode:
/// re-encoding them as a plain [ValueKey] would silently drop the subclass.
final keyCodec = Ack.discriminated<Key>(
  discriminatorKey: 'type',
  schemas: {_valueKeyType: _valueKeyCodec},
);

final _valueKeyCodec =
    Ack.object({
          'valueType': Ack.enumCodec(_ValueKeyValueType.values),
          'value': Ack.anyOf([
            Ack.string(),
            Ack.integer(),
            Ack.double(),
            Ack.boolean(),
          ]),
        })
        .refine(
          _valueMatchesValueType,
          message: 'ValueKey value must match its declared valueType.',
        )
        .codec<Key>(decode: _decodeKey, encode: _encodeKey);

bool _valueMatchesValueType(JsonMap data) {
  final valueType = readValue<_ValueKeyValueType>(data, 'valueType');
  final value = data['value'];

  return switch (valueType) {
    _ValueKeyValueType.string => value is String,
    _ValueKeyValueType.int => value is int,
    _ValueKeyValueType.double => value is num,
    _ValueKeyValueType.bool => value is bool,
  };
}

Key _decodeKey(JsonMap data) {
  final valueType = readValue<_ValueKeyValueType>(data, 'valueType');
  final value = data['value'];

  return switch (valueType) {
    _ValueKeyValueType.string => ValueKey(value as String),
    _ValueKeyValueType.int => ValueKey(value as int),
    _ValueKeyValueType.double => ValueKey((value as num).toDouble()),
    _ValueKeyValueType.bool => ValueKey(value as bool),
  };
}

JsonMap _encodeKey(Key value) {
  // Match the exact runtime type, not `is`: `ValueKey` subclasses such as
  // `PageStorageKey<String>` satisfy `is ValueKey<String>` and would otherwise
  // be silently re-encoded as a plain `ValueKey`, losing the subclass on
  // decode.
  final type = value.runtimeType;
  if (type == ValueKey<String>) {
    return _encodeValueKey(
      _ValueKeyValueType.string,
      (value as ValueKey<String>).value,
    );
  }
  if (type == ValueKey<int>) {
    return _encodeValueKey(
      _ValueKeyValueType.int,
      (value as ValueKey<int>).value,
    );
  }
  if (type == ValueKey<double>) {
    return _encodeValueKey(
      _ValueKeyValueType.double,
      (value as ValueKey<double>).value,
    );
  }
  if (type == ValueKey<bool>) {
    return _encodeValueKey(
      _ValueKeyValueType.bool,
      (value as ValueKey<bool>).value,
    );
  }

  throw FormatException(
    'keyCodec can only encode exactly ValueKey<String|int|double|bool>; '
    '${value.runtimeType} cannot be serialized because it is identity-based, '
    'a ValueKey subclass, or has no portable JSON shape.',
  );
}

JsonMap _encodeValueKey(_ValueKeyValueType valueType, Object value) => {
  'valueType': valueType,
  'value': value,
};
