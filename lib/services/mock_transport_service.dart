import 'dart:async';
import 'dart:math';

import '../models/peer_device.dart';
import '../models/share_file.dart';
import '../models/transfer_item.dart';
import 'transport_service.dart';

class MockTransportService implements TransferService {
  MockTransportService() {
    _incomingTimer = Timer.periodic(
      const Duration(seconds: 20),
      (_) => _emitIncomingRequest(),
    );
  }

  final _random = Random(7);
  final _progressControllers = <String, StreamController<TransferProgressUpdate>>{};
  final _incomingController = StreamController<IncomingTransferRequest>.broadcast();

  Timer? _incomingTimer;
  int _transferCounter = 0;

  @override
  Stream<IncomingTransferRequest> get incomingRequests => _incomingController.stream;

  @override
  Future<List<PeerDevice>> discoverPeers() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return const [
      PeerDevice(id: 'peer_1', name: 'Pixel 8 Pro', availability: PeerAvailability.available),
      PeerDevice(id: 'peer_2', name: 'Galaxy Tab', availability: PeerAvailability.busy),
      PeerDevice(id: 'peer_3', name: 'Windows Laptop', availability: PeerAvailability.available),
    ];
  }

  @override
  Future<String> startTransfer({
    required PeerDevice peer,
    required List<ShareFile> files,
  }) async {
    final id = 'tx_${DateTime.now().millisecondsSinceEpoch}_${_transferCounter++}';
    final totalBytes = files.fold<int>(0, (total, file) => total + file.sizeBytes);
    final controller = StreamController<TransferProgressUpdate>.broadcast();
    _progressControllers[id] = controller;

    var transferredBytes = 0;
    Timer.periodic(const Duration(milliseconds: 700), (timer) {
      if (!controller.hasListener) {
        return;
      }

      final chunk = max(totalBytes ~/ 8, 1024 * 128);
      transferredBytes = min(transferredBytes + chunk, totalBytes);

      final shouldFail = _random.nextInt(100) < 5 && transferredBytes < totalBytes;
      if (shouldFail) {
        controller.add(
          TransferProgressUpdate(
            transferredBytes: transferredBytes,
            totalBytes: totalBytes,
            status: TransferStatus.failed,
            errorMessage: 'Mock transport dropped connection. TODO: replace with native transport.',
          ),
        );
        timer.cancel();
        controller.close();
        _progressControllers.remove(id);
        return;
      }

      if (transferredBytes >= totalBytes) {
        controller.add(
          TransferProgressUpdate(
            transferredBytes: totalBytes,
            totalBytes: totalBytes,
            status: TransferStatus.completed,
          ),
        );
        timer.cancel();
        controller.close();
        _progressControllers.remove(id);
        return;
      }

      controller.add(
        TransferProgressUpdate(
          transferredBytes: transferredBytes,
          totalBytes: totalBytes,
          status: TransferStatus.active,
        ),
      );
    });

    return id;
  }

  @override
  Stream<TransferProgressUpdate> watchTransfer(String transferId) {
    final controller = _progressControllers[transferId];
    if (controller == null) {
      return Stream<TransferProgressUpdate>.value(
        const TransferProgressUpdate(
          transferredBytes: 0,
          totalBytes: 0,
          status: TransferStatus.failed,
          errorMessage: 'Transfer was not found.',
        ),
      );
    }

    return controller.stream;
  }

  @override
  Future<void> respondToIncomingRequest({
    required String requestId,
    required bool accept,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }

  void _emitIncomingRequest() {
    final request = IncomingTransferRequest(
      requestId: 'incoming_${DateTime.now().millisecondsSinceEpoch}',
      sender: const PeerDevice(
        id: 'peer_sender',
        name: 'Nearby Sender',
        availability: PeerAvailability.available,
      ),
      files: const [
        ShareFile(name: 'Vacation_Photo.jpg', sizeBytes: 1942090),
        ShareFile(name: 'Song.mp3', sizeBytes: 6291456),
      ],
      pairingToken: _generatePairingToken(),
    );
    _incomingController.add(request);
  }

  String _generatePairingToken() {
    const charset = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final chars = List.generate(6, (_) => charset[_random.nextInt(charset.length)]);
    return chars.join();
  }

  @override
  void dispose() {
    _incomingTimer?.cancel();
    for (final controller in _progressControllers.values) {
      controller.close();
    }
    _progressControllers.clear();
    _incomingController.close();
  }
}
