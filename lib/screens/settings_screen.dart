import 'package:flutter/material.dart';

import '../state/app_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({required this.appState, super.key});

  final AppState appState;

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
                title: const Text('Device name'),
                subtitle: Text(appState.deviceName),
                trailing: IconButton(
                  tooltip: 'Edit device name',
                  onPressed: () => _showDeviceNameDialog(context),
                  icon: const Icon(Icons.edit_rounded),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: SwitchListTile(
                title: const Text('Discoverable'),
                subtitle: const Text('Visible to nearby senders'),
                value: appState.discoverable,
                onChanged: appState.updateDiscoverable,
              ),
            ),
            Card(
              child: SwitchListTile(
                title: const Text('Auto-accept transfers'),
                subtitle: const Text('Automatically accept incoming requests (demo only)'),
                value: appState.autoAccept,
                onChanged: appState.updateAutoAccept,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                title: const Text('Theme mode'),
                subtitle: Text(appState.themeMode.name),
                trailing: DropdownButton<ThemeMode>(
                  value: appState.themeMode,
                  items: const [
                    DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                    DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                    DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                  ],
                  onChanged: (mode) {
                    if (mode != null) appState.updateThemeMode(mode);
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                title: const Text('Storage location'),
                subtitle: Text(appState.storageLocation),
                trailing: DropdownButton<String>(
                  value: appState.storageLocation,
                  items: const [
                    DropdownMenuItem(
                      value: 'Default Downloads',
                      child: Text('Default Downloads'),
                    ),
                    DropdownMenuItem(
                      value: 'Internal App Storage',
                      child: Text('Internal App Storage'),
                    ),
                    DropdownMenuItem(
                      value: 'Ask every time',
                      child: Text('Ask every time'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) appState.updateStorageLocation(value);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeviceNameDialog(BuildContext context) async {
    final controller = TextEditingController(text: appState.deviceName);
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set device name'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Device name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                appState.updateDeviceName(controller.text);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
