# Ack Example Package

This package demonstrates both code-generation directions: schemas converted
to immutable models with `@AckType()`, and hand-written classes converted to
codec schemas with `@AckModel()`. Annotated examples declare both `.ack.dart`
and `.g.dart` parts.

## Included examples

- Primitive typed schemas in `lib/schema_types_primitives.dart`
- Object schemas in `lib/schema_types_simple.dart`
- Discriminated schemas in `lib/schema_types_discriminated.dart`
- Built-in and custom codec schemas in `lib/schema_types_transforms.dart`
- Edge cases and strict resolution in `lib/schema_types_edge_cases.dart`
- Cross-schema object models in `lib/pet.dart`, `lib/user_with_color.dart`,
  and `lib/additional_properties_example.dart`
- Codecs (built-in and custom) in `lib/codecs_example.dart`
- Hand-written class-first models and sealed unions in
  `lib/class_first_models.dart`

## Running the examples

```bash
dart run melos bootstrap
cd example
dart run build_runner build
dart test
```
