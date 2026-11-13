/// Compares two semantic version strings (major.minor.patch).
/// Returns -1 if [a] < [b], 0 if equal, 1 if [a] > [b].
/// Prerelease suffixes are ignored.
int compareVersions(String a, String b) {
  final aParts = _parseVersion(a);
  final bParts = _parseVersion(b);
  for (int i = 0; i < 3; i++) {
    if (aParts[i] < bParts[i]) return -1;
    if (aParts[i] > bParts[i]) return 1;
  }
  return 0;
}

/// Parses a version string into [major, minor, patch] ints.
/// Non-numeric parts are treated as 0.
List<int> _parseVersion(String v) {
  final parts = v.split('.').take(3);
  return parts.map((p) {
    final num = int.tryParse(p);
    return num ?? 0;
  }).toList();
}
