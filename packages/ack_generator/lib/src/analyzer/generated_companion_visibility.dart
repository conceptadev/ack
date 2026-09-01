import 'package:analyzer/dart/element/element.dart';

/// Whether [import] will expose [generatedName] once it is generated as a
/// public member of [definingLibrary].
///
/// Analyzer namespaces cannot contain a generated companion before its part
/// exists, so visibility has to be projected through every import and export
/// combinator on the route to the defining library.
bool importExposesGeneratedCompanion(
  LibraryImport import, {
  required LibraryElement definingLibrary,
  required String generatedName,
}) {
  if (!_combinatorsAllow(import.combinators, generatedName)) return false;
  final importedLibrary = import.importedLibrary;
  if (importedLibrary == null) return false;
  return _libraryExportsGeneratedCompanion(
    importedLibrary,
    definingLibrary: definingLibrary,
    generatedName: generatedName,
    visited: <Uri>{},
  );
}

bool _libraryExportsGeneratedCompanion(
  LibraryElement library, {
  required LibraryElement definingLibrary,
  required String generatedName,
  required Set<Uri> visited,
}) {
  if (library.uri == definingLibrary.uri) return true;
  if (!visited.add(library.uri)) return false;
  for (final export in library.firstFragment.libraryExports) {
    if (!_combinatorsAllow(export.combinators, generatedName)) continue;
    final exportedLibrary = export.exportedLibrary;
    if (exportedLibrary != null &&
        _libraryExportsGeneratedCompanion(
          exportedLibrary,
          definingLibrary: definingLibrary,
          generatedName: generatedName,
          visited: visited,
        )) {
      return true;
    }
  }
  return false;
}

bool _combinatorsAllow(List<NamespaceCombinator> combinators, String name) {
  for (final combinator in combinators) {
    if (combinator is ShowElementCombinator &&
        !combinator.shownNames.contains(name)) {
      return false;
    }
    if (combinator is HideElementCombinator &&
        combinator.hiddenNames.contains(name)) {
      return false;
    }
  }
  return true;
}
