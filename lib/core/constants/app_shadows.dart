import 'package:flutter/material.dart';

/// Shadow elevation tokens for Argus desktop application.
/// Each elevation level utilizes two subtle black layers for depth.
class AppShadows {
  AppShadows._();

  /// Shadow 1 (sm) - default for cards and surfaces
  /// `0 1 2 rgba(0,0,0,.10)` + `0 1 3 rgba(0,0,0,.15)`
  static const List<BoxShadow> sm = [
    BoxShadow(
      offset: Offset(0, 1),
      blurRadius: 2,
      color: Color.fromRGBO(0, 0, 0, 0.10),
    ),
    BoxShadow(
      offset: Offset(0, 1),
      blurRadius: 3,
      color: Color.fromRGBO(0, 0, 0, 0.15),
    ),
  ];

  /// Shadow 2 (md) - elevated components and hover states
  /// `0 4 6 rgba(0,0,0,.15)` + `0 2 4 rgba(0,0,0,.10)`
  static const List<BoxShadow> md = [
    BoxShadow(
      offset: Offset(0, 4),
      blurRadius: 6,
      color: Color.fromRGBO(0, 0, 0, 0.15),
    ),
    BoxShadow(
      offset: Offset(0, 2),
      blurRadius: 4,
      color: Color.fromRGBO(0, 0, 0, 0.10),
    ),
  ];

  /// Shadow 3 (lg) - dropdowns, popovers, and elevated modals
  /// `0 10 15 rgba(0,0,0,.20)` + `0 4 6 rgba(0,0,0,.10)`
  static const List<BoxShadow> lg = [
    BoxShadow(
      offset: Offset(0, 10),
      blurRadius: 15,
      color: Color.fromRGBO(0, 0, 0, 0.20),
    ),
    BoxShadow(
      offset: Offset(0, 4),
      blurRadius: 6,
      color: Color.fromRGBO(0, 0, 0, 0.10),
    ),
  ];

  /// Shadow 4 (xl) - floating windows
  /// `0 20 30 rgba(0,0,0,.25)` + `0 10 10 rgba(0,0,0,.15)`
  static const List<BoxShadow> xl = [
    BoxShadow(
      offset: Offset(0, 20),
      blurRadius: 30,
      color: Color.fromRGBO(0, 0, 0, 0.25),
    ),
    BoxShadow(
      offset: Offset(0, 10),
      blurRadius: 10,
      color: Color.fromRGBO(0, 0, 0, 0.15),
    ),
  ];
}
