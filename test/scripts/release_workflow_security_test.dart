import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('publishing executes only immutable reviewed dependencies', () {
    final workflowSources = _publishingWorkflowSources();
    final externalUses = RegExp(
      r'^\s*-?\s*uses:\s*([^\s]+)@([^\s#]+)',
      multiLine: true,
    );

    for (final entry in workflowSources.entries) {
      for (final match in externalUses.allMatches(entry.value)) {
        final action = match.group(1)!;
        final reference = match.group(2)!;
        expect(
          reference,
          matches(RegExp(r'^[0-9a-f]{40}$')),
          reason: '$action in ${entry.key} must use a full commit SHA',
        );
      }
      expect(
        entry.value,
        isNot(matches(RegExp(r'curl[^\n]*\|\s*(?:ba)?sh'))),
        reason: '${entry.key} must not execute unverified downloaded scripts',
      );
    }
  });

  test('the publishing Flutter SDK is versioned and checksum verified', () {
    final workflowSources = _publishingWorkflowSources();
    final combined = workflowSources.values.join('\n');
    final flutterVersion = RegExp(
      r'"flutter"\s*:\s*"([^"]+)"',
    ).firstMatch(File('.fvmrc').readAsStringSync())!.group(1)!;

    expect(flutterVersion, isNot('stable'));
    expect(combined, contains('flutter_linux_$flutterVersion-stable.tar.xz'));
    expect(combined, contains('sha256sum --check'));
    expect(
      combined,
      matches(RegExp(r'FLUTTER_ARCHIVE_SHA256:\s*[0-9a-f]{64}')),
    );
  });
}

Map<String, String> _publishingWorkflowSources() {
  const entrypoint = '.github/workflows/release.yml';
  final sources = <String, String>{};
  final pending = <String>[entrypoint];
  final localWorkflow = RegExp(r'uses:\s*\./\.github/workflows/([^\s]+)');

  while (pending.isNotEmpty) {
    final path = pending.removeLast();
    if (sources.containsKey(path)) continue;
    final source = File(path).readAsStringSync();
    sources[path] = source;
    for (final match in localWorkflow.allMatches(source)) {
      pending.add('.github/workflows/${match.group(1)!}');
    }
  }
  return sources;
}
