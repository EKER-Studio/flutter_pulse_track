import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_track/core/infrastructure/storage/isar_provider.dart';

void main() {
  group('isarProvider', () {
    test('throws ProviderException wrapping UnimplementedError when read before override', () {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      expect(
        () => container.read(isarProvider),
        throwsA(
          isA<ProviderException>().having(
            (e) => e.exception,
            'exception',
            isA<UnimplementedError>().having(
              (e) => e.message ?? '',
              'message',
              contains('must be overridden'),
            ),
          ),
        ),
      );
    });

    test('ProviderException mentions isarProvider', () {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      try {
        container.read(isarProvider);
      } on Object catch (e) {
        expect(e.toString(), contains('isarProvider'));
      }
    });

    test('ProviderException mentions UnimplementedError', () {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      try {
        container.read(isarProvider);
      } on Object catch (e) {
        expect(e.toString(), contains('UnimplementedError'));
      }
    });
  });
}
