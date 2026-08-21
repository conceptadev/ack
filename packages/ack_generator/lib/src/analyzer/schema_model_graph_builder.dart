import 'package:ack_annotations/ack_annotations.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';

import '../models/schema_model_graph.dart';

final class _Declaration {
  const _Declaration({
    required this.element,
    required this.expression,
    required this.id,
    required this.className,
  });

  final Element element;
  final Expression expression;
  final AckSchemaId id;
  final String className;
}

final class _SchemaChain {
  const _SchemaChain({
    required this.base,
    required this.reference,
    required this.optional,
    required this.nullable,
    required this.defaulted,
    required this.hasTransform,
    required this.hasCodec,
  });

  final MethodInvocation? base;
  final Expression? reference;
  final bool optional;
  final bool nullable;
  final bool defaulted;
  final bool hasTransform;
  final bool hasCodec;
}

typedef _SchemaTypes = ({AckTypeRef boundary, AckTypeRef runtime});

/// Builds the single normalized graph consumed by Ack model emission.
final class SchemaModelGraphBuilder {
  SchemaModelGraphBuilder(this.library);

  static const _reservedMembers = {
    r'$ack',
    'parse',
    'safeParse',
    'fromJson',
    'toJson',
    'safeToJson',
    '_fromAckRuntime',
    '_toAckRuntime',
    'hashCode',
    'noSuchMethod',
    'toString',
    'runtimeType',
  };

  static const _dartKeywords = {
    'abstract',
    'as',
    'assert',
    'async',
    'await',
    'base',
    'break',
    'case',
    'catch',
    'class',
    'const',
    'continue',
    'covariant',
    'default',
    'deferred',
    'do',
    'dynamic',
    'else',
    'enum',
    'export',
    'extends',
    'extension',
    'external',
    'factory',
    'false',
    'final',
    'finally',
    'for',
    'get',
    'hide',
    'if',
    'implements',
    'import',
    'in',
    'interface',
    'is',
    'late',
    'library',
    'mixin',
    'new',
    'null',
    'of',
    'on',
    'operator',
    'part',
    'required',
    'rethrow',
    'return',
    'sealed',
    'set',
    'show',
    'static',
    'super',
    'switch',
    'sync',
    'this',
    'throw',
    'true',
    'try',
    'typedef',
    'var',
    'void',
    'when',
    'while',
    'with',
    'yield',
  };

  static const _generatedHelperNames = {
    '_ackImmutableCopyValue',
    '_ackImmutableCopyMap',
  };

  final LibraryReader library;
  final AckModelGraph _graph = AckModelGraph();
  final Map<Element, _Declaration> _declarationsByElement = {};
  final Map<AckSchemaId, _Declaration> _declarationsById = {};
  final Map<AckSchemaId, AckSchemaId> _unionOwnerByBranch = {};

  Future<AckModelGraph> build(List<Element> annotatedElements) async {
    final libraryElement = library.element;
    final resolved = await libraryElement.session.getResolvedLibraryByElement(
      libraryElement,
    );
    if (resolved is! ResolvedLibraryResult) {
      throw InvalidGenerationSource(
        'Could not resolve ${libraryElement.uri} for Ack model generation.',
      );
    }

    for (final element in annotatedElements) {
      final expression = _declarationExpression(resolved, element);
      final declarationName = element.name;
      if (declarationName == null || expression == null) {
        throw InvalidGenerationSource(
          'Could not resolve the schema expression for ${element.displayName}.',
          element: element,
        );
      }
      final id = AckSchemaId(
        libraryUri: libraryElement.uri,
        declarationName: declarationName,
      );
      final declaration = _Declaration(
        element: element,
        expression: expression,
        id: id,
        className: _className(
          declarationName,
          _annotationName(element),
          element,
        ),
      );
      _registerElement(element, declaration);
      _declarationsById[id] = declaration;
    }

    _validateClassNames();
    for (final declaration in _declarationsById.values) {
      await _resolve(
        declaration,
        throughLazy: false,
        path: declaration.id.declarationName,
      );
    }
    _validateGeneratedHelperNames();
    return _graph;
  }

  void _registerElement(Element element, _Declaration declaration) {
    _declarationsByElement[element.baseElement] = declaration;
    _declarationsByElement[element] = declaration;
    if (element is TopLevelVariableElement) {
      final getter = element.getter;
      if (getter != null) {
        _declarationsByElement[getter.baseElement] = declaration;
      }
    } else if (element is GetterElement) {
      _declarationsByElement[element.variable.baseElement] = declaration;
    }
  }

  Expression? _declarationExpression(
    ResolvedLibraryResult result,
    Element element,
  ) {
    final declaration = result.getFragmentDeclaration(element.firstFragment);
    final node = declaration?.node;
    if (node is VariableDeclaration) return node.initializer;
    if (node is FunctionDeclaration && node.isGetter) {
      final body = node.functionExpression.body;
      if (body is ExpressionFunctionBody) return body.expression;
      if (body is BlockFunctionBody && body.block.statements.length == 1) {
        final statement = body.block.statements.single;
        if (statement is ReturnStatement) return statement.expression;
      }
    }
    return null;
  }

  Future<void> _resolve(
    _Declaration declaration, {
    required bool throughLazy,
    required String path,
  }) async {
    switch (_graph.stateOf(declaration.id)) {
      case AckResolutionState.resolved:
        return;
      case AckResolutionState.visiting:
        if (throughLazy) return;
        throw InvalidGenerationSource(
          'Ordinary schema alias cycle detected at $path. Recursive model '
          'edges must use named Ack.lazy(...).',
          element: declaration.element,
        );
      case AckResolutionState.unseen:
        break;
    }

    _graph.begin(declaration.id);
    final chain = _chain(declaration.expression);
    _rejectTransform(chain, path, declaration.element);
    if (chain.nullable) {
      throw InvalidGenerationSource(
        '$path is a nullable root. Generated Ack models are non-nullable.',
        element: declaration.element,
        todo: 'Remove .nullable() from the annotated root schema.',
      );
    }

    final baseName = chain.base?.methodName.name;
    final AckModelNode node;
    if (chain.hasCodec) {
      node = await _valueNode(declaration, path);
    } else if (baseName == 'object') {
      node = await _objectNode(declaration, chain, path);
    } else if (baseName == 'discriminated') {
      node = await _unionNode(declaration, chain, path);
    } else if (chain.reference != null) {
      node = await _aliasNode(declaration, chain.reference!, path);
    } else {
      const supportedValueRoots = {
        'string',
        'integer',
        'double',
        'number',
        'boolean',
        'list',
        'literal',
        'enumString',
        'enumValues',
        'uri',
        'date',
        'datetime',
        'duration',
        'codec',
        'lazy',
      };
      if (!supportedValueRoots.contains(baseName)) {
        _rejectUnsupportedRoot(baseName, path, declaration.element);
      }
      node = await _valueNode(declaration, path);
    }
    _graph.complete(node);
  }

  Future<AckValueModelNode> _valueNode(
    _Declaration declaration,
    String path,
  ) async {
    final expression = declaration.expression;
    final types = _schemaTypes(expression, path, declaration.element);
    return AckValueModelNode(
      id: declaration.id,
      className: declaration.className,
      boundaryType: types.boundary,
      runtimeRef: await _runtimeRefForSchema(
        expression,
        path: path,
        context: declaration.element,
        throughLazy: false,
      ),
      encodeCapability: AckEncodeCapability.bidirectional,
      sourceLocation: _location(declaration.element),
      description: _description(expression),
    );
  }

  Future<AckModelNode> _aliasNode(
    _Declaration declaration,
    Expression reference,
    String path,
  ) async {
    final target = _localDeclaration(reference);
    if (target == null) {
      throw InvalidGenerationSource(
        '$path is an unresolvable dynamic schema alias.',
        element: declaration.element,
      );
    }
    await _resolve(
      target,
      throughLazy: false,
      path: '$path -> ${target.id.declarationName}',
    );
    final source = _graph.nodeFor(target.id)!;
    if (source is AckObjectModelNode) {
      return AckObjectModelNode(
        id: declaration.id,
        className: declaration.className,
        boundaryType: source.boundaryType,
        runtimeRef: source.runtimeRef,
        encodeCapability: source.encodeCapability,
        sourceLocation: _location(declaration.element),
        fields: source.fields,
        additionalProperties: source.additionalProperties,
        description: source.description,
      );
    }
    if (source is AckUnionModelNode) {
      throw InvalidGenerationSource(
        '$path aliases a discriminated union. Annotate and use the original '
        'union model directly.',
        element: declaration.element,
      );
    }
    return AckValueModelNode(
      id: declaration.id,
      className: declaration.className,
      boundaryType: source.boundaryType,
      runtimeRef: source.runtimeRef,
      encodeCapability: source.encodeCapability,
      sourceLocation: _location(declaration.element),
      description: source.description,
    );
  }

  Future<AckObjectModelNode> _objectNode(
    _Declaration declaration,
    _SchemaChain chain,
    String path,
  ) async {
    final invocation = chain.base!;
    final arguments = _argumentExpressions(invocation.argumentList);
    if (arguments.isEmpty || arguments.first is! SetOrMapLiteral) {
      throw InvalidGenerationSource(
        '$path must use a map literal in Ack.object(...).',
        element: declaration.element,
      );
    }
    final literal = arguments.first as SetOrMapLiteral;
    final additionalProperties = _additionalProperties(declaration.expression);
    final fields = <AckFieldNode>[];
    for (final entry in literal.elements) {
      if (entry is! MapLiteralEntry || entry.key is! SimpleStringLiteral) {
        throw InvalidGenerationSource(
          '$path object keys must be string literals.',
          element: declaration.element,
        );
      }
      final jsonKey = (entry.key as SimpleStringLiteral).value;
      if (!RegExp(r'^[A-Za-z_$][A-Za-z0-9_$]*$').hasMatch(jsonKey) ||
          _dartKeywords.contains(jsonKey)) {
        throw InvalidGenerationSource(
          '$path.$jsonKey cannot be represented as a Dart field name.',
          element: declaration.element,
        );
      }
      if (_reservedMembers.contains(jsonKey)) {
        throw InvalidGenerationSource(
          '$path.$jsonKey conflicts with generated/Object member "$jsonKey".',
          element: declaration.element,
        );
      }
      if (additionalProperties && jsonKey == 'additionalProperties') {
        throw InvalidGenerationSource(
          '$path.$jsonKey conflicts with the generated additional-properties '
          'member.',
          element: declaration.element,
        );
      }
      final fieldPath = '$path.$jsonKey';
      final fieldChain = _chain(entry.value);
      _rejectTransform(fieldChain, fieldPath, declaration.element);
      if (fieldChain.base?.methodName.name == 'object') {
        throw InvalidGenerationSource(
          '$fieldPath uses an anonymous inline Ack.object(...).',
          element: declaration.element,
          todo: 'Extract it to a named @AckType schema declaration.',
        );
      }
      fields.add(
        AckFieldNode(
          dartName: jsonKey,
          jsonKey: jsonKey,
          presence: _fieldPresence(fieldChain),
          nullable: fieldChain.nullable,
          runtimeRef: await _runtimeRefForSchema(
            entry.value,
            path: fieldPath,
            context: declaration.element,
            throughLazy: false,
          ),
          description: _description(entry.value),
        ),
      );
    }
    final types = _schemaTypes(
      declaration.expression,
      path,
      declaration.element,
    );
    return AckObjectModelNode(
      id: declaration.id,
      className: declaration.className,
      boundaryType: types.boundary,
      runtimeRef: types.runtime,
      encodeCapability: AckEncodeCapability.bidirectional,
      sourceLocation: _location(declaration.element),
      fields: fields,
      additionalProperties: additionalProperties,
      description: _description(declaration.expression),
    );
  }

  Future<AckUnionModelNode> _unionNode(
    _Declaration declaration,
    _SchemaChain chain,
    String path,
  ) async {
    String? discriminatorKey;
    SetOrMapLiteral? branchesLiteral;
    for (final argumentNode in chain.base!.argumentList.arguments) {
      final argument = _namedArgument(argumentNode);
      if (argument == null) continue;
      switch (argument.name) {
        case 'discriminatorKey':
          final value = argument.expression;
          if (value is SimpleStringLiteral) discriminatorKey = value.value;
        case 'schemas':
          final value = argument.expression;
          if (value is SetOrMapLiteral) branchesLiteral = value;
      }
    }
    if (discriminatorKey == null || branchesLiteral == null) {
      throw InvalidGenerationSource(
        '$path must provide literal discriminatorKey and schemas arguments.',
        element: declaration.element,
      );
    }
    if (_reservedMembers.contains(discriminatorKey) ||
        _dartKeywords.contains(discriminatorKey) ||
        discriminatorKey == 'additionalProperties') {
      throw InvalidGenerationSource(
        '$path.$discriminatorKey conflicts with a generated member or Dart '
        'keyword.',
        element: declaration.element,
      );
    }

    final branches = <String, AckSchemaId>{};
    for (final element in branchesLiteral.elements) {
      if (element is! MapLiteralEntry || element.key is! SimpleStringLiteral) {
        throw InvalidGenerationSource(
          '$path discriminated branches must be a string-keyed map literal.',
          element: declaration.element,
        );
      }
      final value = (element.key as SimpleStringLiteral).value;
      final target = _localDeclaration(element.value);
      if (target == null) {
        throw InvalidGenerationSource(
          '$path.$value is a cross-library or unresolvable discriminated branch.',
          element: declaration.element,
        );
      }
      _validateUnionBranchDiscriminator(target, discriminatorKey, value);
      await _resolve(target, throughLazy: false, path: '$path.$value');
      final branch = _graph.nodeFor(target.id);
      if (branch is! AckObjectModelNode) {
        throw InvalidGenerationSource(
          '$path.$value must reference an @AckType object schema.',
          element: declaration.element,
        );
      }
      final owner = _unionOwnerByBranch[target.id];
      if (owner != null && owner != declaration.id) {
        throw InvalidGenerationSource(
          '${target.id.declarationName} belongs to multiple discriminated unions.',
          element: declaration.element,
        );
      }
      _unionOwnerByBranch[target.id] = declaration.id;
      _graph.replace(
        AckObjectModelNode(
          id: branch.id,
          className: branch.className,
          boundaryType: branch.boundaryType,
          runtimeRef: branch.runtimeRef,
          encodeCapability: branch.encodeCapability,
          sourceLocation: branch.sourceLocation,
          fields: branch.fields,
          additionalProperties: branch.additionalProperties,
          unionId: declaration.id,
          discriminatorKey: discriminatorKey,
          discriminatorValue: value,
          description: branch.description,
        ),
      );
      branches[value] = target.id;
    }
    if (branches.isEmpty) {
      throw InvalidGenerationSource(
        '$path must declare at least one discriminated branch.',
        element: declaration.element,
      );
    }
    final types = _schemaTypes(
      declaration.expression,
      path,
      declaration.element,
    );
    return AckUnionModelNode(
      id: declaration.id,
      className: declaration.className,
      boundaryType: types.boundary,
      runtimeRef: types.runtime,
      encodeCapability: AckEncodeCapability.bidirectional,
      sourceLocation: _location(declaration.element),
      discriminatorKey: discriminatorKey,
      branches: branches,
      description: _description(declaration.expression),
    );
  }

  Future<AckTypeRef> _runtimeRefForSchema(
    Expression expression, {
    required String path,
    required Element context,
    required bool throughLazy,
  }) async {
    final chain = _chain(expression);
    _rejectTransform(chain, path, context);
    if (chain.hasCodec) {
      return _schemaTypes(expression, path, context).runtime;
    }
    final baseName = chain.base?.methodName.name;
    switch (baseName) {
      case 'object':
        throw InvalidGenerationSource(
          '$path uses an anonymous inline Ack.object(...).',
          element: context,
        );
      case 'any':
      case 'anyOf':
      case 'instance':
        _rejectUnsupportedRoot(baseName, path, context);
      case 'list':
        final arguments = _argumentExpressions(chain.base!.argumentList);
        if (arguments.isEmpty) {
          throw InvalidGenerationSource(
            '$path has an empty Ack.list().',
            element: context,
          );
        }
        return AckListTypeRef(
          await _runtimeRefForSchema(
            arguments.first,
            path: '$path[]',
            context: context,
            throughLazy: throughLazy,
          ),
        );
      case 'enumValues':
        final arguments = _argumentExpressions(chain.base!.argumentList);
        final valuesType = arguments.firstOrNull?.staticType;
        if (valuesType is InterfaceType &&
            valuesType.isDartCoreList &&
            valuesType.typeArguments.length == 1) {
          return _typeRef(valuesType.typeArguments.single, context);
        }
        throw InvalidGenerationSource(
          '$path Ack.enumValues(...) enum type is not statically resolvable.',
          element: context,
        );
      case 'lazy':
        return _lazyType(chain.base!, path, context);
      case 'discriminated':
        throw InvalidGenerationSource(
          '$path uses an anonymous discriminated union.',
          element: context,
        );
    }

    final reference = chain.reference;
    if (reference != null) {
      final model = await _modelReference(
        reference,
        path: path,
        context: context,
        throughLazy: throughLazy,
      );
      if (model != null) return model;
    }
    return _schemaTypes(expression, path, context).runtime;
  }

  Future<AckTypeRef> _lazyType(
    MethodInvocation invocation,
    String path,
    Element context,
  ) async {
    final arguments = _argumentExpressions(invocation.argumentList);
    if (arguments.length < 2 || arguments.first is! SimpleStringLiteral) {
      throw InvalidGenerationSource(
        '$path must use named Ack.lazy(name, () => schema) recursion.',
        element: context,
      );
    }
    final callback = arguments[1];
    if (callback is! FunctionExpression) {
      throw InvalidGenerationSource(
        '$path Ack.lazy builder must be a closure.',
        element: context,
      );
    }
    final body = callback.body;
    Expression? target;
    if (body is ExpressionFunctionBody) target = body.expression;
    if (body is BlockFunctionBody && body.block.statements.length == 1) {
      final statement = body.block.statements.single;
      if (statement is ReturnStatement) target = statement.expression;
    }
    if (target == null) {
      throw InvalidGenerationSource(
        '$path Ack.lazy builder is not statically resolvable.',
        element: context,
      );
    }
    final model = await _modelReference(
      target,
      path: path,
      context: context,
      throughLazy: true,
    );
    if (model == null) {
      throw InvalidGenerationSource(
        '$path Ack.lazy must resolve to a named @AckType schema.',
        element: context,
      );
    }
    return model;
  }

  Future<AckModelTypeRef?> _modelReference(
    Expression expression, {
    required String path,
    required Element context,
    required bool throughLazy,
  }) async {
    final element = _referencedElement(expression);
    if (element == null) return null;
    final local = _declarationsByElement[element.baseElement];
    if (local != null) {
      await _resolve(local, throughLazy: throughLazy, path: path);
      final runtime = _schemaTypes(
        local.expression,
        path,
        local.element,
      ).runtime;
      return AckModelTypeRef(
        schemaId: local.id,
        className: local.className,
        runtimeRef: runtime,
      );
    }
    if (!_hasAckType(element)) return null;
    final declaration = _propertyDeclaration(element);
    final name = declaration.name;
    final owningLibrary = declaration.library;
    if (name == null || owningLibrary == null) return null;
    return AckModelTypeRef(
      schemaId: AckSchemaId(
        libraryUri: owningLibrary.uri,
        declarationName: name,
      ),
      className: _className(name, _annotationName(declaration), declaration),
      runtimeRef: _schemaTypes(expression, path, context).runtime,
      importPrefix: _expressionPrefix(expression),
    );
  }

  _SchemaTypes _schemaTypes(
    Expression expression,
    String path,
    Element context,
  ) {
    final type = expression.staticType;
    if (type is! InterfaceType) {
      throw InvalidGenerationSource(
        '$path has no resolvable AckSchema<Boundary, Runtime> type.',
        element: context,
      );
    }
    final InterfaceElement? ackElement = _isAckSchema(type)
        ? type.element
        : type.element.allSupertypes.where(_isAckSchema).firstOrNull?.element;
    final ackType = ackElement == null ? null : type.asInstanceOf(ackElement);
    if (ackType == null || ackType.typeArguments.length != 2) {
      throw InvalidGenerationSource(
        '$path does not resolve to AckSchema<Boundary, Runtime>.',
        element: context,
      );
    }
    return (
      boundary: _typeRef(ackType.typeArguments[0], context),
      runtime: _typeRef(ackType.typeArguments[1], context),
    );
  }

  bool _isAckSchema(InterfaceType type) {
    return type.element.name == 'AckSchema' &&
        type.element.library.uri.toString() ==
            'package:ack/src/schemas/schema.dart';
  }

  AckTypeRef _typeRef(DartType type, Element context) {
    if (type is DynamicType) {
      return const AckNullableTypeRef(AckScalarTypeRef('Object'));
    }
    if (type is TypeParameterType) {
      return AckExternalTypeRef(
        name: type.element.name ?? 'Object',
        libraryUri: context.library?.uri ?? Uri.parse('dart:core'),
      );
    }
    if (type is! InterfaceType) {
      throw InvalidGenerationSource(
        'Unsupported runtime type ${type.getDisplayString()}.',
        element: context,
      );
    }
    final nullable = type.nullabilitySuffix == NullabilitySuffix.question;
    final name = type.element.name ?? type.getDisplayString();
    AckTypeRef result;
    if (type.isDartCoreList && type.typeArguments.length == 1) {
      result = AckListTypeRef(_typeRef(type.typeArguments.single, context));
    } else if (type.isDartCoreSet && type.typeArguments.length == 1) {
      result = AckSetTypeRef(_typeRef(type.typeArguments.single, context));
    } else if (type.isDartCoreMap && type.typeArguments.length == 2) {
      result = AckMapTypeRef(_typeRef(type.typeArguments[1], context));
    } else if (type.element.library.uri.toString() == 'dart:core' &&
        const {
          'String',
          'int',
          'double',
          'num',
          'bool',
          'Object',
        }.contains(name)) {
      result = AckScalarTypeRef(name);
    } else {
      final owner = type.element.library.uri;
      result = AckExternalTypeRef(
        name: name,
        libraryUri: owner,
        importPrefix: _visiblePrefix(owner),
        typeArguments: [
          for (final argument in type.typeArguments)
            _typeRef(argument, context),
        ],
      );
    }
    return nullable ? AckNullableTypeRef(result) : result;
  }

  String? _visiblePrefix(Uri target) {
    for (final import in library.element.firstFragment.libraryImports) {
      if (import.importedLibrary?.uri != target) continue;
      return import.prefix?.element.name;
    }
    return null;
  }

  _SchemaChain _chain(Expression expression) {
    if (expression is! MethodInvocation) {
      return _SchemaChain(
        base: null,
        reference: expression,
        optional: false,
        nullable: false,
        defaulted: false,
        hasTransform: false,
        hasCodec: false,
      );
    }
    MethodInvocation? current = expression;
    MethodInvocation? base;
    Expression? reference;
    var optional = false;
    var nullable = false;
    var defaulted = false;
    var transform = false;
    var codec = false;
    while (current != null) {
      final name = current.methodName.name;
      optional |= name == 'optional';
      nullable |= name == 'nullable';
      defaulted |= name == 'withDefault';
      transform |= name == 'transform';
      codec |= name == 'codec';
      final target = current.target;
      if (_isAckTarget(target)) {
        base = current;
        break;
      }
      if (target is MethodInvocation) {
        current = target;
      } else {
        reference = target;
        break;
      }
    }
    return _SchemaChain(
      base: base,
      reference: reference,
      optional: optional,
      nullable: nullable,
      defaulted: defaulted,
      hasTransform: transform,
      hasCodec: codec,
    );
  }

  bool _isAckTarget(Expression? expression) {
    if (expression is SimpleIdentifier) return expression.name == 'Ack';
    if (expression is PrefixedIdentifier) {
      return expression.identifier.name == 'Ack';
    }
    return false;
  }

  Element? _referencedElement(Expression expression) {
    if (expression is SimpleIdentifier) {
      final element = expression.element;
      return element == null ? null : _propertyDeclaration(element);
    }
    if (expression is PrefixedIdentifier) {
      final element = expression.identifier.element;
      return element == null ? null : _propertyDeclaration(element);
    }
    if (expression is MethodInvocation) {
      final chain = _chain(expression);
      final reference = chain.reference;
      return reference == null ? null : _referencedElement(reference);
    }
    return null;
  }

  Element _propertyDeclaration(Element element) {
    if (element is GetterElement && element.isOriginVariable) {
      return element.variable.baseElement;
    }
    return element.baseElement;
  }

  _Declaration? _localDeclaration(Expression expression) {
    final element = _referencedElement(expression);
    return element == null ? null : _declarationsByElement[element.baseElement];
  }

  String? _expressionPrefix(Expression expression) {
    if (expression is PrefixedIdentifier) return expression.prefix.name;
    if (expression is MethodInvocation && expression.target != null) {
      return _expressionPrefix(expression.target!);
    }
    return null;
  }

  bool _hasAckType(Element element) {
    return TypeChecker.typeNamed(
      AckType,
    ).hasAnnotationOfExact(_propertyDeclaration(element));
  }

  String? _annotationName(Element element) {
    final annotation = TypeChecker.typeNamed(
      AckType,
    ).firstAnnotationOfExact(_propertyDeclaration(element));
    final field = annotation == null
        ? null
        : ConstantReader(annotation).peek('name');
    return field == null || field.isNull ? null : field.stringValue;
  }

  AckFieldPresence _fieldPresence(_SchemaChain chain) {
    if (chain.defaulted) return AckFieldPresence.defaulted;
    if (chain.optional) return AckFieldPresence.optional;
    return AckFieldPresence.required;
  }

  String _className(
    String declarationName,
    String? customName,
    Element element,
  ) {
    if (customName != null) {
      if (customName.trim() != customName ||
          !RegExp(r'^[A-Z][A-Za-z0-9]*$').hasMatch(customName)) {
        throw InvalidGenerationSource(
          'Invalid @AckType name "$customName". Names must be unchanged UpperCamelCase identifiers.',
          element: element,
        );
      }
      return customName;
    }
    var stem = declarationName;
    if (stem.endsWith('Schema')) {
      stem = stem.substring(0, stem.length - 'Schema'.length);
    }
    if (stem.isEmpty || !RegExp(r'^[A-Za-z][A-Za-z0-9]*$').hasMatch(stem)) {
      throw InvalidGenerationSource(
        'Cannot derive an UpperCamelCase model name from "$declarationName".',
        element: element,
      );
    }
    return '${stem[0].toUpperCase()}${stem.substring(1)}';
  }

  void _validateClassNames() {
    final generated = <String>{};
    final localNames = {
      for (final element in library.allElements)
        if (element.name case final name?) name,
    };
    for (final declaration in _declarationsById.values) {
      final name = declaration.className;
      if (!generated.add(name)) {
        throw InvalidGenerationSource(
          'Multiple @AckType declarations generate "$name".',
          element: declaration.element,
        );
      }
      if (localNames.contains(name)) {
        throw InvalidGenerationSource(
          'Generated class "$name" conflicts with a local declaration.',
          element: declaration.element,
        );
      }
      final visible = library.element.firstFragment.scope.lookup(name).getter;
      if (visible != null) {
        throw InvalidGenerationSource(
          'Generated class "$name" conflicts with a visible unprefixed import.',
          element: declaration.element,
        );
      }
    }
  }

  void _validateGeneratedHelperNames() {
    AckObjectModelNode? passthroughNode;
    for (final node in _graph.nodes.whereType<AckObjectModelNode>()) {
      if (node.additionalProperties) {
        passthroughNode = node;
        break;
      }
    }
    if (passthroughNode == null) return;

    final localNames = {
      for (final element in library.allElements)
        if (element.name case final name?) name,
    };
    for (final helperName in _generatedHelperNames) {
      if (!localNames.contains(helperName)) continue;
      throw InvalidGenerationSource(
        'Generated helper "$helperName" conflicts with a local declaration.',
        element: _declarationsById[passthroughNode.id]?.element,
      );
    }
  }

  void _validateUnionBranchDiscriminator(
    _Declaration branch,
    String discriminatorKey,
    String discriminatorValue,
  ) {
    final chain = _chain(branch.expression);
    final object = chain.base;
    if (object?.methodName.name != 'object') return;
    final arguments = _argumentExpressions(object!.argumentList);
    if (arguments.firstOrNull case SetOrMapLiteral(:final elements)) {
      for (final entry in elements.whereType<MapLiteralEntry>()) {
        final key = entry.key;
        if (key is! SimpleStringLiteral || key.value != discriminatorKey) {
          continue;
        }
        if (_matchesDiscriminator(entry.value, discriminatorValue)) return;
        throw InvalidGenerationSource(
          '${branch.id.declarationName}.$discriminatorKey must be an exact '
          'literal or enum containing "$discriminatorValue".',
          element: branch.element,
        );
      }
    }
  }

  bool _matchesDiscriminator(Expression expression, String expected) {
    final chain = _chain(expression);
    final base = chain.base;
    if (base == null || !identical(base, expression)) return false;
    final arguments = _argumentExpressions(base.argumentList);
    return switch (base.methodName.name) {
      'literal' =>
        arguments.firstOrNull is SimpleStringLiteral &&
            (arguments.first as SimpleStringLiteral).value == expected,
      'enumString' =>
        arguments.firstOrNull is ListLiteral &&
            (arguments.first as ListLiteral).elements.any(
              (element) =>
                  element is SimpleStringLiteral && element.value == expected,
            ),
      _ => false,
    };
  }

  void _rejectTransform(_SchemaChain chain, String path, Element element) {
    if (!chain.hasTransform) return;
    throw InvalidGenerationSource(
      '$path uses one-way .transform(). Migrate this path to .codec() with an encoder.',
      element: element,
    );
  }

  Never _rejectUnsupportedRoot(String? name, String path, Element element) {
    final label = switch (name) {
      'any' => 'Ack.any()',
      'anyOf' => 'Ack.anyOf()',
      'instance' => 'bare Ack.instance<T>()',
      null => 'an unresolvable dynamic schema factory',
      _ => 'Ack.$name()',
    };
    throw InvalidGenerationSource(
      '$path uses unsupported $label; it cannot provide a static model shape.',
      element: element,
    );
  }

  bool _additionalProperties(Expression expression) {
    Expression? current = expression;
    while (current is MethodInvocation) {
      if (current.methodName.name == 'passthrough') return true;
      if (current.methodName.name == 'object') {
        for (final argumentNode in current.argumentList.arguments) {
          final argument = _namedArgument(argumentNode);
          if (argument != null &&
              argument.name == 'additionalProperties' &&
              argument.expression is BooleanLiteral) {
            return (argument.expression as BooleanLiteral).value;
          }
        }
      }
      current = current.target;
    }
    return false;
  }

  String? _description(Expression expression) {
    Expression? current = expression;
    while (current is MethodInvocation) {
      final arguments = _argumentExpressions(current.argumentList);
      if (current.methodName.name == 'describe' &&
          arguments.firstOrNull is SimpleStringLiteral) {
        return (arguments.first as SimpleStringLiteral).value;
      }
      current = current.target;
    }
    return null;
  }

  /// Normalizes analyzer 10's expression arguments and analyzer 13's
  /// dedicated argument nodes into the expression API used by the graph.
  List<Expression> _argumentExpressions(ArgumentList argumentList) =>
      argumentList.arguments
          .map((argument) => _argumentExpression(argument))
          .toList(growable: false);

  Expression _argumentExpression(AstNode argument) {
    final named = _namedArgument(argument);
    if (named != null) return named.expression;
    if (argument is Expression) return argument;

    final dynamic dynamicArgument = argument;
    // Analyzer 13+ wraps positional expressions in the Argument interface.
    // ignore: avoid_dynamic_calls
    return dynamicArgument.argumentExpression as Expression;
  }

  ({String name, Expression expression})? _namedArgument(AstNode argument) {
    final dynamic dynamicArgument = argument;
    String? name;
    try {
      // Analyzer 13+ exposes a Token directly.
      // ignore: avoid_dynamic_calls
      name = dynamicArgument.name.lexeme as String?;
    } on Object {
      try {
        // Analyzer 10 exposes NamedExpression.name as a Label.
        // ignore: avoid_dynamic_calls
        name = dynamicArgument.name.label.name as String?;
      } on Object {
        return null;
      }
    }
    if (name == null) return null;

    try {
      // Analyzer 13+ uses Argument.argumentExpression.
      // ignore: avoid_dynamic_calls
      final expression = dynamicArgument.argumentExpression as Expression;
      return (name: name, expression: expression);
    } on Object {
      // Analyzer 10 uses NamedExpression.expression.
      // ignore: avoid_dynamic_calls
      final expression = dynamicArgument.expression as Expression;
      return (name: name, expression: expression);
    }
  }

  AckSourceLocation _location(Element element) {
    return AckSourceLocation(
      libraryUri: element.library?.uri ?? library.element.uri,
      offset: element.firstFragment.offset,
      length: element.name?.length ?? 0,
    );
  }
}
