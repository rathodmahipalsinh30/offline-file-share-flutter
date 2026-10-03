import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../widgets/filesize_text.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required this.appState,
    required this.onSendPressed,
    required this.onReceivePressed,
    super.key,
  });

  final AppState appState;
  final VoidCallback onSendPressed;
  final VoidCallback onReceivePressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.wifi_tethering_rounded, size: 34),
                title: const Text('Offline Share'),
                subtitle: const Text('Secure nearby file sharing prototype'),
                trailing: Tooltip(
                  message: 'Refresh nearby devices',
                  child: IconButton(
                    onPressed: appState.refreshDiscovery,
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _DiscoveryStatusCard(appState: appState),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onSendPressed,
                    icon: const Icon(Icons.send_rounded),
                    label: const Text('Send Files'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onReceivePressed,
                    icon: const Icon(Icons.download_rounded),
                    label: const Text('Receive Files'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Pairing Token', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.qr_code_2_rounded, size: 42),
                          const SizedBox(height: 6),
                          Text(
                            appState.pairingToken,
                            semanticsLabel: 'Pairing token ${appState.pairingToken}',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 4),
                          const Text('Share this code with the sender'),
                        ],
                      ),
                    ),
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
                    if (appState.pendingIncomingRequest == null)
                      const Text('No incoming transfer requests.')
                    else ...[
                      Text('Sender: ${appState.pendingIncomingRequest!.sender.name}'),
                      const SizedBox(height: 4),
                      Text('${appState.pendingIncomingRequest!.files.length} files pending'),
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
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Recent activity', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    if (appState.recentActivity.isEmpty)
                      const Text('No transfers yet. Send or receive files to see activity.')
                    else
                      ...appState.recentActivity.map(
                        (transfer) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            transfer.direction.name == 'sending'
                                ? Icons.north_east_rounded
                                : Icons.south_west_rounded,
                          ),
                          title: Text(transfer.files.first.name),
                          subtitle: FileSizeText(transfer.totalBytes),
                          trailing: Text(transfer.status.name.toUpperCase()),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DiscoveryStatusCard extends StatelessWidget {
  const _DiscoveryStatusCard({required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nearby discovery', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            switch (appState.discoveryState) {
              DiscoveryState.loading => const Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text('Scanning for devices...'),
                  ],
                ),
              DiscoveryState.error => Text('Error: ${appState.discoveryError ?? 'Unknown error'}'),
              DiscoveryState.ready when appState.nearbyPeers.isEmpty =>
                const Text('No nearby devices found. Try again.'),
              DiscoveryState.ready => Text('${appState.nearbyPeers.length} nearby device(s) available.'),
            },
          ],
        ),
      ),
    );
  }
}
