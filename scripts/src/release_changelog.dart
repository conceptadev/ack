typedef ChangelogUpdate = ({String content, bool found, bool changed});

/// Replaces the exact [version] section with a release-notes link and removes
/// duplicate headings for that same version.
///
/// Prerelease headings such as `1.0.0-beta.1` do not match version `1.0.0`.
ChangelogUpdate updateReleaseChangelog(
  String content, {
  required String version,
  required String releaseUrl,
}) {
  final lines = content.split('\n');
  final headingIndex = lines.indexWhere(
    (line) => _isVersionHeading(line, version),
  );
  if (headingIndex == -1) {
    return (content: content, found: false, changed: false);
  }

  final bracketed = lines[headingIndex].trimLeft().startsWith('## [');
  lines[headingIndex] = bracketed ? '## [$version]' : '## $version';

  var sectionEnd = _nextHeadingIndex(lines, headingIndex + 1);
  lines.replaceRange(headingIndex + 1, sectionEnd, [
    '',
    '* See [release notes]($releaseUrl) for details.',
    '',
  ]);

  var duplicateIndex = lines.indexWhere(
    (line) => _isVersionHeading(line, version),
    headingIndex + 1,
  );
  while (duplicateIndex != -1) {
    sectionEnd = _nextHeadingIndex(lines, duplicateIndex + 1);
    lines.removeRange(duplicateIndex, sectionEnd);
    duplicateIndex = lines.indexWhere(
      (line) => _isVersionHeading(line, version),
      headingIndex + 1,
    );
  }

  final updated = lines.join('\n');
  return (content: updated, found: true, changed: updated != content);
}

/// Reports whether [content] declares a release heading for [version].
///
/// Prerelease headings such as `1.0.0-beta.1` do not match version `1.0.0`.
bool hasVersionHeading(String content, {required String version}) =>
    content.split('\n').any((line) => _isVersionHeading(line, version));

bool _isVersionHeading(String line, String version) {
  final escapedVersion = RegExp.escape(version);
  final pattern = RegExp(
    '^##\\s+(?:\\[$escapedVersion\\]|$escapedVersion)(?:\\s|\$)',
  );
  return pattern.hasMatch(line);
}

int _nextHeadingIndex(List<String> lines, int start) {
  final index = lines.indexWhere((line) => line.startsWith('## '), start);
  return index == -1 ? lines.length : index;
}
