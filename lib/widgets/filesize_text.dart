import 'package:flutter/widgets.dart';

class FileSizeText extends StatelessWidget {
  const FileSizeText(this.bytes, {super.key});

  final int bytes;

  @override
  Widget build(BuildContext context) {
    return Text(_formatBytes(bytes));
  }

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
