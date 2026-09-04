import 'package:ack/ack.dart';
import 'package:flutter/painting.dart'
    show Alignment, BoxFit, DecorationImage, FilterQuality, ImageRepeat;

import 'enums.dart' show boxFitCodec, filterQualityCodec, imageRepeatCodec;
import 'image_providers.dart' show imageProviderCodec;
import 'json_readers.dart';
import 'primitives/alignment.dart' show alignmentGeometryCodec;
import 'primitives/rect.dart' show rectCodec;

/// Codec for [DecorationImage].
///
/// Composes [imageProviderCodec] (the required image), the [BoxFit] /
/// [ImageRepeat] / [FilterQuality] enum codecs, [alignmentGeometryCodec], and
/// [rectCodec]. All non-`image` fields default to the Flutter
/// [DecorationImage] constructor defaults.
///
/// Note: `opacity` is range-validated `[0, 1]` here. Flutter only clamps it
/// at paint time, so this codec is stricter than the constructor — invalid
/// inputs fail to parse rather than silently clamp.
///
/// Intentionally unsupported:
/// * `colorFilter` — `ColorFilter` keeps its constructor arguments
///   (`color`, `blendMode`, `matrix`, type discriminator) in library-private
///   fields with no public getters, and exposes the same `runtimeType` for
///   all four constructor variants. There is no portable, contract-stable
///   way to inspect an existing instance back to JSON, so a bidirectional
///   codec is not achievable via the public API. The same constraint applies
///   to `ImageFilter` (private subtypes, private state).
/// * `onError` — callback type, not serializable.
///
/// Both are dropped because the schema has no field for them. [onError] is
/// excluded from [DecorationImage]'s `==`, so its loss is invisible. But
/// `colorFilter` *is* compared by `==` and `hashCode`, so a [DecorationImage]
/// with a non-null `colorFilter` cannot round-trip: encoding one throws
/// (rather than silently producing an unequal value), mirroring the
/// `assetImageCodec` `bundle` guard.
final decorationImageCodec =
    Ack.object({
      'image': imageProviderCodec,
      'fit': boxFitCodec.nullable().optional(),
      'alignment': alignmentGeometryCodec.withDefault(Alignment.center),
      'centerSlice': rectCodec.nullable().optional(),
      'repeat': imageRepeatCodec.withDefault(ImageRepeat.noRepeat),
      'matchTextDirection': Ack.boolean().withDefault(false),
      'scale': Ack.number().withDefault(1.0),
      'opacity': Ack.number().min(0).max(1).withDefault(1.0),
      'filterQuality': filterQualityCodec.withDefault(FilterQuality.medium),
      'invertColors': Ack.boolean().withDefault(false),
      'isAntiAlias': Ack.boolean().withDefault(false),
    }).codec<DecorationImage>(
      decode: (data) => DecorationImage(
        image: readValue(data, 'image'),
        fit: readNullableValue(data, 'fit'),
        alignment: readValue(data, 'alignment'),
        centerSlice: readNullableValue(data, 'centerSlice'),
        repeat: readValue(data, 'repeat'),
        matchTextDirection: readValue(data, 'matchTextDirection'),
        scale: readDouble(data, 'scale'),
        opacity: readDouble(data, 'opacity'),
        filterQuality: readValue(data, 'filterQuality'),
        invertColors: readValue(data, 'invertColors'),
        isAntiAlias: readValue(data, 'isAntiAlias'),
      ),
      encode: (value) {
        if (value.colorFilter != null) {
          throw FormatException(
            'DecorationImage.colorFilter cannot be encoded: ColorFilter keeps '
            'its state in library-private fields with no public getters, so it '
            'has no portable JSON shape, and it is part of DecorationImage '
            'equality. Remove the colorFilter before encoding.',
          );
        }

        return {
          'image': value.image,
          'fit': value.fit,
          'alignment': value.alignment,
          'centerSlice': value.centerSlice,
          'repeat': value.repeat,
          'matchTextDirection': value.matchTextDirection,
          'scale': value.scale,
          'opacity': value.opacity,
          'filterQuality': value.filterQuality,
          'invertColors': value.invertColors,
          'isAntiAlias': value.isAntiAlias,
        };
      },
    );
