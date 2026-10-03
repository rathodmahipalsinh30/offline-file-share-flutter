import 'package:flutter/material.dart';

import '../models/transfer_item.dart';
import '../state/app_state.dart';
import '../widgets/filesize_text.dart';

class TransfersScreen extends StatelessWidget {
  const TransfersScreen({required this.appState, super.key});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        if (appState.transfers.isEmpty) {
          return const Center(child: Text('No transfers yet.')); 
        }

        final active = appState.transfers.where((item) => item.status == TransferStatus.active).toList();
        final completed = appState.transfers.where((item) => item.status == TransferStatus.completed).toList();
        final failed = appState.transfers.where((item) {
          return item.status == TransferStatus.failed || item.status == TransferStatus.rejected;
        }).toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _TransferSection(title: 'Active', items: active),
            _TransferSection(title: 'Completed', items: completed),
            _TransferSection(title: 'Failed / Rejected', items: failed),
          ],
        );
      },
    );
  }
}

class _TransferSection extends StatelessWidget {
  const _TransferSection({required this.title, required this.items});

  final String title;
  final List<TransferItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Card(
          child: ListTile(title: Text(title), subtitle: const Text('No items')),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              ...items.map((item) => _TransferTile(item: item)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransferTile extends StatelessWidget {
  const _TransferTile({required this.item});

  final TransferItem item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        item.direction == TransferDirection.sending
            ? Icons.north_east_rounded
            : Icons.south_west_rounded,
      ),
      title: Text(item.peer.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${item.files.length} file(s)'),
          FileSizeText(item.totalBytes),
          const SizedBox(height: 4),
          LinearProgressIndicator(value: item.progress),
        ],
      ),
      trailing: Text(item.status.name),
      onTap: () {
        showModalBottomSheet<void>(
          context: context,
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Transfer ${item.id}', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('Peer: ${item.peer.name}'),
                  Text('Direction: ${item.direction.name}'),
                  Text('Status: ${item.status.name}'),
                  Text('Started: ${item.startedAt}'),
                  if (item.endedAt != null) Text('Ended: ${item.endedAt}'),
                  if (item.errorMessage != null) Text('Error: ${item.errorMessage}'),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
