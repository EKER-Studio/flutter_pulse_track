import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_track/core/integrations/widgets/widget_sync_service.dart';
import 'package:pulse_track/features/workout/domain/models/workout_session.dart';

const MethodChannel _homeWidgetChannel = MethodChannel('home_widget');

WorkoutSession _session({
  int id = 1,
  DateTime? start,
  DateTime? end,
  int avgBpm = 120,
  int maxBpm = 150,
  List<int> samples = const [110, 120, 130],
  String deviceName = 'Polar H10',
}) {
  final startTime = start ?? DateTime(2026, 7, 28, 10);
  return WorkoutSession(
    id: id,
    startTime: startTime,
    endTime: end ?? startTime.add(const Duration(minutes: 90)),
    avgBpm: avgBpm,
    maxBpm: maxBpm,
    bpmSamples: samples,
    sensorLocationIndex: 1,
    deviceMacAddress: 'AA:BB:CC:DD:EE:FF',
    deviceName: deviceName,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final List<MethodCall> widgetCalls = [];

  setUp(() {
    widgetCalls.clear();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_homeWidgetChannel, (call) async {
          widgetCalls.add(call);
          return true;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_homeWidgetChannel, null);
  });

  Map<String, Object?> savedData() {
    final data = <String, Object?>{};
    for (final call in widgetCalls.where((c) => c.method == 'saveWidgetData')) {
      final args = call.arguments as Map;
      data[args['id'] as String] = args['data'];
    }
    return data;
  }

  group('WidgetSyncService.initialize', () {
    test('sets the app group id', () async {
      await WidgetSyncService.instance.initialize();

      final calls = widgetCalls.where((c) => c.method == 'setAppGroupId');
      expect(calls, hasLength(1));
      expect(calls.single.arguments, {'groupId': WidgetSyncService.appGroupId});
    });
  });

  group('WidgetSyncService.updateWidgetData', () {
    test('writes empty-state placeholders when no sessions exist', () async {
      await WidgetSyncService.instance.updateWidgetData(sessions: []);

      final data = savedData();
      expect(data['has_data'], isFalse);
      expect(data['avg_bpm'], '--');
      expect(data['max_bpm'], '--');
      expect(data['duration'], '--');
      expect(data['samples_count'], 0);
      expect(widgetCalls.any((c) => c.method == 'updateWidget'), isTrue);
    });

    test('pushes the latest session by start time', () async {
      final older = _session(
        start: DateTime(2026, 7, 27, 10),
        deviceName: 'Old Strap',
      );
      final latest = _session(id: 2, start: DateTime(2026, 7, 28, 10));

      await WidgetSyncService.instance.updateWidgetData(
        sessions: [latest, older],
      );

      final data = savedData();
      expect(data['has_data'], isTrue);
      expect(data['avg_bpm'], '120');
      expect(data['max_bpm'], '150');
      expect(data['device_name'], 'Polar H10');
      expect(data['samples_count'], 3);
    });

    test('formats 90-minute duration as hours and minutes', () async {
      await WidgetSyncService.instance.updateWidgetData(sessions: [_session()]);

      expect(savedData()['duration'], '1h 30m');
    });

    test('formats sub-minute duration as seconds', () async {
      final start = DateTime(2026, 7, 28, 10);
      await WidgetSyncService.instance.updateWidgetData(
        sessions: [
          _session(start: start, end: start.add(const Duration(seconds: 45))),
        ],
      );

      expect(savedData()['duration'], '45s');
    });

    test('formats minute-range duration as minutes and seconds', () async {
      final start = DateTime(2026, 7, 28, 10);
      await WidgetSyncService.instance.updateWidgetData(
        sessions: [
          _session(start: start, end: start.add(const Duration(seconds: 90))),
        ],
      );

      expect(savedData()['duration'], '1m 30s');
    });

    test('treats missing endTime as zero duration', () async {
      final session = WorkoutSession(
        id: 1,
        startTime: DateTime(2026, 7, 28, 10),
        endTime: null,
        avgBpm: 100,
        maxBpm: 110,
        bpmSamples: const [100],
        sensorLocationIndex: 0,
        deviceMacAddress: 'AA:BB',
        deviceName: 'Strap',
      );

      await WidgetSyncService.instance.updateWidgetData(sessions: [session]);

      expect(savedData()['duration'], '0s');
    });
  });
}
