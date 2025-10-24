import 'package:flutter/material.dart';
import 'package:battery_plus/battery_plus.dart';
import '../services/scan_service.dart';
import '../services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ScanResult? _lastScan;
  BatteryState _batteryState = BatteryState.unknown;
  int _batteryLevel = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _setupBatteryMonitoring();
  }

  Future<void> _loadData() async {
    final lastScan = await ScanService.getLastScan();
    setState(() {
      _lastScan = lastScan;
      _isLoading = false;
    });
  }

  Future<void> _setupBatteryMonitoring() async {
    final battery = Battery();
    
    // Get initial battery level
    final level = await battery.batteryLevel;
    setState(() {
      _batteryLevel = level;
    });

    // Listen to battery state changes
    battery.onBatteryStateChanged.listen((BatteryState state) {
      setState(() {
        _batteryState = state;
      });
    });
  }

  Future<void> _quickScan() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ScanService.performFullScan();
      setState(() {
        _lastScan = result;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quick scan completed!')),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
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
        title: const Text('Mobile Doctor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Navigate to notifications screen (to be implemented)
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Device Status Card
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Device Status',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Battery Level:'),
                              Text('$_batteryLevel%'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Status:'),
                              Text(_getBatteryStateText()),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _quickScan,
                            child: const Text('Quick Scan'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Last Scan Results
                  if (_lastScan != null) ...[
                    const Text(
                      'Last Scan Results',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildScanSummary(_lastScan!),
                  ],

                  const SizedBox(height: 20),

                  // Quick Actions
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: [
                      _buildQuickActionCard(
                        'Clean Junk',
                        Icons.cleaning_services,
                        Colors.green,
                        () async {
                          await ScanService.cleanJunkFiles();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Junk files cleaned!')),
                          );
                        },
                      ),
                      _buildQuickActionCard(
                        'Remove Viruses',
                        Icons.security,
                        Colors.red,
                        () async {
                          await ScanService.removeViruses();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Viruses removed!')),
                          );
                        },
                      ),
                      _buildQuickActionCard(
                        'Optimize Battery',
                        Icons.battery_charging_full,
                        Colors.blue,
                        () async {
                          await ScanService.optimizeBattery();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Battery optimized!')),
                          );
                        },
                      ),
                      _buildQuickActionCard(
                        'Cool Device',
                        Icons.ac_unit,
                        Colors.cyan,
                        () async {
                          await ScanService.coolDownDevice();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Device cooled!')),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  String _getBatteryStateText() {
    switch (_batteryState) {
      case BatteryState.charging:
        return 'Charging';
      case BatteryState.discharging:
        return 'Discharging';
      case BatteryState.full:
        return 'Full';
      default:
        return 'Unknown';
    }
  }

  Widget _buildScanSummary(ScanResult scan) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Scanned: ${scan.scanTime.toString().split('.')[0]}'),
            const SizedBox(height: 8),
            Text('Issues Found: ${scan.issues.length}'),
            Text('Junk Files: ${scan.junkFilesFound}'),
            Text('Viruses: ${scan.virusesFound}'),
            if (scan.batteryIssue) const Text('Battery Issue: Yes'),
            if (scan.overheating) const Text('Overheating: Yes'),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    ),
    );
  }
}