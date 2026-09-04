import 'package:ack/ack.dart';
import 'package:flutter/widgets.dart' show Widget;

import 'container.dart' show containerWidgetCodec;
import 'text.dart' show textWidgetCodec;

/// Codec for the supported [Widget] union, discriminated by `"type"`.
///
/// Current branches are [Container] (`"container"`) and [Text] (`"text"`).
/// Additional widget branches register here as they gain first-class codecs.
final DiscriminatedObjectSchema<Widget> widgetCodec = Ack.discriminated<Widget>(
  discriminatorKey: 'type',
  schemas: {'container': containerWidgetCodec, 'text': textWidgetCodec},
);
