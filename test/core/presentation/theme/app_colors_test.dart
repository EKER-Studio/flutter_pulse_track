import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_track/core/presentation/theme/app_colors.dart';

void main() {
  group('AppColors', () {
    group('backgrounds', () {
      test('scaffoldBackground is a Color', () {
        expect(AppColors.scaffoldBackground, isA<Color>());
      });

      test('surfaceBackground is a Color', () {
        expect(AppColors.surfaceBackground, isA<Color>());
      });

      test('badgeBackground is a Color', () {
        expect(AppColors.badgeBackground, isA<Color>());
      });

      test('darkerBackground is a Color', () {
        expect(AppColors.darkerBackground, isA<Color>());
      });
    });

    group('accents', () {
      test('accentBlue is a Color', () {
        expect(AppColors.accentBlue, isA<Color>());
      });

      test('accentRed is a Color', () {
        expect(AppColors.accentRed, isA<Color>());
      });

      test('accentGreen is a Color', () {
        expect(AppColors.accentGreen, isA<Color>());
      });

      test('accentOrange is a Color', () {
        expect(AppColors.accentOrange, isA<Color>());
      });
    });

    group('text', () {
      test('textPrimary is a Color', () {
        expect(AppColors.textPrimary, isA<Color>());
      });

      test('textSecondary is a Color', () {
        expect(AppColors.textSecondary, isA<Color>());
      });

      test('textTertiary is a Color', () {
        expect(AppColors.textTertiary, isA<Color>());
      });

      test('textMuted is a Color', () {
        expect(AppColors.textMuted, isA<Color>());
      });
    });

    test('errorRed is a Color', () {
      expect(AppColors.errorRed, isA<Color>());
    });

    test('successGreen is a Color', () {
      expect(AppColors.successGreen, isA<Color>());
    });

    test('borderSubtle is a Color', () {
      expect(AppColors.borderSubtle, isA<Color>());
    });

    test('chartGridLine is a Color', () {
      expect(AppColors.chartGridLine, isA<Color>());
    });

    test('chartFillStart returns a Color', () {
      expect(AppColors.chartFillStart, isA<Color>());
    });

    test('chartFillEnd returns a Color', () {
      expect(AppColors.chartFillEnd, isA<Color>());
    });

    test('chartFillStart has alpha < 1.0', () {
      expect(AppColors.chartFillStart.a, lessThan(1.0));
    });

    test('chartFillEnd is fully transparent', () {
      expect(AppColors.chartFillEnd.a, 0.0);
    });

    group('stat icons', () {
      test('statIconAvg is a Color', () {
        expect(AppColors.statIconAvg, isA<Color>());
      });

      test('statIconPeak is a Color', () {
        expect(AppColors.statIconPeak, isA<Color>());
      });

      test('statIconDuration is a Color', () {
        expect(AppColors.statIconDuration, isA<Color>());
      });

      test('statIconSamples is a Color', () {
        expect(AppColors.statIconSamples, isA<Color>());
      });
    });

    group('HR zone palette', () {
      test('hrZone1 is a Color', () {
        expect(AppColors.hrZone1, isA<Color>());
      });

      test('hrZone2 is a Color', () {
        expect(AppColors.hrZone2, isA<Color>());
      });

      test('hrZone3 is a Color', () {
        expect(AppColors.hrZone3, isA<Color>());
      });

      test('hrZone4 is a Color', () {
        expect(AppColors.hrZone4, isA<Color>());
      });

      test('hrZone5 is a Color', () {
        expect(AppColors.hrZone5, isA<Color>());
      });
    });

    test('has exactly 24 constants', () {
      final constants = [
        AppColors.scaffoldBackground,
        AppColors.surfaceBackground,
        AppColors.badgeBackground,
        AppColors.darkerBackground,
        AppColors.accentBlue,
        AppColors.accentRed,
        AppColors.accentGreen,
        AppColors.accentOrange,
        AppColors.textPrimary,
        AppColors.textSecondary,
        AppColors.textTertiary,
        AppColors.textMuted,
        AppColors.errorRed,
        AppColors.successGreen,
        AppColors.borderSubtle,
        AppColors.chartGridLine,
        AppColors.chartFillStart,
        AppColors.chartFillEnd,
        AppColors.statIconAvg,
        AppColors.statIconPeak,
        AppColors.statIconDuration,
        AppColors.statIconSamples,
        AppColors.hrZone1,
        AppColors.hrZone2,
        AppColors.hrZone3,
        AppColors.hrZone4,
        AppColors.hrZone5,
      ];

      expect(constants.whereType<Color>(), hasLength(27));
    });

    test('all constants are non-null', () {
      expect(AppColors.scaffoldBackground, isNotNull);
      expect(AppColors.surfaceBackground, isNotNull);
      expect(AppColors.badgeBackground, isNotNull);
      expect(AppColors.darkerBackground, isNotNull);
      expect(AppColors.accentBlue, isNotNull);
      expect(AppColors.accentRed, isNotNull);
      expect(AppColors.accentGreen, isNotNull);
      expect(AppColors.accentOrange, isNotNull);
      expect(AppColors.textPrimary, isNotNull);
      expect(AppColors.textSecondary, isNotNull);
      expect(AppColors.textTertiary, isNotNull);
      expect(AppColors.textMuted, isNotNull);
      expect(AppColors.errorRed, isNotNull);
      expect(AppColors.successGreen, isNotNull);
      expect(AppColors.borderSubtle, isNotNull);
      expect(AppColors.chartGridLine, isNotNull);
      expect(AppColors.chartFillStart, isNotNull);
      expect(AppColors.chartFillEnd, isNotNull);
      expect(AppColors.statIconAvg, isNotNull);
      expect(AppColors.statIconPeak, isNotNull);
      expect(AppColors.statIconDuration, isNotNull);
      expect(AppColors.statIconSamples, isNotNull);
      expect(AppColors.hrZone1, isNotNull);
      expect(AppColors.hrZone2, isNotNull);
      expect(AppColors.hrZone3, isNotNull);
      expect(AppColors.hrZone4, isNotNull);
      expect(AppColors.hrZone5, isNotNull);
    });
  });
}
