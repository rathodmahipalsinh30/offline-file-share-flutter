import 'dart:async';

import 'package:offline_file_share_flutter/models/peer_device.dart';
import 'package:offline_file_share_flutter/models/share_file.dart';
import 'package:offline_file_share_flutter/models/transfer_item.dart';
import 'package:offline_file_share_flutter/services/file_selection_service.dart';
import 'package:offline_file_share_flutter/services/transport_service.dart';

class FakeFileSelectionService implements FileSelectionService {
  FakeFileSelectionService({this.selectedFiles = const []});

  final List<ShareFile> selectedFiles;

  @override
  Future<List<ShareFile>> pickFiles() async => selectedFiles;
}

class FakeTransferService implements TransferService {
  final _incomingController = StreamController<IncomingTransferRequest>.broadcast();

  @override
  Stream<IncomingTransferRequest> get incomingRequests => _incomingController.stream;

  @override
  Future<List<PeerDevice>> discoverPeers() async {
    return const [
      PeerDevice(id: 'peer-1', name: 'Test Device', availability: PeerAvailability.available),
    ];
  }

  @override
  Future<void> respondToIncomingRequest({required String requestId, required bool accept}) async {}

  @override
  Future<String> startTransfer({required PeerDevice peer, required List<ShareFile> files}) async {
    return 'test-transfer';
  }

  @override
  Stream<TransferProgressUpdate> watchTransfer(String transferId) async* {
    yield const TransferProgressUpdate(
      transferredBytes: 1024,
      totalBytes: 1024,
      status: TransferStatus.completed,
    );
  }

  @override
  void dispose() {
    _incomingController.close();
  }
}
