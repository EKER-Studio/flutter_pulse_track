import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_track/core/integrations/health/platform_detector.dart';

void main() {
  group('NativePlatformDetector', () {
    test('delegates to dart:io platform flags', () {
      const detector = NativePlatformDetector();

      expect(detector.isAndroid, Platform.isAndroid);
      expect(detector.isIOS, Platform.isIOS);
    });
  });
}
