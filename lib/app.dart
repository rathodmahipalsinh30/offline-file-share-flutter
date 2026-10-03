import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/receive_flow_screen.dart';
import 'screens/send_flow_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/transfers_screen.dart';
import 'state/app_state.dart';

class OfflineShareApp extends StatelessWidget {
  const OfflineShareApp({required this.appState, super.key});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        return MaterialApp(
          title: 'Offline Share',
          debugShowCheckedModeBanner: false,
          themeMode: appState.themeMode,
          theme: ThemeData(
            colorSchemeSeed: Colors.teal,
            useMaterial3: true,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            colorSchemeSeed: Colors.teal,
            useMaterial3: true,
            brightness: Brightness.dark,
          ),
          home: AppShell(appState: appState),
        );
      },
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({required this.appState, super.key});

  final AppState appState;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(
        appState: widget.appState,
        onSendPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => SendFlowScreen(appState: widget.appState),
            ),
          );
        },
        onReceivePressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ReceiveFlowScreen(appState: widget.appState),
            ),
          );
        },
      ),
      TransfersScreen(appState: widget.appState),
      SettingsScreen(appState: widget.appState),
    ];

    return Scaffold(
      body: SafeArea(child: pages[_currentIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.swap_horiz_rounded),
            label: 'Transfers',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}
