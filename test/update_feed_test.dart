import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:argus/utils/update_feed.dart';

void main() {
  group('parseLatestFullAsset', () {
    test('picks the newest Full package using real field names', () {
      final feed = jsonDecode(
        '{"Assets":['
        '{"PackageId":"Argus","Version":"0.1.15","Type":"Full","FileName":"Argus-0.1.15-full.nupkg","SHA1":"ABC","SHA256":"DEF","Size":10},'
        '{"PackageId":"Argus","Version":"0.1.16","Type":"Full","FileName":"Argus-0.1.16-full.nupkg","SHA1":"ABC2","SHA256":"DEF2","Size":20},'
        '{"PackageId":"Argus","Version":"0.9.0","Type":"Delta","FileName":"Argus-0.9.0-delta.nupkg","SHA1":"X","SHA256":"Y","Size":5}'
        ']}',
      ) as Map<String, dynamic>;

      final asset = parseLatestFullAsset(feed);
      expect(asset, isNotNull);
      expect(asset!.version, '0.1.16');
      expect(asset.fileName, 'Argus-0.1.16-full.nupkg');
      expect(asset.sha256, 'DEF2');
    });

    test('returns null when there are no Full packages', () {
      final feed = jsonDecode(
        '{"Assets":[{"PackageId":"Argus","Version":"0.1.15","Type":"Delta","FileName":"Argus-0.1.15-delta.nupkg"}]}',
      ) as Map<String, dynamic>;
      expect(parseLatestFullAsset(feed), isNull);
    });
  });

  group('verifyFileHash', () {
    late Directory tempDir;
    late File file;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('argus_hash_');
      file = File('${tempDir.path}/package.bin');
      await file.writeAsBytes([1, 2, 3, 4]);
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('returns true when SHA-256 matches', () async {
      final expected = sha256.convert([1, 2, 3, 4]).toString();
      final ok = await verifyFileHash(
        filePath: file.path,
        expectedSha256: expected.toUpperCase(),
      );
      expect(ok, isTrue);
    });

    test('returns false when SHA-256 does not match', () async {
      final ok = await verifyFileHash(
        filePath: file.path,
        expectedSha256: '0' * 64,
      );
      expect(ok, isFalse);
    });

    test('returns false when no hash is provided', () async {
      final ok = await verifyFileHash(filePath: file.path);
      expect(ok, isFalse);
    });
  });

  group('isSafeUpdateUrl', () {
    test('accepts https', () {
      expect(isSafeUpdateUrl('https://example.com'), isTrue);
    });

    test('accepts http localhost and 127.0.0.1', () {
      expect(isSafeUpdateUrl('http://localhost:8000'), isTrue);
      expect(isSafeUpdateUrl('http://127.0.0.1:8000'), isTrue);
    });

    test('rejects http to a remote host', () {
      expect(isSafeUpdateUrl('http://example.com'), isFalse);
    });
  });
}