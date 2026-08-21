// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'schema_types_edge_cases.dart';

// **************************************************************************
// AckSchemaGenerator
// **************************************************************************

/// Immutable model generated from `productSchema`.
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

  static Product _fromAckRuntime(Map<String, Object?> value) {
    return Product(
      name: value['name'] as String,
      tags: List<String>.unmodifiable(
        (value['tags'] as List).map((item) => item as String),
      ),
      scores: List<int>.unmodifiable(
        (value['scores'] as List).map((item) => item as int),
      ),
      flags: List<bool>.unmodifiable(
        (value['flags'] as List).map((item) => item as bool),
      ),
    );
  }

  Map<String, Object?> _toAckRuntime() {
    return <String, Object?>{
      'name': name,
      'tags': tags.map((item) => item).toList(growable: false),
      'scores': scores.map((item) => item).toList(growable: false),
      'flags': flags.map((item) => item).toList(growable: false),
    };
  }
}

/// Immutable model generated from `gridSchema`.
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

  static Grid _fromAckRuntime(Map<String, Object?> value) {
    return Grid(
      name: value['name'] as String,
      matrix: List<List<int>>.unmodifiable(
        (value['matrix'] as List).map(
          (item) =>
              List<int>.unmodifiable((item as List).map((item) => item as int)),
        ),
      ),
    );
  }

  Map<String, Object?> _toAckRuntime() {
    return <String, Object?>{
      'name': name,
      'matrix': matrix
          .map((item) => item.map((item) => item).toList(growable: false))
          .toList(growable: false),
    };
  }
}

/// Immutable model generated from `addressSchema`.
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

  static Address _fromAckRuntime(Map<String, Object?> value) {
    return Address(
      street: value['street'] as String,
      city: value['city'] as String,
      zipCode: value['zipCode'] as String,
      country: value['country'] as String,
    );
  }

  Map<String, Object?> _toAckRuntime() {
    return <String, Object?>{
      'street': street,
      'city': city,
      'zipCode': zipCode,
      'country': country,
    };
  }
}

/// Immutable model generated from `personSchema`.
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

  static Person _fromAckRuntime(Map<String, Object?> value) {
    return Person(
      name: value['name'] as String,
      email: value['email'] as String,
      address: Address.$ack.fromRuntime(
        value['address'] as Map<String, Object?>,
      ),
      age: value['age'] as int,
    );
  }

  Map<String, Object?> _toAckRuntime() {
    return <String, Object?>{
      'name': name,
      'email': email,
      'address': Address.$ack.toRuntime(address),
      'age': age,
    };
  }
}

/// Immutable model generated from `employeeSchema`.
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

  static Employee _fromAckRuntime(Map<String, Object?> value) {
    return Employee(
      name: value['name'] as String,
      employeeId: value['employeeId'] as String,
      homeAddress: Address.$ack.fromRuntime(
        value['homeAddress'] as Map<String, Object?>,
      ),
      workAddress: Address.$ack.fromRuntime(
        value['workAddress'] as Map<String, Object?>,
      ),
    );
  }

  Map<String, Object?> _toAckRuntime() {
    return <String, Object?>{
      'name': name,
      'employeeId': employeeId,
      'homeAddress': Address.$ack.toRuntime(homeAddress),
      'workAddress': Address.$ack.toRuntime(workAddress),
    };
  }
}

/// Immutable model generated from `modifierSchema`.
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

  static Modifier _fromAckRuntime(Map<String, Object?> value) {
    return Modifier(
      requiredField: value['requiredField'] as String,
      optionalField: value['optionalField'] as String?,
      nullableField: value['nullableField'] as String?,
      optionalNullable: value['optionalNullable'] as String?,
      nullableOptional: value['nullableOptional'] as String?,
    );
  }

  Map<String, Object?> _toAckRuntime() {
    return <String, Object?>{
      'requiredField': requiredField,
      if (optionalField != null) 'optionalField': optionalField!,
      'nullableField': nullableField,
      if (optionalNullable != null) 'optionalNullable': optionalNullable!,
      if (nullableOptional != null) 'nullableOptional': nullableOptional!,
    };
  }
}

/// Immutable model generated from `taggedItemSchema`.
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

  static TaggedItem _fromAckRuntime(Map<String, Object?> value) {
    return TaggedItem(
      name: value['name'] as String,
      requiredTags: List<String>.unmodifiable(
        (value['requiredTags'] as List).map((item) => item as String),
      ),
      optionalTags: switch (value['optionalTags']) {
        null => null,
        final fieldValue => List<String>.unmodifiable(
          (fieldValue as List).map((item) => item as String),
        ),
      },
      nullableTags: switch (value['nullableTags']) {
        null => null,
        final fieldValue => List<String>.unmodifiable(
          (fieldValue as List).map((item) => item as String),
        ),
      },
    );
  }

  Map<String, Object?> _toAckRuntime() {
    return <String, Object?>{
      'name': name,
      'requiredTags': requiredTags.map((item) => item).toList(growable: false),
      if (optionalTags != null)
        'optionalTags': optionalTags!
            .map((item) => item)
            .toList(growable: false),
      'nullableTags': switch (nullableTags) {
        null => null,
        final fieldValue =>
          fieldValue.map((item) => item).toList(growable: false),
      },
    };
  }
}

/// Immutable model generated from `contactListSchema`.
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

  static ContactList _fromAckRuntime(Map<String, Object?> value) {
    return ContactList(
      name: value['name'] as String,
      addresses: List<Address>.unmodifiable(
        (value['addresses'] as List).map(
          (item) => Address.$ack.fromRuntime(item as Map<String, Object?>),
        ),
      ),
    );
  }

  Map<String, Object?> _toAckRuntime() {
    return <String, Object?>{
      'name': name,
      'addresses': addresses
          .map((item) => Address.$ack.toRuntime(item))
          .toList(growable: false),
    };
  }
}

/// Immutable model generated from `emptySchema`.
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

  static Empty _fromAckRuntime(Map<String, Object?> value) {
    return Empty();
  }

  Map<String, Object?> _toAckRuntime() {
    return <String, Object?>{};
  }
}

/// Immutable model generated from `minimalSchema`.
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

  static Minimal _fromAckRuntime(Map<String, Object?> value) {
    return Minimal(id: value['id'] as String);
  }

  Map<String, Object?> _toAckRuntime() {
    return <String, Object?>{'id': id};
  }
}

/// Immutable model generated from `namedItemSchema`.
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

  static NamedItem _fromAckRuntime(Map<String, Object?> value) {
    return NamedItem(name: value['name'] as String);
  }

  Map<String, Object?> _toAckRuntime() {
    return <String, Object?>{'name': name};
  }
}

/// Immutable model generated from `item`.
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

  static Item _fromAckRuntime(Map<String, Object?> value) {
    return Item(id: value['id'] as String);
  }

  Map<String, Object?> _toAckRuntime() {
    return <String, Object?>{'id': id};
  }
}

/// Immutable model generated from `myCustomSchema123`.
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

  static MyCustomSchema123 _fromAckRuntime(Map<String, Object?> value) {
    return MyCustomSchema123(value: value['value'] as String);
  }

  Map<String, Object?> _toAckRuntime() {
    return <String, Object?>{'value': value};
  }
}
