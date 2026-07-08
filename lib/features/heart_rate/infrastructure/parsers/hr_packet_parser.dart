import 'dart:typed_data';
import '../../domain/models/hr_measurement.dart';

class HrPacketParser {
  static HrMeasurement? parseRawBytes(List<int> rawData) {
    if (rawData.isEmpty) return null;

    final byteData = ByteData.sublistView(Uint8List.fromList(rawData));
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