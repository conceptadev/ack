import 'dart:convert';
import 'dart:io';

import 'package:flutter_codec/flutter_codec.dart';
import 'package:flutter_test/flutter_test.dart';

const _fixturePath = 'test/golden/fixtures/json_schema.json';
final _update = Platform.environment['UPDATE_GOLDENS'] == 'true';

typedef _SchemaExporter = Map<String, Object?> Function();

void main() {
  test('schema inventory covers every public codec declaration', () {
    expect(_schemaExporters.keys, unorderedEquals(_declaredPublicCodecNames()));
  });

  test('every public codec exports its recorded JSON Schema', () {
    final schemas = {
      for (final entry in _schemaExporters.entries) entry.key: entry.value(),
    };
    final actualText = _renderSchemas(schemas);
    final fixture = File(_fixturePath);

    if (_update) {
      fixture.parent.createSync(recursive: true);
      fixture.writeAsStringSync('$actualText\n');
      return;
    }

    expect(
      fixture.existsSync(),
      isTrue,
      reason:
          'Missing schema golden $_fixturePath. Generate it with '
          'UPDATE_GOLDENS=true flutter test test/golden/schema_golden_test.dart',
    );
    expect(
      actualText,
      fixture.readAsStringSync().trimRight(),
      reason:
          'JSON Schema drifted. If the change is intentional, regenerate with '
          'UPDATE_GOLDENS=true flutter test test/golden/schema_golden_test.dart.',
    );
  });
}

String _renderSchemas(Map<String, Map<String, Object?>> schemas) {
  final entries = schemas.entries.toList(growable: false);
  final buffer = StringBuffer('{\n');

  for (var index = 0; index < entries.length; index += 1) {
    final entry = entries[index];
    buffer
      ..write('  ${jsonEncode(entry.key)}: ${jsonEncode(entry.value)}')
      ..writeln(index == entries.length - 1 ? '' : ',');
  }

  return '${buffer.toString()}}';
}

Set<String> _declaredPublicCodecNames() {
  final declaration = RegExp(r'\b([a-z][A-Za-z0-9_]*Codec)\s*=');

  return Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .expand(
        (file) => declaration
            .allMatches(file.readAsStringSync())
            .map((match) => match.group(1)!),
      )
      .toSet();
}

final Map<String, _SchemaExporter> _schemaExporters = {
  'alignmentCodec': alignmentCodec.toJsonSchema,
  'alignmentDirectionalCodec': alignmentDirectionalCodec.toJsonSchema,
  'alignmentGeometryCodec': alignmentGeometryCodec.toJsonSchema,
  'assetImageCodec': assetImageCodec.toJsonSchema,
  'axisCodec': axisCodec.toJsonSchema,
  'axisDirectionCodec': axisDirectionCodec.toJsonSchema,
  'beveledRectangleBorderCodec': beveledRectangleBorderCodec.toJsonSchema,
  'blendModeCodec': blendModeCodec.toJsonSchema,
  'blurStyleCodec': blurStyleCodec.toJsonSchema,
  'borderCodec': borderCodec.toJsonSchema,
  'borderDirectionalCodec': borderDirectionalCodec.toJsonSchema,
  'borderRadiusCodec': borderRadiusCodec.toJsonSchema,
  'borderRadiusDirectionalCodec': borderRadiusDirectionalCodec.toJsonSchema,
  'borderRadiusGeometryCodec': borderRadiusGeometryCodec.toJsonSchema,
  'borderSideCodec': borderSideCodec.toJsonSchema,
  'borderStyleCodec': borderStyleCodec.toJsonSchema,
  'boxBorderCodec': boxBorderCodec.toJsonSchema,
  'boxConstraintsCodec': boxConstraintsCodec.toJsonSchema,
  'boxDecorationCodec': boxDecorationCodec.toJsonSchema,
  'boxFitCodec': boxFitCodec.toJsonSchema,
  'boxHeightStyleCodec': boxHeightStyleCodec.toJsonSchema,
  'boxShadowCodec': boxShadowCodec.toJsonSchema,
  'boxShapeCodec': boxShapeCodec.toJsonSchema,
  'boxWidthStyleCodec': boxWidthStyleCodec.toJsonSchema,
  'brightnessCodec': brightnessCodec.toJsonSchema,
  'circleBorderCodec': circleBorderCodec.toJsonSchema,
  'clipCodec': clipCodec.toJsonSchema,
  'colorCodec': colorCodec.toJsonSchema,
  'constraintsCodec': constraintsCodec.toJsonSchema,
  'containerWidgetCodec': containerWidgetCodec.toJsonSchema,
  'continuousRectangleBorderCodec': continuousRectangleBorderCodec.toJsonSchema,
  'crossAxisAlignmentCodec': crossAxisAlignmentCodec.toJsonSchema,
  'decorationCodec': decorationCodec.toJsonSchema,
  'decorationImageCodec': decorationImageCodec.toJsonSchema,
  'decorationPositionCodec': decorationPositionCodec.toJsonSchema,
  'dragStartBehaviorCodec': dragStartBehaviorCodec.toJsonSchema,
  'edgeInsetsCodec': edgeInsetsCodec.toJsonSchema,
  'edgeInsetsDirectionalCodec': edgeInsetsDirectionalCodec.toJsonSchema,
  'edgeInsetsGeometryCodec': edgeInsetsGeometryCodec.toJsonSchema,
  'filterQualityCodec': filterQualityCodec.toJsonSchema,
  'flexFitCodec': flexFitCodec.toJsonSchema,
  'fontFeatureCodec': fontFeatureCodec.toJsonSchema,
  'fontStyleCodec': fontStyleCodec.toJsonSchema,
  'fontVariationCodec': fontVariationCodec.toJsonSchema,
  'fontWeightCodec': fontWeightCodec.toJsonSchema,
  'gradientCodec': gradientCodec.toJsonSchema,
  'growthDirectionCodec': growthDirectionCodec.toJsonSchema,
  'hitTestBehaviorCodec': hitTestBehaviorCodec.toJsonSchema,
  'imageProviderCodec': imageProviderCodec.toJsonSchema,
  'imageRepeatCodec': imageRepeatCodec.toJsonSchema,
  'keyCodec': keyCodec.toJsonSchema,
  'linearBorderCodec': linearBorderCodec.toJsonSchema,
  'linearBorderEdgeCodec': linearBorderEdgeCodec.toJsonSchema,
  'linearGradientCodec': linearGradientCodec.toJsonSchema,
  'localeCodec': localeCodec.toJsonSchema,
  'mainAxisAlignmentCodec': mainAxisAlignmentCodec.toJsonSchema,
  'mainAxisSizeCodec': mainAxisSizeCodec.toJsonSchema,
  'materialTapTargetSizeCodec': materialTapTargetSizeCodec.toJsonSchema,
  'matrix4Codec': matrix4Codec.toJsonSchema,
  'networkImageCodec': networkImageCodec.toJsonSchema,
  'offsetCodec': offsetCodec.toJsonSchema,
  'paintingStyleCodec': paintingStyleCodec.toJsonSchema,
  'pathFillTypeCodec': pathFillTypeCodec.toJsonSchema,
  'placeholderAlignmentCodec': placeholderAlignmentCodec.toJsonSchema,
  'radialGradientCodec': radialGradientCodec.toJsonSchema,
  'radiusCodec': radiusCodec.toJsonSchema,
  'rectCodec': rectCodec.toJsonSchema,
  'roundedRectangleBorderCodec': roundedRectangleBorderCodec.toJsonSchema,
  'roundedSuperellipseBorderCodec': roundedSuperellipseBorderCodec.toJsonSchema,
  'scrollDirectionCodec': scrollDirectionCodec.toJsonSchema,
  'scrollViewKeyboardDismissBehaviorCodec':
      scrollViewKeyboardDismissBehaviorCodec.toJsonSchema,
  'shadowCodec': shadowCodec.toJsonSchema,
  'shapeBorderCodec': shapeBorderCodec.toJsonSchema,
  'shapeDecorationCodec': shapeDecorationCodec.toJsonSchema,
  'stackFitCodec': stackFitCodec.toJsonSchema,
  'stadiumBorderCodec': stadiumBorderCodec.toJsonSchema,
  'starBorderCodec': starBorderCodec.toJsonSchema,
  'strokeAlignCodec': strokeAlignCodec.toJsonSchema,
  'strokeCapCodec': strokeCapCodec.toJsonSchema,
  'strokeJoinCodec': strokeJoinCodec.toJsonSchema,
  'strutStyleCodec': strutStyleCodec.toJsonSchema,
  'sweepGradientCodec': sweepGradientCodec.toJsonSchema,
  'targetPlatformCodec': targetPlatformCodec.toJsonSchema,
  'textAlignCodec': textAlignCodec.toJsonSchema,
  'textBaselineCodec': textBaselineCodec.toJsonSchema,
  'textCapitalizationCodec': textCapitalizationCodec.toJsonSchema,
  'textDecorationCodec': textDecorationCodec.toJsonSchema,
  'textDecorationStyleCodec': textDecorationStyleCodec.toJsonSchema,
  'textDirectionCodec': textDirectionCodec.toJsonSchema,
  'textHeightBehaviorCodec': textHeightBehaviorCodec.toJsonSchema,
  'textLeadingDistributionCodec': textLeadingDistributionCodec.toJsonSchema,
  'textOverflowCodec': textOverflowCodec.toJsonSchema,
  'textStyleCodec': textStyleCodec.toJsonSchema,
  'textWidgetCodec': textWidgetCodec.toJsonSchema,
  'textWidthBasisCodec': textWidthBasisCodec.toJsonSchema,
  'themeModeCodec': themeModeCodec.toJsonSchema,
  'tileModeCodec': tileModeCodec.toJsonSchema,
  'verticalDirectionCodec': verticalDirectionCodec.toJsonSchema,
  'webHtmlElementStrategyCodec': webHtmlElementStrategyCodec.toJsonSchema,
  'widgetCodec': widgetCodec.toJsonSchema,
  'wrapAlignmentCodec': wrapAlignmentCodec.toJsonSchema,
  'wrapCrossAlignmentCodec': wrapCrossAlignmentCodec.toJsonSchema,
};
