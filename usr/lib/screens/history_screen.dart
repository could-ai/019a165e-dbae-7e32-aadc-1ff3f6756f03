import 'package:flutter/material.dart';
import '../services/scan_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<ScanResult> _scanHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadScanHistory();
  }

  Future<void> _loadScanHistory() async {
    final history = await ScanService.getScanHistory();
    setState(() {
      _scanHistory = history;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadScanHistory,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _scanHistory.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No scan history yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Perform your first scan to see results here',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _scanHistory.length,
                  itemBuilder: (context, index) {
                    final scan = _scanHistory[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 2,
                      child: ExpansionTile(
                        title: Text(
                          'Scan ${index + 1}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          scan.scanTime.toString().split('.')[0],
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Issues Found:'),
                                    Text('${scan.issues.length}'),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Junk Files:'),
                                    Text('${scan.junkFilesFound}'),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Viruses:'),
                                    Text('${scan.virusesFound}'),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Battery Issue:'),
                                    Text(scan.batteryIssue ? 'Yes' : 'No'),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Overheating:'),
                                    Text(scan.overheating ? 'Yes' : 'No'),
                                  ],
                                ),
                                if (scan.issues.isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Issues:',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  ...scan.issues.map((issue) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: _getSeverityColor(issue.severity),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            issue.title,
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          Text(issue.description),
                                          Text(
                                            'Severity: ${issue.severity.toUpperCase()}',
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
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