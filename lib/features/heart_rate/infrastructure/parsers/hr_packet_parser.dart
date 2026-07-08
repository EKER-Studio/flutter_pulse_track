import 'dart:typed_data';

import '../../domain/models/hr_measurement.dart';

/// Low-level binary parser responsible for decoding raw Bluetooth GATT Heart Rate Measurement packets (0x2A37).
class HrPacketParser {
  /// Parses raw byte data from a BLE heart rate characteristic into a domain [HrMeasurement].
  ///
  /// Conforms strictly to the Bluetooth SIG Heart Rate Profile specification,
  /// handling both 8-bit and 16-bit BPM representations and extracting R-R intervals (scaled to seconds).
  static HrMeasurement? parseRawBytes(List<int> rawData) {
    if (rawData.isEmpty) return null;

    // Optimize allocation: use views where possible, fallback to copy if it's a standard GrowableList
    final Uint8List bytesList = rawData is Uint8List
        ? rawData
        : Uint8List.fromList(rawData);
    final byteData = ByteData.sublistView(bytesList);
    int currentOffset = 0;

    final int flags = byteData.getUint8(currentOffset);
    currentOffset += 1;

    final bool isHeartRate16Bit = (flags & 0x01) != 0;
    final bool hasRrIntervals = (flags & 0x10) != 0;

    int bpm;
    if (isHeartRate16Bit) {
      if (byteData.lengthInBytes < currentOffset + 2) return null;
      bpm = byteData.getUint16(currentOffset, Endian.little);
      currentOffset += 2;
    } else {
      if (byteData.lengthInBytes < currentOffset + 1) return null;
      bpm = byteData.getUint8(currentOffset);
      currentOffset += 1;
    }

    final List<double> rrIntervals = [];
    if (hasRrIntervals) {
      while (currentOffset + 2 <= byteData.lengthInBytes) {
        final int rawRr = byteData.getUint16(currentOffset, Endian.little);
        // Bluetooth SIG standard: R-R interval value is exported as 1/1024 of a second
        rrIntervals.add(rawRr / 1024.0);
        currentOffset += 2;
      }
    }

    return HrMeasurement(
      bpm: bpm,
      rrIntervals: rrIntervals,
      timestamp: DateTime.now(),
    );
  }
}
