import 'package:ack/ack.dart';
import 'package:flutter/widgets.dart' show Text;

import '../enums.dart'
    show
        textAlignCodec,
        textDirectionCodec,
        textOverflowCodec,
        textWidthBasisCodec;
import '../json_readers.dart';
import '../primitives/color.dart' show colorCodec;
import '../primitives/locale.dart' show localeCodec;
import '../primitives/text_height_behavior.dart' show textHeightBehaviorCodec;
import '../strut_style.dart' show strutStyleCodec;
import '../text_style.dart' show textStyleCodec;
import 'key.dart' show keyCodec;

/// Codec for plain [Text].
///
/// [Text.rich] is intentionally excluded until inline span trees have their own
/// codec. `textScaler` has no portable JSON shape (Flutter exposes no stable
/// public state for its concrete implementations); encoding a [Text] that sets
/// it fails validation rather than dropping it silently. The
/// deprecated `textScaleFactor` constructor parameter is not encoded.
final CodecSchema<JsonMap, Text> textWidgetCodec = Ack.object({
  'key': keyCodec.nullable().optional(),
  'data': Ack.string(),
  'style': textStyleCodec.nullable().optional(),
  'strutStyle': strutStyleCodec.nullable().optional(),
  'textAlign': textAlignCodec.nullable().optional(),
  'textDirection': textDirectionCodec.nullable().optional(),
  'locale': localeCodec.nullable().optional(),
  'softWrap': Ack.boolean().nullable().optional(),
  'overflow': textOverflowCodec.nullable().optional(),
  'maxLines': Ack.integer().min(1).nullable().optional(),
  'semanticsLabel': Ack.string().nullable().optional(),
  'semanticsIdentifier': Ack.string().nullable().optional(),
  'textWidthBasis': textWidthBasisCodec.nullable().optional(),
  'textHeightBehavior': textHeightBehaviorCodec.nullable().optional(),
  'selectionColor': colorCodec.nullable().optional(),
}).codec<Text>(decode: _decodeText, encode: _encodeText);

Text _decodeText(JsonMap data) {
  return Text(
    readValue(data, 'data'),
    key: readNullableValue(data, 'key'),
    style: readNullableValue(data, 'style'),
    strutStyle: readNullableValue(data, 'strutStyle'),
    textAlign: readNullableValue(data, 'textAlign'),
    textDirection: readNullableValue(data, 'textDirection'),
    locale: readNullableValue(data, 'locale'),
    softWrap: readNullableValue(data, 'softWrap'),
    overflow: readNullableValue(data, 'overflow'),
    maxLines: readNullableValue(data, 'maxLines'),
    semanticsLabel: readNullableValue(data, 'semanticsLabel'),
    semanticsIdentifier: readNullableValue(data, 'semanticsIdentifier'),
    textWidthBasis: readNullableValue(data, 'textWidthBasis'),
    textHeightBehavior: readNullableValue(data, 'textHeightBehavior'),
    selectionColor: readNullableValue(data, 'selectionColor'),
  );
}

JsonMap _encodeText(Text value) {
  if (value.textSpan != null) {
    throw FormatException(
      'Text.rich inline span trees are not supported by textWidgetCodec. '
      'Use Text with plain data instead.',
    );
  }

  // Flutter exposes no stable public state for a [TextScaler] implementation,
  // so it has no portable JSON shape. Fail loudly when one is set instead of
  // dropping it and decoding back an unscaled [Text].
  if (value.textScaler != null) {
    throw FormatException(
      'Text.textScaler has no portable JSON shape and cannot be encoded. '
      'Resolve text scaling outside the codec, or omit textScaler.',
    );
  }

  return {
    'key': value.key,
    'data': value.data,
    'style': value.style,
    'strutStyle': value.strutStyle,
    'textAlign': value.textAlign,
    'textDirection': value.textDirection,
    'locale': value.locale,
    'softWrap': value.softWrap,
    'overflow': value.overflow,
    'maxLines': value.maxLines,
    'semanticsLabel': value.semanticsLabel,
    'semanticsIdentifier': value.semanticsIdentifier,
    'textWidthBasis': value.textWidthBasis,
    'textHeightBehavior': value.textHeightBehavior,
    'selectionColor': value.selectionColor,
  };
}
