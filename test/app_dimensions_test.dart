import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:argus/core/constants/app_dimensions.dart';

void main() {
  test('scaledWindowSize multiplies the base 960x640 window', () {
    expect(AppDimensions.scaledWindowSize(70), const Size(672, 448));
    expect(AppDimensions.scaledWindowSize(80), const Size(768, 512));
    expect(AppDimensions.scaledWindowSize(90), const Size(864, 576));
    expect(AppDimensions.scaledWindowSize(100), const Size(960, 640));
    expect(AppDimensions.scaledWindowSize(110), const Size(1056, 704));
    expect(AppDimensions.scaledWindowSize(125), const Size(1200, 800));
  });
}
