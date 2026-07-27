import 'hr_measurement.dart';

/// Sealed union representing every possible state in the active BLE connection
/// and heart rate monitoring lifecycle.
///
/// The UI performs an exhaustive switch over these states to render the
/// appropriate screen — from the initial idle screen to the live telemetry
/// dashboard and the error recovery screen — without any nullable fields.
///
/// State transition diagram:
///
/// ```
///  disconnected ──(connect)──▶ connecting ──▶ discoveringServices
///       ▲                           │                   │
///       │                           │(timeout/error)    │(timeout/error)
///       │◀────────(disconnect)──────┘                   ▼
///       │                                           failure
///       │                                               │
///       │◀──────────────────────────(retry)─────────────┘
///       │
///       └──────────────────────────────────────────▶ connected(measurement)
///                                                        │
///                                                        │(stream events)
///                                                        ▼
///                                                   connected(measurement)
/// ```
sealed class MonitorState {
  /// Abstract base constructor for [MonitorState].
  const MonitorState();

  /// No active connection exists and no operation is pending.
  const factory MonitorState.disconnected() = DisconnectedMonitorState;

  /// The physical BLE link-layer handshake is in progress (≤ 4 s).
  const factory MonitorState.connecting() = ConnectingMonitorState;

  /// The physical link is established; GATT service discovery is running (≤ 5 s).
  const factory MonitorState.discoveringServices() =
      DiscoveringServicesMonitorState;

  /// Service discovery succeeded and GATT notifications are active.
  /// [measurement] holds the most recently parsed heart rate packet.
  factory MonitorState.connected({required HrMeasurement measurement}) =
      ConnectedMonitorState;

  /// A non-recoverable error occurred during connection or streaming.
  /// [message] is a human-readable string suitable for the recovery screen CTA.
  const factory MonitorState.failure({required String message}) =
      FailureMonitorState;
}

// ---------------------------------------------------------------------------
// Concrete state implementations (public, for exhaustive switch matching).
// ---------------------------------------------------------------------------

/// The monitor is idle; no connection is active.
final class DisconnectedMonitorState extends MonitorState {
  /// Creates a [DisconnectedMonitorState] instance.
  const DisconnectedMonitorState();
}

/// Physical BLE link-layer handshake is in flight.
final class ConnectingMonitorState extends MonitorState {
  /// Creates a [ConnectingMonitorState] instance.
  const ConnectingMonitorState();
}

/// BLE link is established; GATT discovery is running against the sensor.
final class DiscoveringServicesMonitorState extends MonitorState {
  /// Creates a [DiscoveringServicesMonitorState] instance.
  const DiscoveringServicesMonitorState();
}

/// GATT notifications are live; [measurement] contains the latest HR packet.
final class ConnectedMonitorState extends MonitorState {
  /// The most recently decoded heart rate measurement from the BLE sensor.
  final HrMeasurement measurement;

  /// Creates a [ConnectedMonitorState] instance with the given [measurement].
  const ConnectedMonitorState({required this.measurement});
}

/// An error terminated the connection or stream; [message] drives the recovery UI.
final class FailureMonitorState extends MonitorState {
  /// Human-readable error detail for the "Retry" recovery screen.
  final String message;

  /// Creates a [FailureMonitorState] instance with the given error [message].
  const FailureMonitorState({required this.message});
}
