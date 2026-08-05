/// Performs deep equality comparison between two values.
///
/// This function recursively compares:
/// - JSON numbers by numeric value (`1` and `1.0` are equal)
/// - Other primitives using standard equality
/// - Lists by comparing each element in order
/// - Maps by comparing keys and values
/// - Sets by comparing elements (order-independent)
///
/// Returns `true` if the values are structurally equal, `false` otherwise.
/// Collection categories remain distinct (e.g., a List is not equal to a Set
/// or another Iterable implementation).
bool deepEquals(Object? a, Object? b) {
  // Fast path: identical objects or both null
  if (identical(a, b)) return true;

  if (a == null || b == null) return false;

  // JSON Schema considers mathematically equal numbers equal regardless of
  // whether Dart represents them as int or double. Check this before runtime
  // types because dart2js does not preserve that distinction consistently.
  if (a is num && b is num) return a == b;

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
    for (final key in a.keys) {
      if (!b.containsKey(key)) return false;
      if (!deepEquals(a[key], b[key])) return false;
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

  // Preserve type distinctions for non-numeric scalar values.
  if (a.runtimeType != b.runtimeType) return false;

  return a == b;
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
