# Ack Example Package

This package demonstrates Ack schemas built directly in source and converted to
immutable models with `@AckType()`.

## Included examples

- Primitive typed schemas in `lib/schema_types_primitives.dart`
- Object schemas in `lib/schema_types_simple.dart`
- Discriminated schemas in `lib/schema_types_discriminated.dart`
- Built-in and custom codec schemas in `lib/schema_types_transforms.dart`
- Edge cases and strict resolution in `lib/schema_types_edge_cases.dart`
- Cross-schema object models in `lib/pet.dart`, `lib/user_with_color.dart`,
  and `lib/args_getter_example.dart`
- Codecs (built-in and custom) in `lib/codecs_example.dart`

## Running the examples

```bash
dart run melos bootstrap
cd example
dart run build_runner build
dart test
```
