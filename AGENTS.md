# AGENTS.md — Argus

Instructions for any AI coding agent (OpenCode, Antigravity, Claude Code, etc.) working in this repo. Read this fully before writing code.

## 1. What Argus is

Argus is a **Windows-only desktop app** that enforces the 20-20-20 eye-rest rule: every 20 minutes it blacks out the screen for 20 seconds. It lives in the system tray, runs silently, starts with Windows, and is lightweight and fully offline (the app itself makes no network calls).

- Tagline: "Your eyes. Our watch."
- Publisher: Bitekoi Labs
- Version: 1.0.0 (MVP)
- The owner is a beginner Flutter developer. **Write simple, readable, well-commented code. Prefer boring and obvious over clever.**

## 2. Source of truth for design

The design blueprints are images in `blueprints/` (project root). **They override everything else, including any older spec file** (`argus-design-spec.html` is obsolete, ignore it if present). If a value below conflicts with a blueprint image, follow the image and tell the owner.

The blueprint images are: the overview sheet (break screen, tray, settings window), the Settings Window Blueprint (all 5 tabs), and the Design System sheet (tokens and component sizes). The overview sheet's sidebar shows a "Startup" tab; that is **superseded** by the 5-tab sidebar (General, Break, Appearance, Support, About) in the Settings Window Blueprint. Startup is just a toggle on the General page.

All visual values live in `lib/core/constants/` as tokens. **Never hardcode a color, size, radius, font size, or spacing number inside a widget.** Always reference a token.

## 3. Stack and rules

- Flutter (Dart), **Windows desktop only**. Do not add or restore android/ios/web/linux/macos folders.
- Project root is this folder (`argus_app`), package name `argus`.
- **State management: plain `setState` / `ValueNotifier` / `ChangeNotifier` only.** No Riverpod, Bloc, Provider, GetX.
- **Allowed packages** (add nothing else without asking the owner first):
  - `tray_manager` for the system tray icon and menu
  - `window_manager` for window size, frameless, always-on-top, fullscreen, prevent-close
  - `launch_at_startup` for starting with Windows
  - one outline icon package matching the blueprint's thin-stroke icons (Lucide style). Confirm the exact package name on pub.dev before adding.
- Settings are saved as JSON at `%APPDATA%\Argus\settings.json` using `dart:io` and `dart:convert` (no extra package).
- Font: **Inter**, bundled in `assets/fonts/Inter/static/`. Use the `Inter_18pt-*.ttf` files only (Regular 400, Medium 500, SemiBold 600, Bold 700), registered in `pubspec.yaml` under family `Inter`. Do not use `google_fonts` (the app must work offline).
- Run `flutter analyze` after every change and fix all errors and warnings before saying you're done.
- Do not edit anything inside `windows/` unless a task truly requires it, and say so if you do.
- Work **one phase at a time** (section 9). Do not build ahead. After each phase, tell the owner exactly how to run and check it.

## 4. Design tokens

### Colors (`app_colors.dart`)

| Token | Hex |
|---|---|
| primary | #5B8CFF |
| primaryLight | #7BA6FF |
| primaryDark | #2E5DFF |
| background | #0E0E10 |
| surface | #16161B |
| surfaceElevated | #1E1E24 |
| border | #2A2A33 |
| divider | #24242C |
| textPrimary | #F5F5F5 |
| textSecondary | #A1A1AA |
| textTertiary | #71717A |
| textDisabled | #52525B |
| success | #22C55E |
| warning | #F59E0B |
| error | #EF4444 |
| info | #3B82F6 |

Accent color options on the Appearance page (6 swatches, in order): blue `#5B8CFF` (default), purple, green, orange, pink, teal. Only blue is specified exactly. Pick close matches to the blueprint swatches for the other five and keep them in one list in `accent_color.dart`.

Active nav item and selected states use the accent color at low opacity (about 12 to 15%) as background, with accent-colored icon and text.

### Typography (`app_typography.dart`), all Inter

| Style | Size / line height | Weight | Letter spacing |
|---|---|---|---|
| Heading 1 | 32 / 40 | 700 | -0.5 |
| Heading 2 | 20 / 28 | 600 | -0.3 |
| Body Large | 16 / 24 | 500 | 0 |
| Body | 14 / 20 | 400 | 0 |
| Caption | 12 / 16 | 400 | 0 |
| Small | 11 / 14 | 400 | 0 |

Extra sizes used by specific screens (derive them from the blueprints and keep them in the typography file): break screen headline (large, bold), break screen body, countdown number inside the ring, tray timer "19:47".

### Spacing (`app_spacing.dart`), 8px base unit

4, 8, 12, 16, 20, 24, 32, 40, 48, 64.

Common usage: window padding 24 · section gap 32 · card padding 20 · element gap 16 · icon-to-text 12 · button padding 12 vertical × 20 horizontal · input padding 10 vertical × 14 horizontal · layout gutter 24.

### Radius (`app_radius.dart`)

4, 6, 8, 12, 16, 24, full (999). Cards use 12. Inputs, dropdowns and buttons use 6 to 8 (match the blueprint). Badges use 8.

### Shadows (`app_shadows.dart`), two layers each, black

These were read from a small image, so double-check them against the blueprint.

- Shadow 1 (sm): `0 1 2 rgba(0,0,0,.10)` + `0 1 3 rgba(0,0,0,.15)`
- Shadow 2 (md): `0 4 6 rgba(0,0,0,.15)` + `0 2 4 rgba(0,0,0,.10)`
- Shadow 3 (lg): `0 10 15 rgba(0,0,0,.20)` + `0 4 6 rgba(0,0,0,.10)`
- Shadow 4 (xl): `0 20 30 rgba(0,0,0,.25)` + `0 10 10 rgba(0,0,0,.15)`

All surfaces use Shadow 1 by default. Elevated elements use Shadow 2 or 3.

### Dimensions (`app_dimensions.dart`)

| Element | Size |
|---|---|
| Main settings window | 960 × 640 |
| Title bar | 32 high |
| Sidebar | 180 wide |
| Sidebar / tab item | 160 wide × 40 high |
| Button (primary, secondary) | 40 high |
| Icon button | 40 × 40 |
| Input and dropdown | 36 high |
| Toggle switch | 44 × 24 |
| Card radius | 12 |
| Icon size | 24 |
| Progress ring | 120 (component), 160 (break screen) |
| Badge | 18 high |
| Break screen | fullscreen (reference 1920 × 1080) |

## 5. Screens and behavior

### Settings window (5 tabs, sidebar order)

General, Break, Appearance, Support, About. Custom frameless title bar: "ARGUS" wordmark on the left, window buttons on the right. (The blueprints show minimize + close in the overview sheet and minimize + maximize + close elsewhere. The window is a fixed 960 × 640, so build **minimize and close only**, and mention this choice to the owner.) Same layout shell for all pages: title, subtitle, then a list of setting rows (label and description on the left, control on the right).

**General** — "Configure general behavior of Argus."
- Break Interval: dropdown, "Time between breaks", default 20 minutes
- Break Duration: dropdown, "Length of each break", default 20 seconds
- Skip Option: toggle, "Allow skipping break with Esc key", default on
- Start on Windows Startup: toggle, "Launch Argus when Windows starts", default on
- Show Notifications: toggle, "Show reminder before break (10 sec before)", default on
- Enable Sounds: toggle, "Play a soft sound before a break", default off

**Break** — "Customize your break experience."
- Break Message: multiline text field, default "Time to rest your eyes. Look at something 20 feet away for 20 seconds."
- Background: dropdown, default "Black Screen"
- Text Color: color swatch, default near-white
- Font Size: dropdown, default "Large"
- Show Progress Ring: toggle, default on

**Appearance** — "Change how Argus looks."
- Theme: three selectable cards, Dark (default) / Light / System
- Accent Color: six circular swatches, the selected one has a ring
- UI Scale: dropdown, default "100% (Default)"

**Support** — "Your support keeps Argus alive."
- Donation progress ring: "Money needed for the month", "$128 / $200", "64%". These are **hardcoded placeholder values** for now (local variables in the page, no network).
- Text: "Every donation helps keep Argus free, independent and ad-free."
- Buttons: "Donate Now" (primary) and "Learn More" (secondary). For now they can do nothing or open a placeholder URL in the default browser.

**About**
- Eye logo, "ARGUS", "Version 1.0.0", "20-20-20 made simple."
- Description: "Argus helps you follow the 20-20-20 rule by blocking your screen for 20 seconds every 20 minutes so you can rest your eyes, refocus, and stay productive."
- Links: Privacy Policy, Terms of Use
- Footer: "© 2025 BITEKOI LABS. All rights reserved."

### Break overlay

Fullscreen, always on top, background `#0E0E10` (or per Break settings). Centered column: eye icon, headline "Time to rest your eyes.", body "Look at something 20 feet away for 20 seconds.", circular progress ring (160) with the countdown number inside, then a tip row with a lightbulb icon: "Tip: Blink slowly and relax your eyes." A "Skip (Esc)" button sits top-right (shown and active only if Skip Option is on). The ring counts down from the break duration, and the overlay closes automatically at 0.

### System tray

Tray icon with a popup/menu showing: header "ARGUS" with a gear icon, "Next break in 19:47" (live mm:ss countdown) with a green check icon, then "Pause for 1 hour", "Settings", "Exit Argus". Closing the settings window **hides it to the tray** and the app keeps running. Only "Exit Argus" quits.

**MVP limitation:** `tray_manager` only gives a native Windows context menu, so the blueprint's styled card (green check, big timer) cannot be reproduced exactly. For the MVP, build the native menu with the same items in the same order, with the first item's label updating live (for example "Next break in 19:47"). A custom styled popup is a post-MVP upgrade. Do not try to hack one in during phase 6.

### Timer behavior

Work interval counts down (default 20 min), then an optional notification 10 seconds before, then the break overlay for the break duration, then repeat. "Pause for 1 hour" suspends the cycle and resumes automatically afterwards. Changing interval or duration in settings applies from the next cycle.

## 6. Architecture decisions (keep these)

- **Single window, two modes.** Do not build true multi-window. The one app window is either the 960×640 settings window or switches into overlay mode (fullscreen, frameless, always-on-top) for a break and switches back afterwards. Use `window_manager` for this. The settings window stays hidden in the tray when not open.
- `BreakTimerService` owns the timing and exposes streams or notifiers for "seconds until break" and "seconds left in break". The UI and the tray only listen to it.
- Services are plain Dart classes created once in `main.dart` and passed down. No hidden global singletons beyond that.
- The settings model has `toJson` / `fromJson` and sensible defaults, so a missing or corrupted file never crashes the app.

## 7. Project structure

```
lib/
  main.dart                 entry point: init window_manager, tray, services, runApp
  app.dart                  root MaterialApp + theme
  core/
    constants/              app_colors, app_typography, app_spacing, app_radius,
                            app_shadows, app_dimensions
    theme/app_theme.dart
  models/                   app_settings, break_settings, appearance_settings, accent_color
  services/                 tray_service, window_service, startup_service,
                            settings_service, break_timer_service
  screens/
    settings/               settings_shell, general_page, break_page,
                            appearance_page, support_page, about_page
    break_overlay/          break_overlay_screen
  widgets/
    titlebar/custom_title_bar
    sidebar/                sidebar_nav, sidebar_nav_item
    common/                 settings_row, app_toggle, app_dropdown, app_text_input,
                            primary_button, secondary_button, icon_button_widget,
                            card_container, badge_widget, progress_ring,
                            theme_option_card, accent_swatch
    icons/app_icons
  utils/time_format.dart
assets/
  fonts/Inter/static/       Inter_18pt-*.ttf
  icons/                    app_icon.ico, tray_icon.ico
blueprints/                 design images (do not modify)
```

`progress_ring.dart` is one generic widget (value, size, stroke width, color, child) reused for the component demo, the break screen, and the Support donation ring. Icons are referenced only through `app_icons.dart`.

## 8. Code style

- Small files, one widget per file, `const` constructors wherever possible.
- Comment the *why* on anything non-obvious (especially window and tray code), in plain language.
- No unused imports and no leftover `print` calls (use `debugPrint` while developing).
- Keep widgets dumb: they receive values and callbacks, and services hold the logic.
- If a requirement is unclear or conflicts with a blueprint, **ask the owner instead of guessing**.

## 9. Build phases

Do only the phase you are asked to do.

1. **Foundation**: fonts registered, all token files, `app_theme.dart`, `main.dart` + `app.dart` launching a blank dark window at 960×640 with the Inter font.
2. **Shared widgets**: everything in `widgets/common/`, plus `app_icons`, with a temporary demo page to view them.
3. **Settings UI (static)**: custom title bar, sidebar, shell, and all 5 pages with local state only, matching the blueprints.
4. **Settings persistence**: models, `settings_service`, load on start, save on change.
5. **Break timer**: `break_timer_service` with working countdowns (test with short durations).
6. **System tray**: tray icon, live "Next break in", Pause / Settings / Exit, hide-to-tray on close.
7. **Break overlay**: fullscreen overlay mode, Esc to skip, auto close, pre-break notification.
8. **Startup + release**: launch at startup, app icon, `flutter build windows --release`, packaging notes.

## 10. Definition of done (every phase)

- `flutter analyze` is clean.
- `flutter run -d windows` launches without errors.
- Visuals match the blueprint at 100% scale.
- You have listed which files you created or changed and how to test the phase.
