// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'schema_types_edge_cases.dart';

// **************************************************************************
// AckSchemaGenerator
// **************************************************************************

/// Immutable model generated from `productSchema`.
@AckType.jsonSerializable
final class Product {
  Product({
    required this.name,
    required List<String> tags,
    required List<int> scores,
    required List<bool> flags,
  }) : tags = List<String>.unmodifiable(tags.map((item) => item)),
       scores = List<int>.unmodifiable(scores.map((item) => item)),
       flags = List<bool>.unmodifiable(flags.map((item) => item));

  factory Product.parse(Object? input) {
    return $ack.parse(input);
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return $ack.parse(json);
  }

  final String name;

  final List<String> tags;

  final List<int> scores;

  final List<bool> flags;

  static final $ack = AckModelAdapter(
    schema: () => productSchema,
    fromRuntime: Product._fromAckRuntime,
    toRuntime: (model) => model._toAckRuntime(),
  );

  static SchemaResult<Product> safeParse(Object? input) =>
      $ack.safeParse(input);

  Map<String, dynamic> toJson() => Map<String, dynamic>.from($ack.encode(this));

  SchemaResult<Map<String, Object?>> safeToJson() => $ack.safeEncode(this);

  static Product _fromAckRuntime(Map<String, Object?> value) =>
      _$ProductFromJson(Map<String, dynamic>.from(value));

  Map<String, Object?> _toAckRuntime() => <String, Object?>{
    ..._$ProductToJson(this),
  };

  static String _ackFromRuntimeName(Object? value) => value as String;

  static Object? _ackToRuntimeName(String value) => value;

  static List<String> _ackFromRuntimeTags(Object? value) =>
      (value as List).map((item) => item as String).toList();

  static Object? _ackToRuntimeTags(List<String> value) =>
      value.map((item) => item).toList(growable: false);

  static List<int> _ackFromRuntimeScores(Object? value) =>
      (value as List).map((item) => item as int).toList();

  static Object? _ackToRuntimeScores(List<int> value) =>
      value.map((item) => item).toList(growable: false);

  static List<bool> _ackFromRuntimeFlags(Object? value) =>
      (value as List).map((item) => item as bool).toList();

  static Object? _ackToRuntimeFlags(List<bool> value) =>
      value.map((item) => item).toList(growable: false);
}

/// Immutable model generated from `gridSchema`.
@AckType.jsonSerializable
final class Grid {
  Grid({required this.name, required List<List<int>> matrix})
    : matrix = List<List<int>>.unmodifiable(
        matrix.map((item) => List<int>.unmodifiable(item.map((item) => item))),
      );

  factory Grid.parse(Object? input) {
    return $ack.parse(input);
  }

  factory Grid.fromJson(Map<String, dynamic> json) {
    return $ack.parse(json);
  }

  final String name;

  final List<List<int>> matrix;

  static final $ack = AckModelAdapter(
    schema: () => gridSchema,
    fromRuntime: Grid._fromAckRuntime,
    toRuntime: (model) => model._toAckRuntime(),
  );

  static SchemaResult<Grid> safeParse(Object? input) => $ack.safeParse(input);

  Map<String, dynamic> toJson() => Map<String, dynamic>.from($ack.encode(this));

  SchemaResult<Map<String, Object?>> safeToJson() => $ack.safeEncode(this);

  static Grid _fromAckRuntime(Map<String, Object?> value) =>
      _$GridFromJson(Map<String, dynamic>.from(value));

  Map<String, Object?> _toAckRuntime() => <String, Object?>{
    ..._$GridToJson(this),
  };

  static String _ackFromRuntimeName(Object? value) => value as String;

  static Object? _ackToRuntimeName(String value) => value;

  static List<List<int>> _ackFromRuntimeMatrix(Object? value) => (value as List)
      .map((item) => (item as List).map((item) => item as int).toList())
      .toList();

  static Object? _ackToRuntimeMatrix(List<List<int>> value) => value
      .map((item) => item.map((item) => item).toList(growable: false))
      .toList(growable: false);
}

/// Immutable model generated from `addressSchema`.
@AckType.jsonSerializable
final class Address {
  Address({
    required this.street,
    required this.city,
    required this.zipCode,
    required this.country,
  });

  factory Address.parse(Object? input) {
    return $ack.parse(input);
  }

  factory Address.fromJson(Map<String, dynamic> json) {
    return $ack.parse(json);
  }

  final String street;

  final String city;

  final String zipCode;

  final String country;

  static final $ack = AckModelAdapter(
    schema: () => addressSchema,
    fromRuntime: Address._fromAckRuntime,
    toRuntime: (model) => model._toAckRuntime(),
  );

  static SchemaResult<Address> safeParse(Object? input) =>
      $ack.safeParse(input);

  Map<String, dynamic> toJson() => Map<String, dynamic>.from($ack.encode(this));

  SchemaResult<Map<String, Object?>> safeToJson() => $ack.safeEncode(this);

  static Address _fromAckRuntime(Map<String, Object?> value) =>
      _$AddressFromJson(Map<String, dynamic>.from(value));

  Map<String, Object?> _toAckRuntime() => <String, Object?>{
    ..._$AddressToJson(this),
  };

  static String _ackFromRuntimeStreet(Object? value) => value as String;

  static Object? _ackToRuntimeStreet(String value) => value;

  static String _ackFromRuntimeCity(Object? value) => value as String;

  static Object? _ackToRuntimeCity(String value) => value;

  static String _ackFromRuntimeZipCode(Object? value) => value as String;

  static Object? _ackToRuntimeZipCode(String value) => value;

  static String _ackFromRuntimeCountry(Object? value) => value as String;

  static Object? _ackToRuntimeCountry(String value) => value;
}

/// Immutable model generated from `personSchema`.
@AckType.jsonSerializable
final class Person {
  Person({
    required this.name,
    required this.email,
    required this.address,
    required this.age,
  });

  factory Person.parse(Object? input) {
    return $ack.parse(input);
  }

  factory Person.fromJson(Map<String, dynamic> json) {
    return $ack.parse(json);
  }

  final String name;

  final String email;

  final Address address;

  final int age;

  static final $ack = AckModelAdapter(
    schema: () => personSchema,
    fromRuntime: Person._fromAckRuntime,
    toRuntime: (model) => model._toAckRuntime(),
  );

  static SchemaResult<Person> safeParse(Object? input) => $ack.safeParse(input);

  Map<String, dynamic> toJson() => Map<String, dynamic>.from($ack.encode(this));

  SchemaResult<Map<String, Object?>> safeToJson() => $ack.safeEncode(this);

  static Person _fromAckRuntime(Map<String, Object?> value) =>
      _$PersonFromJson(Map<String, dynamic>.from(value));

  Map<String, Object?> _toAckRuntime() => <String, Object?>{
    ..._$PersonToJson(this),
  };

  static String _ackFromRuntimeName(Object? value) => value as String;

  static Object? _ackToRuntimeName(String value) => value;

  static String _ackFromRuntimeEmail(Object? value) => value as String;

  static Object? _ackToRuntimeEmail(String value) => value;

  static Address _ackFromRuntimeAddress(Object? value) =>
      Address.$ack.fromRuntime(value as Map<String, Object?>);

  static Object? _ackToRuntimeAddress(Address value) =>
      Address.$ack.toRuntime(value);

  static int _ackFromRuntimeAge(Object? value) => value as int;

  static Object? _ackToRuntimeAge(int value) => value;
}

/// Immutable model generated from `employeeSchema`.
@AckType.jsonSerializable
final class Employee {
  Employee({
    required this.name,
    required this.employeeId,
    required this.homeAddress,
    required this.workAddress,
  });

  factory Employee.parse(Object? input) {
    return $ack.parse(input);
  }

  factory Employee.fromJson(Map<String, dynamic> json) {
    return $ack.parse(json);
  }

  final String name;

  final String employeeId;

  final Address homeAddress;

  final Address workAddress;

  static final $ack = AckModelAdapter(
    schema: () => employeeSchema,
    fromRuntime: Employee._fromAckRuntime,
    toRuntime: (model) => model._toAckRuntime(),
  );

  static SchemaResult<Employee> safeParse(Object? input) =>
      $ack.safeParse(input);

  Map<String, dynamic> toJson() => Map<String, dynamic>.from($ack.encode(this));

  SchemaResult<Map<String, Object?>> safeToJson() => $ack.safeEncode(this);

  static Employee _fromAckRuntime(Map<String, Object?> value) =>
      _$EmployeeFromJson(Map<String, dynamic>.from(value));

  Map<String, Object?> _toAckRuntime() => <String, Object?>{
    ..._$EmployeeToJson(this),
  };

  static String _ackFromRuntimeName(Object? value) => value as String;

  static Object? _ackToRuntimeName(String value) => value;

  static String _ackFromRuntimeEmployeeId(Object? value) => value as String;

  static Object? _ackToRuntimeEmployeeId(String value) => value;

  static Address _ackFromRuntimeHomeAddress(Object? value) =>
      Address.$ack.fromRuntime(value as Map<String, Object?>);

  static Object? _ackToRuntimeHomeAddress(Address value) =>
      Address.$ack.toRuntime(value);

  static Address _ackFromRuntimeWorkAddress(Object? value) =>
      Address.$ack.fromRuntime(value as Map<String, Object?>);

  static Object? _ackToRuntimeWorkAddress(Address value) =>
      Address.$ack.toRuntime(value);
}

/// Immutable model generated from `modifierSchema`.
@AckType.jsonSerializable
final class Modifier {
  Modifier({
    required this.requiredField,
    this.optionalField,
    required this.nullableField,
    this.optionalNullable,
    this.nullableOptional,
  });

  factory Modifier.parse(Object? input) {
    return $ack.parse(input);
  }

  factory Modifier.fromJson(Map<String, dynamic> json) {
    return $ack.parse(json);
  }

  final String requiredField;

  final String? optionalField;

  final String? nullableField;

  final String? optionalNullable;

  final String? nullableOptional;

  static final $ack = AckModelAdapter(
    schema: () => modifierSchema,
    fromRuntime: Modifier._fromAckRuntime,
    toRuntime: (model) => model._toAckRuntime(),
  );

  static SchemaResult<Modifier> safeParse(Object? input) =>
      $ack.safeParse(input);

  Map<String, dynamic> toJson() => Map<String, dynamic>.from($ack.encode(this));

  SchemaResult<Map<String, Object?>> safeToJson() => $ack.safeEncode(this);

  static Modifier _fromAckRuntime(Map<String, Object?> value) =>
      _$ModifierFromJson(Map<String, dynamic>.from(value));

  Map<String, Object?> _toAckRuntime() {
    final result = <String, Object?>{..._$ModifierToJson(this)};
    if (nullableField == null) {
      result['nullableField'] = null;
    }
    return <String, Object?>{...result};
  }

  static String _ackFromRuntimeRequiredField(Object? value) => value as String;

  static Object? _ackToRuntimeRequiredField(String value) => value;

  static String? _ackFromRuntimeOptionalField(Object? value) =>
      value as String?;

  static Object? _ackToRuntimeOptionalField(String? value) => value;

  static String? _ackFromRuntimeNullableField(Object? value) =>
      value as String?;

  static Object? _ackToRuntimeNullableField(String? value) => value;

  static String? _ackFromRuntimeOptionalNullable(Object? value) =>
      value as String?;

  static Object? _ackToRuntimeOptionalNullable(String? value) => value;

  static String? _ackFromRuntimeNullableOptional(Object? value) =>
      value as String?;

  static Object? _ackToRuntimeNullableOptional(String? value) => value;
}

/// Immutable model generated from `taggedItemSchema`.
@AckType.jsonSerializable
final class TaggedItem {
  TaggedItem({
    required this.name,
    required List<String> requiredTags,
    List<String>? optionalTags,
    required List<String>? nullableTags,
  }) : requiredTags = List<String>.unmodifiable(
         requiredTags.map((item) => item),
       ),
       optionalTags = switch (optionalTags) {
         null => null,
         final fieldValue => List<String>.unmodifiable(
           fieldValue.map((item) => item),
         ),
       },
       nullableTags = switch (nullableTags) {
         null => null,
         final fieldValue => List<String>.unmodifiable(
           fieldValue.map((item) => item),
         ),
       };

  factory TaggedItem.parse(Object? input) {
    return $ack.parse(input);
  }

  factory TaggedItem.fromJson(Map<String, dynamic> json) {
    return $ack.parse(json);
  }

  final String name;

  final List<String> requiredTags;

  final List<String>? optionalTags;

  final List<String>? nullableTags;

  static final $ack = AckModelAdapter(
    schema: () => taggedItemSchema,
    fromRuntime: TaggedItem._fromAckRuntime,
    toRuntime: (model) => model._toAckRuntime(),
  );

  static SchemaResult<TaggedItem> safeParse(Object? input) =>
      $ack.safeParse(input);

  Map<String, dynamic> toJson() => Map<String, dynamic>.from($ack.encode(this));

  SchemaResult<Map<String, Object?>> safeToJson() => $ack.safeEncode(this);

  static TaggedItem _fromAckRuntime(Map<String, Object?> value) =>
      _$TaggedItemFromJson(Map<String, dynamic>.from(value));

  Map<String, Object?> _toAckRuntime() {
    final result = <String, Object?>{..._$TaggedItemToJson(this)};
    if (nullableTags == null) {
      result['nullableTags'] = null;
    }
    return <String, Object?>{...result};
  }

  static String _ackFromRuntimeName(Object? value) => value as String;

  static Object? _ackToRuntimeName(String value) => value;

  static List<String> _ackFromRuntimeRequiredTags(Object? value) =>
      (value as List).map((item) => item as String).toList();

  static Object? _ackToRuntimeRequiredTags(List<String> value) =>
      value.map((item) => item).toList(growable: false);

  static List<String>? _ackFromRuntimeOptionalTags(Object? value) =>
      switch (value) {
        null => null,
        final fieldValue =>
          (fieldValue as List).map((item) => item as String).toList(),
      };

  static Object? _ackToRuntimeOptionalTags(List<String>? value) =>
      switch (value) {
        null => null,
        final fieldValue =>
          fieldValue.map((item) => item).toList(growable: false),
      };

  static List<String>? _ackFromRuntimeNullableTags(Object? value) =>
      switch (value) {
        null => null,
        final fieldValue =>
          (fieldValue as List).map((item) => item as String).toList(),
      };

  static Object? _ackToRuntimeNullableTags(List<String>? value) =>
      switch (value) {
        null => null,
        final fieldValue =>
          fieldValue.map((item) => item).toList(growable: false),
      };
}

/// Immutable model generated from `contactListSchema`.
@AckType.jsonSerializable
final class ContactList {
  ContactList({required this.name, required List<Address> addresses})
    : addresses = List<Address>.unmodifiable(addresses.map((item) => item));

  factory ContactList.parse(Object? input) {
    return $ack.parse(input);
  }

  factory ContactList.fromJson(Map<String, dynamic> json) {
    return $ack.parse(json);
  }

  final String name;

  final List<Address> addresses;

  static final $ack = AckModelAdapter(
    schema: () => contactListSchema,
    fromRuntime: ContactList._fromAckRuntime,
    toRuntime: (model) => model._toAckRuntime(),
  );

  static SchemaResult<ContactList> safeParse(Object? input) =>
      $ack.safeParse(input);

  Map<String, dynamic> toJson() => Map<String, dynamic>.from($ack.encode(this));

  SchemaResult<Map<String, Object?>> safeToJson() => $ack.safeEncode(this);

  static ContactList _fromAckRuntime(Map<String, Object?> value) =>
      _$ContactListFromJson(Map<String, dynamic>.from(value));

  Map<String, Object?> _toAckRuntime() => <String, Object?>{
    ..._$ContactListToJson(this),
  };

  static String _ackFromRuntimeName(Object? value) => value as String;

  static Object? _ackToRuntimeName(String value) => value;

  static List<Address> _ackFromRuntimeAddresses(Object? value) =>
      (value as List)
          .map((item) => Address.$ack.fromRuntime(item as Map<String, Object?>))
          .toList();

  static Object? _ackToRuntimeAddresses(List<Address> value) =>
      value.map((item) => Address.$ack.toRuntime(item)).toList(growable: false);
}

/// Immutable model generated from `emptySchema`.
@AckType.jsonSerializable
final class Empty {
  Empty();

  factory Empty.parse(Object? input) {
    return $ack.parse(input);
  }

  factory Empty.fromJson(Map<String, dynamic> json) {
    return $ack.parse(json);
  }

  static final $ack = AckModelAdapter(
    schema: () => emptySchema,
    fromRuntime: Empty._fromAckRuntime,
    toRuntime: (model) => model._toAckRuntime(),
  );

  static SchemaResult<Empty> safeParse(Object? input) => $ack.safeParse(input);

  Map<String, dynamic> toJson() => Map<String, dynamic>.from($ack.encode(this));

  SchemaResult<Map<String, Object?>> safeToJson() => $ack.safeEncode(this);

  static Empty _fromAckRuntime(Map<String, Object?> value) =>
      _$EmptyFromJson(Map<String, dynamic>.from(value));

  Map<String, Object?> _toAckRuntime() => <String, Object?>{
    ..._$EmptyToJson(this),
  };
}

/// Immutable model generated from `minimalSchema`.
@AckType.jsonSerializable
final class Minimal {
  Minimal({required this.id});

  factory Minimal.parse(Object? input) {
    return $ack.parse(input);
  }

  factory Minimal.fromJson(Map<String, dynamic> json) {
    return $ack.parse(json);
  }

  final String id;

  static final $ack = AckModelAdapter(
    schema: () => minimalSchema,
    fromRuntime: Minimal._fromAckRuntime,
    toRuntime: (model) => model._toAckRuntime(),
  );

  static SchemaResult<Minimal> safeParse(Object? input) =>
      $ack.safeParse(input);

  Map<String, dynamic> toJson() => Map<String, dynamic>.from($ack.encode(this));

  SchemaResult<Map<String, Object?>> safeToJson() => $ack.safeEncode(this);

  static Minimal _fromAckRuntime(Map<String, Object?> value) =>
      _$MinimalFromJson(Map<String, dynamic>.from(value));

  Map<String, Object?> _toAckRuntime() => <String, Object?>{
    ..._$MinimalToJson(this),
  };

  static String _ackFromRuntimeId(Object? value) => value as String;

  static Object? _ackToRuntimeId(String value) => value;
}

/// Immutable model generated from `namedItemSchema`.
@AckType.jsonSerializable
final class NamedItem {
  NamedItem({required this.name});

  factory NamedItem.parse(Object? input) {
    return $ack.parse(input);
  }

  factory NamedItem.fromJson(Map<String, dynamic> json) {
    return $ack.parse(json);
  }

  final String name;

  static final $ack = AckModelAdapter(
    schema: () => namedItemSchema,
    fromRuntime: NamedItem._fromAckRuntime,
    toRuntime: (model) => model._toAckRuntime(),
  );

  static SchemaResult<NamedItem> safeParse(Object? input) =>
      $ack.safeParse(input);

  Map<String, dynamic> toJson() => Map<String, dynamic>.from($ack.encode(this));

  SchemaResult<Map<String, Object?>> safeToJson() => $ack.safeEncode(this);

  static NamedItem _fromAckRuntime(Map<String, Object?> value) =>
      _$NamedItemFromJson(Map<String, dynamic>.from(value));

  Map<String, Object?> _toAckRuntime() => <String, Object?>{
    ..._$NamedItemToJson(this),
  };

  static String _ackFromRuntimeName(Object? value) => value as String;

  static Object? _ackToRuntimeName(String value) => value;
}

/// Immutable model generated from `item`.
@AckType.jsonSerializable
final class Item {
  Item({required this.id});

  factory Item.parse(Object? input) {
    return $ack.parse(input);
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    return $ack.parse(json);
  }

  final String id;

  static final $ack = AckModelAdapter(
    schema: () => item,
    fromRuntime: Item._fromAckRuntime,
    toRuntime: (model) => model._toAckRuntime(),
  );

  static SchemaResult<Item> safeParse(Object? input) => $ack.safeParse(input);

  Map<String, dynamic> toJson() => Map<String, dynamic>.from($ack.encode(this));

  SchemaResult<Map<String, Object?>> safeToJson() => $ack.safeEncode(this);

  static Item _fromAckRuntime(Map<String, Object?> value) =>
      _$ItemFromJson(Map<String, dynamic>.from(value));

  Map<String, Object?> _toAckRuntime() => <String, Object?>{
    ..._$ItemToJson(this),
  };

  static String _ackFromRuntimeId(Object? value) => value as String;

  static Object? _ackToRuntimeId(String value) => value;
}

/// Immutable model generated from `myCustomSchema123`.
@AckType.jsonSerializable
final class MyCustomSchema123 {
  MyCustomSchema123({required this.value});

  factory MyCustomSchema123.parse(Object? input) {
    return $ack.parse(input);
  }

  factory MyCustomSchema123.fromJson(Map<String, dynamic> json) {
    return $ack.parse(json);
  }

  final String value;

  static final $ack = AckModelAdapter(
    schema: () => myCustomSchema123,
    fromRuntime: MyCustomSchema123._fromAckRuntime,
    toRuntime: (model) => model._toAckRuntime(),
  );

  static SchemaResult<MyCustomSchema123> safeParse(Object? input) =>
      $ack.safeParse(input);

  Map<String, dynamic> toJson() => Map<String, dynamic>.from($ack.encode(this));

  SchemaResult<Map<String, Object?>> safeToJson() => $ack.safeEncode(this);

  static MyCustomSchema123 _fromAckRuntime(Map<String, Object?> value) =>
      _$MyCustomSchema123FromJson(Map<String, dynamic>.from(value));

  Map<String, Object?> _toAckRuntime() => <String, Object?>{
    ..._$MyCustomSchema123ToJson(this),
  };

  static String _ackFromRuntimeValue(Object? value) => value as String;

  static Object? _ackToRuntimeValue(String value) => value;
}
