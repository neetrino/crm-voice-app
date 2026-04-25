import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import 'history_page.dart';
import 'record_page.dart';

class RecorderShellPage extends StatefulWidget {
  const RecorderShellPage({
    super.key,
    required this.apiClient,
    required this.onLogout,
  });

  final ApiClient apiClient;
  final VoidCallback onLogout;

  @override
  State<RecorderShellPage> createState() => _RecorderShellPageState();
}

class _RecorderShellPageState extends State<RecorderShellPage> {
  int _index = 0;
  int _historyRefreshSignal = 0;

  void _selectTab(int value) {
    setState(() {
      _index = value;
      if (value == 1) _historyRefreshSignal++;
    });
  }

  void _refreshHistory() {
    setState(() => _historyRefreshSignal++);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      RecordPage(
        apiClient: widget.apiClient,
        onRecordingUploaded: _refreshHistory,
      ),
      HistoryPage(
        apiClient: widget.apiClient,
        refreshSignal: _historyRefreshSignal,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: widget.onLogout,
            tooltip: 'Դուրս գալ',
            color: const Color(0xFF252D46),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _selectTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.mic_none),
            selectedIcon: Icon(Icons.mic),
            label: 'Ձայնագրում',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            selectedIcon: Icon(Icons.history),
            label: 'Պատմություն',
          ),
        ],
      ),
    );
  }
}
