import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_file_share_flutter/models/peer_device.dart';
import 'package:offline_file_share_flutter/models/share_file.dart';
import 'package:offline_file_share_flutter/models/transfer_item.dart';
import 'package:offline_file_share_flutter/screens/send_flow_screen.dart';
import 'package:offline_file_share_flutter/services/file_selection_service.dart';
import 'package:offline_file_share_flutter/services/transport_service.dart';
import 'package:offline_file_share_flutter/state/app_state.dart';

import 'test_doubles.dart';

void main() {
  testWidgets('send flow picks files and starts transfer', (tester) async {
    final transferService = FakeTransferService();
    final appState = AppState(
      transportService: transferService,
      fileSelectionService: FakeFileSelectionService(
        selectedFiles: const [
          ShareFile(name: 'demo.pdf', sizeBytes: 2048),
        ],
      ),
    );

    await appState.refreshDiscovery();

    await tester.pumpWidget(
      MaterialApp(home: SendFlowScreen(appState: appState)),
    );

    await tester.tap(find.text('Select files'));
    await tester.pumpAndSettle();
    expect(find.text('demo.pdf'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(RadioListTile<PeerDevice>).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start transfer'));
    await tester.pumpAndSettle();

    expect(appState.transfers, isNotEmpty);
    expect(appState.transfers.first.status, anyOf(TransferStatus.active, TransferStatus.completed));
  });
}
