import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_file_share_flutter/app.dart';
import 'package:offline_file_share_flutter/services/file_selection_service.dart';
import 'package:offline_file_share_flutter/services/transport_service.dart';
import 'package:offline_file_share_flutter/state/app_state.dart';

import 'test_doubles.dart';

void main() {
  testWidgets('bottom navigation switches between screens', (tester) async {
    final appState = AppState(
      transportService: FakeTransferService(),
      fileSelectionService: FakeFileSelectionService(),
    );

    await tester.pumpWidget(OfflineShareApp(appState: appState));

    expect(find.text('Offline Share'), findsOneWidget);

    await tester.tap(find.text('Transfers'));
    await tester.pumpAndSettle();
    expect(find.text('No transfers yet.'), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Device name'), findsOneWidget);
  });
}
