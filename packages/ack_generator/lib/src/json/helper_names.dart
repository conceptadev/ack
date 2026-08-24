/// Pascal-case first letter used by per-field Ack runtime bridges.
String ackBridgePascal(String fieldName) {
  if (fieldName.isEmpty) return fieldName;
  return '${fieldName[0].toUpperCase()}${fieldName.substring(1)}';
}

/// Decode-side runtime bridge for a stored field.
String ackFromRuntimeBridgeName(String fieldName) =>
    '_ackFromRuntime${ackBridgePascal(fieldName)}';

/// Encode-side runtime bridge for a stored field.
String ackToRuntimeBridgeName(String fieldName) =>
    '_ackToRuntime${ackBridgePascal(fieldName)}';

/// Decode-side top-level bridge for a class-first stored field.
String ackClassFromRuntimeBridgeName(String className, String fieldName) =>
    '_ack${className}FromRuntime${ackBridgePascal(fieldName)}';

/// Encode-side top-level bridge for a class-first stored field.
String ackClassToRuntimeBridgeName(String className, String fieldName) =>
    '_ack${className}ToRuntime${ackBridgePascal(fieldName)}';

/// Runtime-map decoder for a hand-written class-first model.
String ackClassFromRuntimeName(String className) =>
    '_\$${className}FromRuntime';

/// Runtime-map encoder for a hand-written class-first model.
String ackClassToRuntimeName(String className) => '_\$${className}ToRuntime';

/// json_serializable `fromJson` helper for a generated model class.
String jsonFromHelperName(String className) => '_\$${className}FromJson';

/// json_serializable `toJson` helper for a generated model class.
String jsonToHelperName(String className) => '_\$${className}ToJson';

/// All per-field bridges derived from [fieldName].
Iterable<String> ackFieldBridgeNames(String fieldName) sync* {
  yield ackFromRuntimeBridgeName(fieldName);
  yield ackToRuntimeBridgeName(fieldName);
}

/// All top-level JSON helpers derived from [className].
Iterable<String> ackJsonHelperNames(String className) sync* {
  yield jsonFromHelperName(className);
  yield jsonToHelperName(className);
}
