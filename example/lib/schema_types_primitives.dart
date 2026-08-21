import 'package:ack/ack.dart';
import 'package:ack_annotations/ack_annotations.dart';

part 'schema_types_primitives.ack.dart';

// Primitive schemas generate immutable value models while the schema remains
// available directly for parse() and safeParse().

/// Test primitive schema types with @AckType

/// Test enums for enumValues schema
enum UserRole { admin, user, guest }

enum Status { active, inactive, pending }

// String schema
@AckType()
final passwordSchema = Ack.string().minLength(8);

// Integer schema
@AckType()
final ageSchema = Ack.integer().min(0).max(150);

// Double schema
@AckType()
final priceSchema = Ack.double().min(0);

// Boolean schema
@AckType()
final activeSchema = Ack.boolean();

// List schema
@AckType()
final tagsSchema = Ack.list(Ack.string());

// List of integers
@AckType()
final scoresSchema = Ack.list(Ack.integer());

// Literal schema
@AckType(name: 'StatusLiteral')
final statusSchema = Ack.literal('active');

// String enum schema
@AckType()
final roleSchema = Ack.enumString(['admin', 'user', 'guest']);

// EnumValues schemas
@AckType(name: 'UserRoleModel')
final userRoleSchema = Ack.enumValues(UserRole.values);

@AckType()
final statusEnumSchema = Ack.enumValues(Status.values);

// Method chaining tests for new schema types
@AckType()
final optionalStatusSchema = Ack.literal('active').optional();

final nullableRoleSchema = Ack.enumString(['admin', 'user']).nullable();

@AckType()
final defaultedEnumSchema = Ack.enumValues(
  UserRole.values,
).withDefault(UserRole.guest);

final optionalNullableLiteralSchema = Ack.literal(
  'pending',
).optional().nullable();

@AckType()
final chainedEnumStringSchema = Ack.enumString([
  'read',
  'write',
  'execute',
]).withDefault('read');

// Test refine - this should work
@AckType()
final refinedAgeSchema = Ack.integer()
    .min(0)
    .refine((age) => age < 150, message: 'Age must be less than 150');
