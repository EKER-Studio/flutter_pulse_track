import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse_track/features/heart_rate/application/ble_providers.dart';
import 'package:pulse_track/features/heart_rate/domain/models/body_sensor_location.dart';
import 'package:pulse_track/features/heart_rate/presentation/controllers/gatt_profile_resolver.dart';

class _MockHeartRateMonitorService extends Mock
    implements HeartRateMonitorService {}

class _MockBluetoothService extends Mock implements BluetoothService {}

class _MockBluetoothCharacteristic extends Mock
    implements BluetoothCharacteristic {}

class _MockCharacteristicProperties extends Mock
    implements CharacteristicProperties {}

void main() {
  late _MockHeartRateMonitorService mockService;
  late GattProfileResolver resolver;

  setUp(() {
    mockService = _MockHeartRateMonitorService();
    resolver = GattProfileResolver(mockService);
  });

  group('GattProfileResolver', () {
    test('readBodySensorLocation returns chest for byte value 1', () async {
      final mockHrService = _MockBluetoothService();
      final mockLocationChar = _MockBluetoothCharacteristic();

      when(() => mockLocationChar.characteristicUuid).thenReturn(Guid('2a38'));
      when(() => mockHrService.characteristics).thenReturn([mockLocationChar]);
      when(() => mockService.read(mockLocationChar))
          .thenAnswer((_) async => [1]);

      final location = await resolver.readBodySensorLocation(mockHrService);
      expect(location, BodySensorLocation.chest);
    });

    test(
      'readBodySensorLocation returns unknown when characteristic not found',
      () async {
        final mockHrService = _MockBluetoothService();
        when(() => mockHrService.characteristics).thenReturn([]);

        final location = await resolver.readBodySensorLocation(mockHrService);
        expect(location, BodySensorLocation.unknown);
      },
    );

    test(
      'resolveBatteryService returns nulls when battery service is missing',
      () async {
        final services = <BluetoothService>[];

        final result = await resolver.resolveBatteryService(
          services,
          onLevelChanged: (_) {},
        );

        expect(result.initialLevel, isNull);
        expect(result.subscription, isNull);
      },
    );

    test(
      'resolveBatteryService reads initial level when battery service exists',
      () async {
        final mockBatteryService = _MockBluetoothService();
        final mockBatteryChar = _MockBluetoothCharacteristic();
        final mockProperties = _MockCharacteristicProperties();

        when(() => mockBatteryService.serviceUuid).thenReturn(Guid('180f'));
        when(() => mockBatteryChar.characteristicUuid).thenReturn(Guid('2a19'));
        when(() => mockBatteryService.characteristics)
            .thenReturn([mockBatteryChar]);
        when(() => mockBatteryChar.properties).thenReturn(mockProperties);
        when(() => mockProperties.notify).thenReturn(false);
        when(() => mockProperties.indicate).thenReturn(false);
        when(() => mockService.read(mockBatteryChar))
            .thenAnswer((_) async => [85]);

        final result = await resolver.resolveBatteryService([
          mockBatteryService,
        ], onLevelChanged: (_) {});

        expect(result.initialLevel, 85);
        expect(result.subscription, isNull);
      },
    );
  });
}
