/// Performs deep equality comparison between two values.
///
/// This function recursively compares:
/// - Primitives (num, String, bool, null) using standard equality
/// - Lists by comparing each element in order
/// - Maps by comparing keys and values
/// - Sets by comparing elements (order-independent)
///
/// Returns `true` if the values are structurally equal, `false` otherwise.
/// Collection wrappers do not affect equality, while different scalar types
/// remain distinct (for example, `int` and `double`).
bool deepEquals(Object? a, Object? b) {
  // Fast path: identical objects or both null
  if (identical(a, b)) return true;

  // Handle Lists
  if (a is List || b is List) {
    if (a is! List || b is! List) return false;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (!deepEquals(a[i], b[i])) return false;
    }

    return true;
  }

  // Handle Sets (order-independent comparison)
  if (a is Set || b is Set) {
    if (a is! Set || b is! Set) return false;
    if (a.length != b.length) return false;
    final unmatched = b.toList();
    for (final itemA in a) {
      var matchIndex = -1;
      for (var i = 0; i < unmatched.length; i++) {
        if (deepEquals(itemA, unmatched[i])) {
          matchIndex = i;
          break;
        }
      }
      if (matchIndex == -1) return false;
      unmatched.removeAt(matchIndex);
    }

    return true;
  }

  // Handle Maps
  if (a is Map || b is Map) {
    if (a is! Map || b is! Map) return false;
    if (a.length != b.length) return false;
    final unmatched = b.entries.toList();
    for (final entryA in a.entries) {
      var matchIndex = -1;
      for (var i = 0; i < unmatched.length; i++) {
        final entryB = unmatched[i];
        if (deepEquals(entryA.key, entryB.key) &&
            deepEquals(entryA.value, entryB.value)) {
          matchIndex = i;
          break;
        }
      }
      if (matchIndex == -1) return false;
      unmatched.removeAt(matchIndex);
    }

    return true;
  }

  // Handle other Iterables (not List or Set)
  if (a is Iterable || b is Iterable) {
    if (a is! Iterable || b is! Iterable) return false;
    final iterA = a.iterator;
    final iterB = b.iterator;
    while (iterA.moveNext()) {
      if (!iterB.moveNext()) return false;
      if (!deepEquals(iterA.current, iterB.current)) return false;
    }

    return !iterB.moveNext(); // Ensure b has no more elements
  }

  // Scalars preserve their concrete type so `1` and `1.0` stay distinct.
  if (a.runtimeType != b.runtimeType) return false;
  return a == b;
}

/// Computes a hash code for [value] that is consistent with [deepEquals].
///
/// Generated Ack models and unique-item constraints share this helper so
/// collection equality and hashing stay aligned. The function assumes acyclic
/// inputs such as JSON-derived data; cyclic structures overflow the stack.
int deepHashCode(Object? value) {
  if (value == null) return Object.hash(null, null);

  if (value is! Iterable && value is! Map) {
    return Object.hash(value.runtimeType, value);
  }

  if (value is List) {
    var hash = Object.hash('ack:list', value.length);
    for (final item in value) {
      hash = Object.hash(hash, deepHashCode(item));
    }

    return hash;
  }

  if (value is Set) {
    // Use XOR with bit mixing for order-independent hashing with better
    // collision resistance than simple sum.
    var combined = 0;
    for (final item in value) {
      final h = deepHashCode(item);
      combined ^= h ^ (h >>> 16);
    }

    return Object.hash('ack:set', value.length, combined);
  }

  if (value is Map) {
    // Use XOR with bit mixing for order-independent hashing.
    var combined = 0;
    for (final entry in value.entries) {
      final keyHash = deepHashCode(entry.key);
      final valueHash = deepHashCode(entry.value);
      final entryHash = Object.hash(keyHash, valueHash);
      combined ^= entryHash ^ (entryHash >>> 16);
    }

    return Object.hash('ack:map', value.length, combined);
  }

  if (value is Iterable) {
    var hash = Object.hash('ack:iterable', 0);
    for (final item in value) {
      hash = Object.hash(hash, deepHashCode(item));
    }

    return hash;
  }

  return Object.hash(value.runtimeType, value.hashCode);
}

extension IterableExtensions<T> on Iterable<T> {
  /// Returns duplicate elements in this iterable.
  /// The order of duplicates in the returned iterable is based on their second appearance.
  Iterable<T> get duplicates {
    final seen = <T>{};
    final duplicatesFound = <T>[];
    for (final element in this) {
      if (!seen.add(element)) {
        // .add returns false if element was already present
        duplicatesFound.add(element);
      }
    }

    return duplicatesFound;
  }

  /// Checks if there are any duplicate elements in this iterable.
  bool get hasDuplicates => duplicates.isNotEmpty;

  /// Returns the first element matching [test], or `null` if none found.
  T? firstWhereOrNull(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) return element;
    }

    return null;
  }
}
