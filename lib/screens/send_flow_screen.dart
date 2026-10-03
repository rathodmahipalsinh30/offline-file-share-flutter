import 'package:flutter/material.dart';

import '../models/peer_device.dart';
import '../models/share_file.dart';
import '../models/transfer_item.dart';
import '../state/app_state.dart';
import '../widgets/filesize_text.dart';

class SendFlowScreen extends StatefulWidget {
  const SendFlowScreen({required this.appState, super.key});

  final AppState appState;

  @override
  State<SendFlowScreen> createState() => _SendFlowScreenState();
}

class _SendFlowScreenState extends State<SendFlowScreen> {
  int _currentStep = 0;
  String? _error;
  String? _transferId;
  PeerDevice? _selectedPeer;
  final List<ShareFile> _selectedFiles = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send Files')),
      body: AnimatedBuilder(
        animation: widget.appState,
        builder: (context, _) {
          final transfer = _transferId == null
              ? null
              : widget.appState.transfers.firstWhere(
                  (item) => item.id == _transferId,
                  orElse: () => _emptyTransfer,
                );

          return Stepper(
            currentStep: _currentStep,
            controlsBuilder: (context, details) {
              return Wrap(
                spacing: 8,
                children: [
                  if (_currentStep < 2)
                    FilledButton(
                      onPressed: details.onStepContinue,
                      child: const Text('Next'),
                    ),
                  if (_currentStep > 0)
                    OutlinedButton(
                      onPressed: details.onStepCancel,
                      child: const Text('Back'),
                    ),
                ],
              );
            },
            onStepContinue: _handleContinue,
            onStepCancel: () {
              setState(() {
                _error = null;
                if (_currentStep > 0) _currentStep -= 1;
              });
            },
            steps: [
              Step(
                title: const Text('Choose files'),
                isActive: _currentStep >= 0,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FilledButton.icon(
                      onPressed: _pickFiles,
                      icon: const Icon(Icons.upload_file_rounded),
                      label: const Text('Select files'),
                    ),
                    const SizedBox(height: 8),
                    if (_selectedFiles.isEmpty)
                      const Text('No files selected yet.')
                    else
                      ..._selectedFiles.map(
                        (file) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(file.name),
                          subtitle: FileSizeText(file.sizeBytes),
                          trailing: IconButton(
                            tooltip: 'Remove file',
                            onPressed: () {
                              setState(() {
                                _selectedFiles.remove(file);
                              });
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Step(
                title: const Text('Select recipient'),
                isActive: _currentStep >= 1,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.appState.discoveryState == DiscoveryState.loading)
                      const CircularProgressIndicator()
                    else if (widget.appState.nearbyPeers.isEmpty)
                      const Text('No nearby peers available.')
                    else
                      ...widget.appState.nearbyPeers.map(
                        (peer) => RadioListTile<PeerDevice>(
                          value: peer,
                          groupValue: _selectedPeer,
                          onChanged: (value) {
                            setState(() => _selectedPeer = value);
                          },
                          title: Text(peer.name),
                          subtitle: Text(peer.availability.name),
                        ),
                      ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: widget.appState.refreshDiscovery,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Refresh peers'),
                      ),
                    ),
                  ],
                ),
              ),
              Step(
                title: const Text('Confirm and send'),
                isActive: _currentStep >= 2,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Files: ${_selectedFiles.length}'),
                    Text('Peer: ${_selectedPeer?.name ?? 'None selected'}'),
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: transfer?.status == TransferStatus.active ? null : _startTransfer,
                      icon: const Icon(Icons.send_rounded),
                      label: const Text('Start transfer'),
                    ),
                    if (transfer != null) ...[
                      const SizedBox(height: 12),
                      Text('Status: ${transfer.status.name}'),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(value: transfer.progress),
                      const SizedBox(height: 4),
                      Text('${(transfer.progress * 100).toStringAsFixed(0)}%'),
                      if (transfer.status == TransferStatus.failed && transfer.errorMessage != null)
                        Text('Error: ${transfer.errorMessage}'),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: _error == null
          ? null
          : Material(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer)),
              ),
            ),
    );
  }

  Future<void> _pickFiles() async {
    final files = await widget.appState.fileSelectionService.pickFiles();
    if (!mounted) return;
    setState(() {
      _selectedFiles
        ..clear()
        ..addAll(files);
      _error = files.isEmpty ? 'No files selected.' : null;
    });
  }

  Future<void> _startTransfer() async {
    if (_selectedPeer == null || _selectedFiles.isEmpty) {
      setState(() => _error = 'Select files and a recipient first.');
      return;
    }

    final transferId = await widget.appState.startSendTransfer(
      peer: _selectedPeer!,
      files: _selectedFiles,
    );

    if (!mounted) return;
    setState(() {
      _transferId = transferId;
      _error = null;
    });
  }

  void _handleContinue() {
    setState(() {
      _error = null;
      if (_currentStep == 0 && _selectedFiles.isEmpty) {
        _error = 'Choose at least one file to continue.';
        return;
      }
      if (_currentStep == 1 && _selectedPeer == null) {
        _error = 'Pick a nearby recipient to continue.';
        return;
      }
      if (_currentStep < 2) _currentStep += 1;
    });
  }

  TransferItem get _emptyTransfer => TransferItem(
        id: 'none',
        peer: const PeerDevice(id: 'none', name: 'Unknown', availability: PeerAvailability.offline),
        files: const [],
        totalBytes: 1,
        transferredBytes: 0,
        status: TransferStatus.pending,
        direction: TransferDirection.sending,
        startedAt: DateTime.now(),
      );
}
