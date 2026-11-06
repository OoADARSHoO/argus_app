import 'package:flutter_test/flutter_test.dart';
import 'package:argus/models/app_settings.dart';
import 'package:argus/models/appearance_settings.dart';
import 'package:argus/models/break_settings.dart';
import 'package:argus/models/accent_color.dart';

void main() {
  group('AppSettings defaults match AGENTS.md section 5', () {
    test('breakIntervalMinutes defaults to 20', () {
      expect(AppSettings.defaults.breakIntervalMinutes, 20);
    });

    test('breakDurationSeconds defaults to 20', () {
      expect(AppSettings.defaults.breakDurationSeconds, 20);
    });

    test('skipEnabled defaults to true', () {
      expect(AppSettings.defaults.skipEnabled, true);
    });

    test('startOnStartup defaults to true', () {
      expect(AppSettings.defaults.startOnStartup, true);
    });

    test('showNotifications defaults to true', () {
      expect(AppSettings.defaults.showNotifications, true);
    });

    test('enableSounds defaults to false', () {
      expect(AppSettings.defaults.enableSounds, false);
    });

    test('breakSettings defaults match BreakSettings.defaults', () {
      expect(AppSettings.defaults.breakSettings, BreakSettings.defaults);
    });

    test('appearanceSettings defaults match AppearanceSettings.defaults', () {
      expect(AppSettings.defaults.appearanceSettings,
          AppearanceSettings.defaults);
    });

    test('appearance theme defaults to dark', () {
      expect(AppSettings.defaults.appearanceSettings.themeId, 'dark');
    });

    test('appearance accent defaults to blue', () {
      expect(AppSettings.defaults.appearanceSettings.accentId, 'blue');
    });

    test('appearance uiScale defaults to 100', () {
      expect(AppSettings.defaults.appearanceSettings.uiScale, 100);
    });

    test('break message defaults to spec text', () {
      expect(
        AppSettings.defaults.breakSettings.message,
        'Time to rest your eyes. Look at something 20 feet away for 20 seconds.',
      );
    });

    test('break background defaults to black_screen', () {
      expect(AppSettings.defaults.breakSettings.backgroundId, 'black_screen');
    });

    test('break text color defaults to near-white', () {
      expect(AppSettings.defaults.breakSettings.textColor, 0xFFF5F5F5);
    });

    test('break font size defaults to large', () {
      expect(AppSettings.defaults.breakSettings.fontSizeId, 'large');
    });

    test('break showProgressRing defaults to true', () {
      expect(AppSettings.defaults.breakSettings.showProgressRing, true);
    });
  });

  group('AppSettings toJson / fromJson round-trip', () {
    test('round-trips all fields correctly', () {
      final original = AppSettings(
        breakIntervalMinutes: 30,
        breakDurationSeconds: 60,
        skipEnabled: false,
        startOnStartup: false,
        showNotifications: false,
        enableSounds: true,
        breakSettings: BreakSettings(
          message: 'Custom break message.',
          backgroundId: 'deep_blue',
          textColor: 0xFFFF0000,
          fontSizeId: 'small',
          showProgressRing: false,
        ),
        appearanceSettings: AppearanceSettings(
          themeId: 'light',
          accentId: 'purple',
          uiScale: 125,
        ),
      );

      final json = original.toJson();
      final restored = AppSettings.fromJson(json);

      expect(restored, original);
    });

    test('toJson includes version 1', () {
      final json = AppSettings.defaults.toJson();
      expect(json['version'], 1);
    });

    test('round-trip preserves nested models', () {
      final original = AppSettings(
        breakIntervalMinutes: 15,
        breakDurationSeconds: 30,
        skipEnabled: true,
        startOnStartup: true,
        showNotifications: true,
        enableSounds: false,
        breakSettings: BreakSettings.defaults,
        appearanceSettings: AppearanceSettings.defaults,
      );

      final restored = AppSettings.fromJson(original.toJson());
      expect(restored.breakSettings, original.breakSettings);
      expect(restored.appearanceSettings, original.appearanceSettings);
    });
  });

  group('AppSettings.fromJson never throws', () {
    test('empty map falls back to defaults', () {
      expect(() => AppSettings.fromJson({}), returnsNormally);
      expect(AppSettings.fromJson({}), AppSettings.defaults);
    });

    test('missing keys fall back to defaults', () {
      final s = AppSettings.fromJson({'version': 1});
      expect(s, AppSettings.defaults);
    });

    test('wrong types fall back to defaults', () {
      final s = AppSettings.fromJson({
        'version': 1,
        'breakIntervalMinutes': 'not a number',
        'breakDurationSeconds': null,
        'skipEnabled': 'yes',
        'startOnStartup': 1,
        'showNotifications': [],
        'enableSounds': {},
      });
      expect(s.breakIntervalMinutes, 20);
      expect(s.breakDurationSeconds, 20);
      expect(s.skipEnabled, true);
      expect(s.startOnStartup, true);
      expect(s.showNotifications, true);
      expect(s.enableSounds, false);
    });

    test('unknown version returns defaults', () {
      final s = AppSettings.fromJson({'version': 99});
      expect(s, AppSettings.defaults);
    });

    test('null nested maps fall back to defaults', () {
      final s = AppSettings.fromJson({
        'version': 1,
        'breakSettings': null,
        'appearanceSettings': null,
      });
      expect(s.breakSettings, BreakSettings.defaults);
      expect(s.appearanceSettings, AppearanceSettings.defaults);
    });

    test('out-of-range breakIntervalMinutes clamps to allowed option', () {
      // 999 clamps to nearest allowed (60)
      final s = AppSettings.fromJson({
        'version': 1,
        'breakIntervalMinutes': 999,
      });
      expect(s.breakIntervalMinutes, 60);
    });

    test('out-of-range breakDurationSeconds clamps to allowed option', () {
      // 1 clamps to nearest allowed (10)
      final s = AppSettings.fromJson({
        'version': 1,
        'breakDurationSeconds': 1,
      });
      expect(s.breakDurationSeconds, 10);
    });

    test('out-of-range uiScale clamps to allowed option', () {
      // 200 clamps to nearest allowed (125)
      final s = AppSettings.fromJson({
        'version': 1,
        'appearanceSettings': {'uiScale': 200},
      });
      expect(s.appearanceSettings.uiScale, 125);

      // 50 clamps to nearest allowed (90)
      final s2 = AppSettings.fromJson({
        'version': 1,
        'appearanceSettings': {'uiScale': 50},
      });
      expect(s2.appearanceSettings.uiScale, 90);
    });

    test('unknown theme id falls back to default', () {
      final s = AppSettings.fromJson({
        'version': 1,
        'appearanceSettings': {'themeId': 'unknown_theme'},
      });
      expect(s.appearanceSettings.themeId, 'dark');
    });

    test('unknown accent id falls back to default', () {
      final s = AppSettings.fromJson({
        'version': 1,
        'appearanceSettings': {'accentId': 'unknown_accent'},
      });
      expect(s.appearanceSettings.accentId, 'blue');
    });

    test('unknown background id falls back to default', () {
      final s = AppSettings.fromJson({
        'version': 1,
        'breakSettings': {'backgroundId': 'unknown_bg'},
      });
      expect(s.breakSettings.backgroundId, 'black_screen');
    });

    test('unknown font size id falls back to default', () {
      final s = AppSettings.fromJson({
        'version': 1,
        'breakSettings': {'fontSizeId': 'unknown_size'},
      });
      expect(s.breakSettings.fontSizeId, 'large');
    });
  });

  group('BreakSettings defaults', () {
    test('message matches spec', () {
      expect(
        BreakSettings.defaults.message,
        'Time to rest your eyes. Look at something 20 feet away for 20 seconds.',
      );
    });

    test('backgroundId defaults to black_screen', () {
      expect(BreakSettings.defaults.backgroundId, 'black_screen');
    });

    test('textColor defaults to near-white', () {
      expect(BreakSettings.defaults.textColor, 0xFFF5F5F5);
    });

    test('fontSizeId defaults to large', () {
      expect(BreakSettings.defaults.fontSizeId, 'large');
    });

    test('showProgressRing defaults to true', () {
      expect(BreakSettings.defaults.showProgressRing, true);
    });
  });

  group('BreakSettings round-trip', () {
    test('toJson then fromJson preserves values', () {
      final original = BreakSettings(
        message: 'Hello',
        backgroundId: 'dark_gray',
        textColor: 0xFF00FF00,
        fontSizeId: 'small',
        showProgressRing: false,
      );
      final restored = BreakSettings.fromJson(original.toJson());
      expect(restored, original);
    });

    test('empty map falls back to defaults', () {
      expect(BreakSettings.fromJson({}), BreakSettings.defaults);
    });

    test('wrong types fall back to defaults without throwing', () {
      expect(() => BreakSettings.fromJson({
        'message': 123,
        'textColor': 'not a number',
        'showProgressRing': 'yes',
      }), returnsNormally);
      final s = BreakSettings.fromJson({
        'message': 123,
        'textColor': 'not a number',
        'showProgressRing': 'yes',
      });
      expect(s.message, BreakSettings.defaults.message);
      expect(s.textColor, BreakSettings.defaults.textColor);
      expect(s.showProgressRing, BreakSettings.defaults.showProgressRing);
    });
  });

  group('AppearanceSettings defaults', () {
    test('themeId defaults to dark', () {
      expect(AppearanceSettings.defaults.themeId, 'dark');
    });

    test('accentId defaults to blue', () {
      expect(AppearanceSettings.defaults.accentId, 'blue');
    });

    test('uiScale defaults to 100', () {
      expect(AppearanceSettings.defaults.uiScale, 100);
    });
  });

  group('AppearanceSettings round-trip', () {
    test('toJson then fromJson preserves values', () {
      final original = AppearanceSettings(
        themeId: 'light',
        accentId: 'teal',
        uiScale: 125,
      );
      final restored = AppearanceSettings.fromJson(original.toJson());
      expect(restored, original);
    });

    test('empty map falls back to defaults', () {
      expect(AppearanceSettings.fromJson({}), AppearanceSettings.defaults);
    });

    test('wrong types fall back to defaults without throwing', () {
      expect(() => AppearanceSettings.fromJson({
        'themeId': 123,
        'uiScale': 'not a number',
      }), returnsNormally);
      final s = AppearanceSettings.fromJson({
        'themeId': 123,
        'uiScale': 'not a number',
      });
      expect(s.themeId, AppearanceSettings.defaults.themeId);
      expect(s.uiScale, AppearanceSettings.defaults.uiScale);
    });
  });

  group('AccentColorOption', () {
    test('fromId returns blue for null id', () {
      expect(AccentColorOption.fromId(null), AccentColorOption.blue);
    });

    test('fromId returns blue for empty id', () {
      expect(AccentColorOption.fromId(''), AccentColorOption.blue);
    });

    test('fromId returns blue for unknown id', () {
      expect(AccentColorOption.fromId('unknown'), AccentColorOption.blue);
    });

    test('fromId returns correct option for known ids', () {
      expect(AccentColorOption.fromId('blue'), AccentColorOption.blue);
      expect(AccentColorOption.fromId('purple'), AccentColorOption.purple);
      expect(AccentColorOption.fromId('green'), AccentColorOption.green);
      expect(AccentColorOption.fromId('orange'), AccentColorOption.orange);
      expect(AccentColorOption.fromId('pink'), AccentColorOption.pink);
      expect(AccentColorOption.fromId('teal'), AccentColorOption.teal);
    });

    test('all list contains 6 options', () {
      expect(AccentColorOption.all.length, 6);
    });

    test('toJson includes id', () {
      expect(AccentColorOption.blue.toJson()['id'], 'blue');
    });

    test('fromJson falls back to blue for null', () {
      expect(AccentColorOption.fromJson(null), AccentColorOption.blue);
    });
  });
}
