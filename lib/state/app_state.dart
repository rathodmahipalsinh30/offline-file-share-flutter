import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../models/peer_device.dart';
import '../models/share_file.dart';
import '../models/transfer_item.dart';
import '../services/file_selection_service.dart';
import '../services/transport_service.dart';

enum DiscoveryState { loading, ready, error }

class AppState extends ChangeNotifier {
  AppState({
    required this.transportService,
    required this.fileSelectionService,
  }) {
    _incomingSubscription = transportService.incomingRequests.listen((request) {
      pendingIncomingRequest = request;
      pairingToken = request.pairingToken;
      notifyListeners();
    });
  }

  final TransferService transportService;
  final FileSelectionService fileSelectionService;

  final List<TransferItem> _transfers = [];
  final List<PeerDevice> _nearbyPeers = [];
  StreamSubscription<IncomingTransferRequest>? _incomingSubscription;

  DiscoveryState discoveryState = DiscoveryState.loading;
  String? discoveryError;

  IncomingTransferRequest? pendingIncomingRequest;
  String pairingToken = _createPairingToken();

  String deviceName = 'My Device';
  bool discoverable = true;
  bool autoAccept = false;
  ThemeMode themeMode = ThemeMode.system;
  String storageLocation = 'Default Downloads';

  List<PeerDevice> get nearbyPeers => List.unmodifiable(_nearbyPeers);
  List<TransferItem> get transfers => List.unmodifiable(_transfers);

  List<TransferItem> get recentActivity {
    final copy = List<TransferItem>.from(_transfers);
    copy.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return copy.take(4).toList(growable: false);
  }

  Future<void> initialize() async {
    await refreshDiscovery();
  }

  Future<void> refreshDiscovery() async {
    discoveryState = DiscoveryState.loading;
    discoveryError = null;
    notifyListeners();

    try {
      final peers = await transportService.discoverPeers();
      _nearbyPeers
        ..clear()
        ..addAll(peers);
      discoveryState = DiscoveryState.ready;
    } catch (error) {
      discoveryState = DiscoveryState.error;
      discoveryError = error.toString();
    }

    notifyListeners();
  }

  Future<String?> startSendTransfer({
    required PeerDevice peer,
    required List<ShareFile> files,
  }) async {
    if (files.isEmpty) {
      return null;
    }

    final totalBytes = files.fold<int>(0, (sum, file) => sum + file.sizeBytes);
    final transferId = await transportService.startTransfer(peer: peer, files: files);

    _transfers.insert(
      0,
      TransferItem(
        id: transferId,
        peer: peer,
        files: files,
        totalBytes: totalBytes,
        transferredBytes: 0,
        status: TransferStatus.active,
        direction: TransferDirection.sending,
        startedAt: DateTime.now(),
      ),
    );
    notifyListeners();

    unawaited(_listenTransferUpdates(transferId));
    return transferId;
  }

  Future<void> _listenTransferUpdates(String transferId) async {
    await for (final update in transportService.watchTransfer(transferId)) {
      final index = _transfers.indexWhere((transfer) => transfer.id == transferId);
      if (index == -1) continue;

      final finished = update.status == TransferStatus.completed || update.status == TransferStatus.failed;
      _transfers[index] = _transfers[index].copyWith(
        transferredBytes: update.transferredBytes,
        status: update.status,
        endedAt: finished ? DateTime.now() : null,
        errorMessage: update.errorMessage,
      );
      notifyListeners();
    }
  }

  Future<void> respondToIncoming({required bool accept}) async {
    final request = pendingIncomingRequest;
    if (request == null) return;

    await transportService.respondToIncomingRequest(
      requestId: request.requestId,
      accept: accept,
    );

    if (!accept) {
      _transfers.insert(
        0,
        TransferItem(
          id: 'rx_${DateTime.now().millisecondsSinceEpoch}',
          peer: request.sender,
          files: request.files,
          totalBytes: request.files.fold<int>(0, (sum, file) => sum + file.sizeBytes),
          transferredBytes: 0,
          status: TransferStatus.rejected,
          direction: TransferDirection.receiving,
          startedAt: DateTime.now(),
          endedAt: DateTime.now(),
          errorMessage: 'Request rejected by receiver.',
        ),
      );
      pendingIncomingRequest = null;
      notifyListeners();
      return;
    }

    final total = request.files.fold<int>(0, (sum, file) => sum + file.sizeBytes);
    final transferId = 'rx_${DateTime.now().millisecondsSinceEpoch}';
    _transfers.insert(
      0,
      TransferItem(
        id: transferId,
        peer: request.sender,
        files: request.files,
        totalBytes: total,
        transferredBytes: 0,
        status: TransferStatus.active,
        direction: TransferDirection.receiving,
        startedAt: DateTime.now(),
      ),
    );
    pendingIncomingRequest = null;
    notifyListeners();

    var progress = 0;
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      final index = _transfers.indexWhere((transfer) => transfer.id == transferId);
      if (index == -1) {
        timer.cancel();
        return;
      }

      progress = min(progress + max(total ~/ 7, 1024 * 100), total);
      final complete = progress >= total;
      _transfers[index] = _transfers[index].copyWith(
        transferredBytes: progress,
        status: complete ? TransferStatus.completed : TransferStatus.active,
        endedAt: complete ? DateTime.now() : null,
      );
      notifyListeners();

      if (complete) {
        timer.cancel();
      }
    });
  }

  void updateDeviceName(String value) {
    deviceName = value.trim().isEmpty ? 'My Device' : value.trim();
    notifyListeners();
  }

  void updateDiscoverable(bool value) {
    discoverable = value;
    notifyListeners();
  }

  void updateAutoAccept(bool value) {
    autoAccept = value;
    notifyListeners();
  }

  void updateThemeMode(ThemeMode value) {
    themeMode = value;
    notifyListeners();
  }

  void updateStorageLocation(String value) {
    storageLocation = value;
    notifyListeners();
  }

  static String _createPairingToken() {
    const charset = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    final chars = List.generate(6, (_) => charset[random.nextInt(charset.length)]);
    return chars.join();
  }

  @override
  void dispose() {
    _incomingSubscription?.cancel();
    transportService.dispose();
    super.dispose();
  }
}
