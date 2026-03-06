import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ss_preventer/ss_preventer.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const SsPreventerExamplePage(),
      theme: ThemeData(useMaterial3: true),
    );
  }
}

class SsPreventerExamplePage extends StatefulWidget {
  const SsPreventerExamplePage({super.key});

  @override
  State<SsPreventerExamplePage> createState() => _SsPreventerExamplePageState();
}

class _SsPreventerExamplePageState extends State<SsPreventerExamplePage>
    with WidgetsBindingObserver {
  bool _isPreventEnabled = false;
  bool _isDetectionEnabled = false;
  bool _restorePreventOnResume = false;
  StreamSubscription? _subscription;
  final List<String> _logs = <String>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _subscription = SsPreventer.screenshotStream.listen((event) {
      final message = 'Screenshot detected: ${event.detectedAt.toLocal()}';
      if (!mounted) {
        return;
      }
      setState(() {
        _logs.insert(0, message);
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _subscription?.cancel();
    SsPreventer.preventOff();
    SsPreventer.setDetectionEnabled(false);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _restorePreventOnResume) {
      unawaited(SsPreventer.preventOn());
      _restorePreventOnResume = false;
      _isPreventEnabled = true;
      _logs.insert(0, 'Prevention restored after closing in-app browser');
    }
    setState(() {
      _logs.insert(0, 'Lifecycle: $state');
    });
  }

  Future<void> _togglePrevent(bool nextValue) async {
    if (nextValue) {
      await SsPreventer.preventOn();
    } else {
      await SsPreventer.preventOff();
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isPreventEnabled = nextValue;
      _logs.insert(0, 'Prevention: ${nextValue ? 'ON' : 'OFF'}');
    });
  }

  Future<void> _toggleDetection(bool nextValue) async {
    await SsPreventer.setDetectionEnabled(nextValue);

    if (!mounted) {
      return;
    }

    setState(() {
      _isDetectionEnabled = nextValue;
      _logs.insert(0, 'Detection: ${nextValue ? 'ON' : 'OFF'}');
    });
  }

  Future<void> _openInAppBrowser() async {
    const url = 'https://example.com';
    final uri = Uri.parse(url);
    final wasPreventEnabled = _isPreventEnabled;
    if (wasPreventEnabled) {
      await SsPreventer.preventOff();
    }

    final success = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    _restorePreventOnResume = wasPreventEnabled && success;
    if (wasPreventEnabled && !success) {
      await SsPreventer.preventOn();
      _restorePreventOnResume = false;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      if (wasPreventEnabled && success) {
        _isPreventEnabled = false;
        _logs.insert(
          0,
          'Prevention temporarily OFF while in-app browser is open',
        );
      }
      _logs.insert(
        0,
        success
            ? 'Opened in-app browser: $url'
            : 'Failed to open in-app browser: $url',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ss_preventer example')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Prevent Screenshot'),
              value: _isPreventEnabled,
              onChanged: _togglePrevent,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Detect Screenshot'),
              value: _isDetectionEnabled,
              onChanged: _toggleDetection,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.tonal(
                onPressed: _openInAppBrowser,
                child: const Text('Open In-App Browser'),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Event Logs',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _logs.isEmpty
                    ? const Center(child: Text('No events yet.'))
                    : ListView.builder(
                        itemCount: _logs.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            dense: true,
                            title: Text(_logs[index]),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
