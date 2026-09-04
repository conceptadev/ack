import 'package:meta/meta_meta.dart';

/// Adds `.min(value)` to an inferred numeric schema.
@Target({TargetKind.field})
final class Min {
  const Min(this.value);

  final num value;
}

/// Adds `.max(value)` to an inferred numeric schema.
@Target({TargetKind.field})
final class Max {
  const Max(this.value);

  final num value;
}

/// Adds `.multipleOf(value)` to an inferred numeric schema.
@Target({TargetKind.field})
final class MultipleOf {
  const MultipleOf(this.value);

  final num value;
}

/// Adds `.positive()` to an inferred numeric schema.
@Target({TargetKind.field})
final class Positive {
  const Positive();
}

/// Adds `.negative()` to an inferred numeric schema.
@Target({TargetKind.field})
final class Negative {
  const Negative();
}

/// Adds `.minLength(length)` to an inferred string schema.
@Target({TargetKind.field})
final class MinLength {
  const MinLength(this.length);

  final int length;
}

/// Adds `.maxLength(length)` to an inferred string schema.
@Target({TargetKind.field})
final class MaxLength {
  const MaxLength(this.length);

  final int length;
}

/// Adds `.matches(pattern)` to an inferred string schema.
@Target({TargetKind.field})
final class Pattern {
  const Pattern(this.pattern);

  final String pattern;
}

/// Adds `.email()` to an inferred string schema.
@Target({TargetKind.field})
final class Email {
  const Email();
}

/// Adds `.notEmpty()` to an inferred string schema.
@Target({TargetKind.field})
final class NotEmpty {
  const NotEmpty();
}

/// Adds `.minItems(count)` to an inferred collection schema.
@Target({TargetKind.field})
final class MinItems {
  const MinItems(this.count);

  final int count;
}

/// Adds `.maxItems(count)` to an inferred collection schema.
@Target({TargetKind.field})
final class MaxItems {
  const MaxItems(this.count);

  final int count;
}

/// Adds `.unique()` to an inferred collection schema.
@Target({TargetKind.field})
final class UniqueItems {
  const UniqueItems();
}
