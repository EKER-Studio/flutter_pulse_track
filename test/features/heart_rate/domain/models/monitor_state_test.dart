import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_track/features/heart_rate/domain/models/body_sensor_location.dart';
import 'package:pulse_track/features/heart_rate/domain/models/hr_measurement.dart';
import 'package:pulse_track/features/heart_rate/domain/models/monitor_state.dart';

// ── Helpers ────────────────────────────────────────────────────────────────

HrMeasurement _measurement({int bpm = 72}) {
  return HrMeasurement(
    bpm: bpm,
    rrIntervals: [],
    timestamp: DateTime(2026, 7, 23, 14, 30, 0),
    sensorLocation: BodySensorLocation.unknown,
  );
}

// ── Tests ──────────────────────────────────────────────────────────────────

void main() {
  group('MonitorState.disconnected', () {
    test('creates DisconnectedMonitorState', () {
      final state = MonitorState.disconnected();
      expect(state, isA<DisconnectedMonitorState>());
      expect(state, isA<MonitorState>());
    });
  });

  group('MonitorState.connecting', () {
    test('creates ConnectingMonitorState', () {
      final state = MonitorState.connecting();
      expect(state, isA<ConnectingMonitorState>());
      expect(state, isA<MonitorState>());
    });
  });

  group('MonitorState.discoveringServices', () {
    test('creates DiscoveringServicesMonitorState', () {
      final state = MonitorState.discoveringServices();
      expect(state, isA<DiscoveringServicesMonitorState>());
      expect(state, isA<MonitorState>());
    });
  });

  group('MonitorState.connected', () {
    test('creates ConnectedMonitorState with measurement', () {
      final m = _measurement(bpm: 120);
      final state = MonitorState.connected(measurement: m);
      expect(state, isA<ConnectedMonitorState>());
      expect(state, isA<MonitorState>());
    });

    test('exposes the measurement', () {
      final m = _measurement(bpm: 85);
      final state = MonitorState.connected(measurement: m);
      final connected = state as ConnectedMonitorState;
      expect(connected.measurement.bpm, 85);
    });
  });

  group('MonitorState.failure', () {
    test('creates FailureMonitorState with message', () {
      final state = MonitorState.failure(message: 'Connection timed out');
      expect(state, isA<FailureMonitorState>());
      expect(state, isA<MonitorState>());
    });

    test('exposes the error message', () {
      final state = MonitorState.failure(message: 'Device not found');
      final failure = state as FailureMonitorState;
      expect(failure.message, 'Device not found');
    });
  });

  group('exhaustive switch', () {
    test('covers all five states', () {
      int classify(MonitorState s) => switch (s) {
        DisconnectedMonitorState _ => 0,
        ConnectingMonitorState _ => 1,
        DiscoveringServicesMonitorState _ => 2,
        ConnectedMonitorState _ => 3,
        FailureMonitorState _ => 4,
      };

      expect(classify(MonitorState.disconnected()), 0);
      expect(classify(MonitorState.connecting()), 1);
      expect(classify(MonitorState.discoveringServices()), 2);
      expect(classify(MonitorState.connected(measurement: _measurement())), 3);
      expect(classify(MonitorState.failure(message: 'x')), 4);
    });
  });

  group('runtime type identity', () {
    test('disconnected is not connecting', () {
      expect(
        MonitorState.disconnected().runtimeType,
        isNot(MonitorState.connecting().runtimeType),
      );
    });

    test('connected with different measurements is same type', () {
      final a = MonitorState.connected(measurement: _measurement(bpm: 60));
      final b = MonitorState.connected(measurement: _measurement(bpm: 80));
      expect(a.runtimeType, b.runtimeType);
    });

    test('failure with different messages is same type', () {
      final a = MonitorState.failure(message: 'err1');
      final b = MonitorState.failure(message: 'err2');
      expect(a.runtimeType, b.runtimeType);
    });
  });
}