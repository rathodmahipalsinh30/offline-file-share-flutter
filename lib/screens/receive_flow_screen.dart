import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../widgets/filesize_text.dart';

class ReceiveFlowScreen extends StatelessWidget {
  const ReceiveFlowScreen({required this.appState, super.key});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Receive Files')),
      body: AnimatedBuilder(
        animation: appState,
        builder: (context, _) {
          final incoming = appState.pendingIncomingRequest;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: SwitchListTile(
                  title: const Text('Discoverable'),
                  subtitle: const Text('Allow nearby senders to request transfers'),
                  value: appState.discoverable,
                  onChanged: appState.updateDiscoverable,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Pairing token', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                        ),
                        child: Text(
                          appState.pairingToken,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text('TODO: replace token placeholder with QR pairing from native transport layer.'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Nearby sender status', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      if (incoming == null)
                        const Text('Listening for incoming requests...')
                      else ...[
                        Text('Sender: ${incoming.sender.name}'),
                        const SizedBox(height: 6),
                        ...incoming.files.map(
                          (file) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(file.name),
                            subtitle: FileSizeText(file.sizeBytes),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            FilledButton(
                              onPressed: () => appState.respondToIncoming(accept: true),
                              child: const Text('Accept'),
                            ),
                            OutlinedButton(
                              onPressed: () => appState.respondToIncoming(accept: false),
                              child: const Text('Reject'),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
