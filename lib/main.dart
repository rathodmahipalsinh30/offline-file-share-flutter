import 'package:flutter/material.dart';

import 'app.dart';
import 'services/file_selection_service.dart';
import 'services/mock_transport_service.dart';
import 'state/app_state.dart';

void main() {
  final appState = AppState(
    transportService: MockTransportService(),
    fileSelectionService: FilePickerSelectionService(),
  )..initialize();

  runApp(OfflineShareApp(appState: appState));
}
