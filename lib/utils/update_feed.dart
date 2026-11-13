import 'dart:io';

import 'package:crypto/crypto.dart';

import 'version.dart';

/// Pure functions for parsing Velopack release feeds and verifying hashes.
/// No network access — safe to test offline.

/// Parses a releases.win.json feed and returns the newest Full package.
///
/// Returns null if no Full packages exist or the JSON is invalid.
VelopackAsset? parseLatestFullAsset(Map<String, dynamic> feed) {
  final assets = feed['Assets'] as List<dynamic>?;
  if (assets == null || assets.isEmpty) return null;

  VelopackAsset? best;
  for (final a in assets) {
    if (a is! Map<String, dynamic>) continue;
    if (a['Type'] != 'Full') continue;
    final fileName = a['FileName'] as String?;
    if (fileName == null || !fileName.endsWith('-full.nupkg')) continue;
    final versionStr = a['Version'] as String?;
    if (versionStr == null) continue;
    if (best == null || compareVersions(versionStr, best.version) > 0) {
      best = VelopackAsset(
        name: a['PackageId'] as String? ?? 'Argus',
        version: versionStr,
        fileName: fileName,
        sha256: a['SHA256'] as String?,
        sha1: a['SHA1'] as String?,
        size: a['Size'] as int?,
      );
    }
  }
  return best;
}

/// Verifies that the file at [filePath] has the expected hash.
///
/// If [expectedSha256] is non-null, computes SHA-256 and compares
/// case-insensitively. If [expectedSha256] is null but [expectedSha1] is
/// non-null, computes SHA-1 instead. If neither is non-null, returns false.
///
/// Returns true if the hash matches, false otherwise.
Future<bool> verifyFileHash({
  required String filePath,
  String? expectedSha256,
  String? expectedSha1,
}) async {
  if (expectedSha256 == null && expectedSha1 == null) return false;

  final file = File(filePath);
  if (!file.existsSync()) return false;

  final bytes = file.openRead();
  if (expectedSha256 != null) {
    final digest = await sha256.bind(bytes).first;
    return digest.toString().toLowerCase() == expectedSha256.toLowerCase();
  } else {
    final digest = await sha1.bind(bytes).first;
    return digest.toString().toLowerCase() == expectedSha1!.toLowerCase();
  }
}

/// Returns true when [url] is safe to use as an update base URL.
///
/// Only HTTPS is allowed, except HTTP for localhost or 127.0.0.1 (used for
/// local testing). Anything else (plain HTTP to a remote host, ftp, etc.) is
/// rejected.
bool isSafeUpdateUrl(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) return false;
  if (uri.scheme == 'https') return true;
  if (uri.scheme == 'http' &&
      (uri.host == 'localhost' || uri.host == '127.0.0.1')) {
    return true;
  }
  return false;
}

/// Alias kept for callers that use a shorter name.
bool isSafeUrl(String url) => isSafeUpdateUrl(url);

/// Alias kept for callers that use an "allowed" naming.
bool isAllowedUpdateUrl(String url) => isSafeUpdateUrl(url);

/// Simple value object for a release asset from releases.win.json.
class VelopackAsset {
  final String name;
  final String version;
  final String fileName;
  final String? sha256;
  final String? sha1;
  final int? size;

  VelopackAsset({
    required this.name,
    required this.version,
    required this.fileName,
    this.sha256,
    this.sha1,
    this.size,
  });
}
