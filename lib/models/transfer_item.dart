import 'peer_device.dart';
import 'share_file.dart';

enum TransferStatus { pending, active, completed, failed, rejected }
enum TransferDirection { sending, receiving }

class TransferItem {
  const TransferItem({
    required this.id,
    required this.peer,
    required this.files,
    required this.totalBytes,
    required this.transferredBytes,
    required this.status,
    required this.direction,
    required this.startedAt,
    this.endedAt,
    this.errorMessage,
  });

  final String id;
  final PeerDevice peer;
  final List<ShareFile> files;
  final int totalBytes;
  final int transferredBytes;
  final TransferStatus status;
  final TransferDirection direction;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String? errorMessage;

  double get progress {
    if (totalBytes <= 0) return 0;
    return (transferredBytes / totalBytes).clamp(0, 1);
  }

  TransferItem copyWith({
    int? transferredBytes,
    TransferStatus? status,
    DateTime? endedAt,
    String? errorMessage,
  }) {
    return TransferItem(
      id: id,
      peer: peer,
      files: files,
      totalBytes: totalBytes,
      transferredBytes: transferredBytes ?? this.transferredBytes,
      status: status ?? this.status,
      direction: direction,
      startedAt: startedAt,
      endedAt: endedAt ?? this.endedAt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
