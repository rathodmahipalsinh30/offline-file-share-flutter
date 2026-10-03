import '../models/peer_device.dart';
import '../models/share_file.dart';
import '../models/transfer_item.dart';

class TransferProgressUpdate {
  const TransferProgressUpdate({
    required this.transferredBytes,
    required this.totalBytes,
    required this.status,
    this.errorMessage,
  });

  final int transferredBytes;
  final int totalBytes;
  final TransferStatus status;
  final String? errorMessage;
}

class IncomingTransferRequest {
  const IncomingTransferRequest({
    required this.requestId,
    required this.sender,
    required this.files,
    required this.pairingToken,
  });

  final String requestId;
  final PeerDevice sender;
  final List<ShareFile> files;
  final String pairingToken;
}

abstract class TransferService {
  Future<List<PeerDevice>> discoverPeers();

  Future<String> startTransfer({
    required PeerDevice peer,
    required List<ShareFile> files,
  });

  Stream<TransferProgressUpdate> watchTransfer(String transferId);

  Stream<IncomingTransferRequest> get incomingRequests;

  Future<void> respondToIncomingRequest({
    required String requestId,
    required bool accept,
  });

  void dispose() {}
}
