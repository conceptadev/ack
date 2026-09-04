import 'package:ack/ack.dart';
import 'package:flutter/painting.dart' show EdgeInsetsGeometry;
import 'package:flutter/widgets.dart' show Clip, Container, Widget;

import '../constraints.dart' show boxConstraintsCodec;
import '../decorations.dart' show decorationCodec;
import '../enums.dart' show clipCodec;
import '../json_readers.dart';
import '../primitives/alignment.dart' show alignmentGeometryCodec;
import '../primitives/color.dart' show colorCodec;
import '../primitives/edge_insets.dart' show edgeInsetsGeometryCodec;
import '../primitives/matrix4.dart' show matrix4Codec;
import 'key.dart' show keyCodec;
import 'widget.dart' show widgetCodec;

/// Maximum supported depth for recursive [Container.child] widget decoding and
/// encoding.
const int containerWidgetMaxDepth = 64;

/// Codec for [Container].
///
/// `width` and `height` are accepted on decode because they are constructor
/// parameters, but Flutter stores them by tightening [Container.constraints].
/// Encoding therefore canonicalizes both shorthands to `constraints`.
final CodecSchema<JsonMap, Container> containerWidgetCodec =
    Ack.object({
          'key': keyCodec.nullable().optional(),
          'alignment': alignmentGeometryCodec.nullable().optional(),
          'padding': edgeInsetsGeometryCodec.nullable().optional(),
          'color': colorCodec.nullable().optional(),
          'isAntiAlias': Ack.boolean().withDefault(true),
          'decoration': decorationCodec.nullable().optional(),
          'foregroundDecoration': decorationCodec.nullable().optional(),
          'width': Ack.number().min(0).nullable().optional(),
          'height': Ack.number().min(0).nullable().optional(),
          'constraints': boxConstraintsCodec.nullable().optional(),
          'margin': edgeInsetsGeometryCodec.nullable().optional(),
          'transform': matrix4Codec.nullable().optional(),
          'transformAlignment': alignmentGeometryCodec.nullable().optional(),
          'clipBehavior': clipCodec.withDefault(Clip.none),
          'child': Ack.lazy<JsonMap, Widget>(
            'widgetCodec',
            () => widgetCodec,
            maxDepth: containerWidgetMaxDepth,
          ).nullable().optional(),
        })
        // Enforce the constructor's cross-field invariants here so validation holds
        // in release builds too (Flutter's asserts are stripped outside debug).
        .refine(
          (data) => data['color'] == null || data['decoration'] == null,
          message: 'Container cannot set both color and decoration.',
        )
        .refine(
          (data) =>
              data['decoration'] != null || data['clipBehavior'] == Clip.none,
          message: 'Container clipBehavior requires a decoration.',
        )
        // Reject negative insets: Flutter's Padding/margin handling asserts
        // non-negative edges in debug, and the assert is stripped in release.
        .refine(
          (data) => _hasNonNegativeInset(data, 'padding'),
          message: 'Container padding must not be negative.',
        )
        .refine(
          (data) => _hasNonNegativeInset(data, 'margin'),
          message: 'Container margin must not be negative.',
        )
        .codec<Container>(decode: _decodeContainer, encode: _encodeContainer);

bool _hasNonNegativeInset(JsonMap data, String key) {
  final inset = data[key];

  return inset is! EdgeInsetsGeometry || inset.isNonNegative;
}

Container _decodeContainer(JsonMap data) {
  return Container(
    key: readNullableValue(data, 'key'),
    alignment: readNullableValue(data, 'alignment'),
    padding: readNullableValue(data, 'padding'),
    color: readNullableValue(data, 'color'),
    isAntiAlias: readValue(data, 'isAntiAlias'),
    decoration: readNullableValue(data, 'decoration'),
    foregroundDecoration: readNullableValue(data, 'foregroundDecoration'),
    width: readNullableDouble(data, 'width'),
    height: readNullableDouble(data, 'height'),
    constraints: readNullableValue(data, 'constraints'),
    margin: readNullableValue(data, 'margin'),
    transform: readNullableValue(data, 'transform'),
    transformAlignment: readNullableValue(data, 'transformAlignment'),
    clipBehavior: readValue(data, 'clipBehavior'),
    child: readNullableValue(data, 'child'),
  );
}

JsonMap _encodeContainer(Container value) {
  return {
    'key': value.key,
    'alignment': value.alignment,
    'padding': value.padding,
    'color': value.color,
    'isAntiAlias': value.isAntiAlias,
    'decoration': value.decoration,
    'foregroundDecoration': value.foregroundDecoration,
    'width': null,
    'height': null,
    'constraints': value.constraints,
    'margin': value.margin,
    'transform': value.transform,
    'transformAlignment': value.transformAlignment,
    'clipBehavior': value.clipBehavior,
    'child': value.child,
  };
}
