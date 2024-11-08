import 'dart:math';
import 'dart:typed_data';

class FileSizeCalculator {
  /// Converts bytes to human readable file size
  static String getFileSize(Uint8List data, {int decimals = 1}) {
    int bytes = data.lengthInBytes;
    if (bytes <= 0) return "0 B";

    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();

    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  /// Gets size in specific unit
  static double getSizeInUnit(Uint8List data, String unit) {
    int bytes = data.lengthInBytes;
    switch (unit.toUpperCase()) {
      case 'B':
        return bytes.toDouble();
      case 'KB':
        return bytes / 1024;
      case 'MB':
        return bytes / (1024 * 1024);
      case 'GB':
        return bytes / (1024 * 1024 * 1024);
      default:
        throw ArgumentError('Unsupported unit: $unit');
    }
  }
}
