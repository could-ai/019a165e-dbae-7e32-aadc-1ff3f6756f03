import 'package:flutter/material.dart';
import '../services/scan_service.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with TickerProviderStateMixin {
  bool _isScanning = false;
  ScanResult? _scanResult;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _startFullScan() async {
    setState(() {
      _isScanning = true;
      _scanResult = null;
    });

    try {
      final result = await ScanService.performFullScan();
      setState(() {
        _scanResult = result;
        _isScanning = false;
      });
    } catch (e) {
      setState(() {
        _isScanning = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Scan failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Full System Scan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_isScanning) ...[
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _animation.value,
                            child: const Icon(
                              Icons.search,
                              size: 100,
                              color: Colors.blue,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Scanning your device...',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      const LinearProgressIndicator(),
                    ],
                  ),
                ),
              ),
            ] else if (_scanResult != null) ...[
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Scan Complete!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildScanResults(_scanResult!),
                      const SizedBox(height: 20),
                      _buildIssuesList(_scanResult!.issues),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.health_and_safety,
                        size: 100,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Ready to scan your device',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'This will check for issues, junk files, viruses, and performance problems.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _startFullScan,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        ),
                        child: const Text('Start Full Scan'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScanResults(ScanResult result) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Scan Summary',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Issues Found:'),
                Text('${result.issues.length}'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Junk Files:'),
                Text('${result.junkFilesFound}'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Viruses Detected:'),
                Text('${result.virusesFound}'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Battery Issues:'),
                Text(result.batteryIssue ? 'Yes' : 'No'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Overheating:'),
                Text(result.overheating ? 'Yes' : 'No'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIssuesList(List<Issue> issues) {
    if (issues.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'No issues found! Your device is healthy.',
            style: TextStyle(color: Colors.green, fontSize: 16),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detected Issues',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...issues.map((issue) => Card(
          color: _getSeverityColor(issue.severity),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  issue.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(issue.description),
                const SizedBox(height: 8),
                Text(
                  'Severity: ${issue.severity.toUpperCase()}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'low':
        return Colors.yellow.shade100;
      case 'medium':
        return Colors.orange.shade100;
      case 'high':
        return Colors.red.shade100;
      case 'critical':
        return Colors.red.shade200;
      default:
        return Colors.grey.shade100;
    }
  }
}