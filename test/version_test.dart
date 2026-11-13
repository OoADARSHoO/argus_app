import 'package:flutter_test/flutter_test.dart';
import 'package:argus/utils/version.dart';

void main() {
  group('compareVersions', () {
    test('equal versions return 0', () {
      expect(compareVersions('1.2.3', '1.2.3'), 0);
    });

    test('newer version returns 1', () {
      expect(compareVersions('1.2.4', '1.2.3'), 1);
    });

    test('older version returns -1', () {
      expect(compareVersions('1.2.2', '1.2.3'), -1);
    });

    test('1.0.10 is newer than 1.0.9', () {
      expect(compareVersions('1.0.10', '1.0.9'), 1);
    });
  });

  group('appVersion', () {
    test('defaults to 0.0.0 when APP_VERSION is not provided', () {
      expect(appVersion, '0.0.0');
    });
  });
}