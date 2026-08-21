import 'package:analyzer/dart/element/type.dart';
import 'package:json_serializable/type_helper.dart';

import 'helper_names.dart';

/// Routes every stored Ack field through generated runtime bridge methods.
///
/// The input is an already-validated Ack runtime value, so this helper must
/// claim scalars as well as nested models. Default json_serializable codecs
/// would otherwise decode DateTime, Uri, enums, or nested JSON a second time.
final class AckRuntimeTypeHelper extends TypeHelper<TypeHelperContext> {
  const AckRuntimeTypeHelper();

  @override
  Object? serialize(
    DartType targetType,
    String expression,
    TypeHelperContext context,
  ) {
    return '${context.classElement.name}.${ackToRuntimeBridgeName(context.fieldElement.name!)}($expression)';
  }

  @override
  Object? deserialize(
    DartType targetType,
    String expression,
    TypeHelperContext context,
    bool defaultProvided,
  ) {
    return '${context.classElement.name}.${ackFromRuntimeBridgeName(context.fieldElement.name!)}($expression)';
  }
}
