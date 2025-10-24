import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'notification_service.dart';

class Issue {
  final String id;
  final String title;
  final String description;
  final String severity; // 'low', 'medium', 'high', 'critical'
  final DateTime detectedAt;
  final bool resolved;

  Issue({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.detectedAt,
    this.resolved = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'severity': severity,
    'detectedAt': detectedAt.toIso8601String(),
    'resolved': resolved,
  };

  factory Issue.fromJson(Map<String, dynamic> json) => Issue(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    severity: json['severity'],
    detectedAt: DateTime.parse(json['detectedAt']),
    resolved: json['resolved'] ?? false,
  );
}

class ScanResult {
  final DateTime scanTime;
  final List<Issue> issues;
  final int junkFilesFound;
  final int virusesFound;
  final bool batteryIssue;
  final bool overheating;

  ScanResult({
    required this.scanTime,
    required this.issues,
    this.junkFilesFound = 0,
    this.virusesFound = 0,
    this.batteryIssue = false,
    this.overheating = false,
  });
}

class ScanService {
  static late SharedPreferences _prefs;
  static const String _scanHistoryKey = 'scan_history';
  static const String _lastScanKey = 'last_scan';
  
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<ScanResult> performFullScan() async {
    List<Issue> issues = [];
    int junkFilesFound = 0;
    int virusesFound = 0;
    bool batteryIssue = false;
    bool overheating = false;

    // Simulate device health checks
    final deviceInfo = await _getDeviceInfo();
    final battery = Battery();
    final batteryLevel = await battery.batteryLevel;

    // Check battery health
    if (batteryLevel < 20) {
      issues.add(Issue(
        id: 'battery_low',
        title: 'Low Battery',
        description: 'Your battery is running low. Consider charging your device.',
        severity: 'medium',
        detectedAt: DateTime.now(),
      ));
    }

    // Simulate junk file detection
    junkFilesFound = (DateTime.now().millisecondsSinceEpoch % 100) + 10;
    if (junkFilesFound > 50) {
      issues.add(Issue(
        id: 'junk_files',
        title: 'Junk Files Found',
        description: 'Found $junkFilesFound junk files that can be cleaned.',
        severity: 'low',
        detectedAt: DateTime.now(),
      ));
    }

    // Simulate virus scan
    virusesFound = DateTime.now().second % 5; // 0-4 viruses
    if (virusesFound > 0) {
      issues.add(Issue(
        id: 'virus_detected',
        title: 'Virus Detected',
        description: 'Found $virusesFound potentially harmful files.',
        severity: 'high',
        detectedAt: DateTime.now(),
      ));
    }

    // Simulate overheating detection
    if (DateTime.now().minute % 3 == 0) { // Every 3 minutes simulate overheating
      overheating = true;
      issues.add(Issue(
        id: 'overheating',
        title: 'Device Overheating',
        description: 'Your device temperature is high. Close background apps.',
        severity: 'high',
        detectedAt: DateTime.now(),
      ));
    }

    // Simulate battery drain issue
    if (batteryLevel > 80 && DateTime.now().hour > 20) {
      batteryIssue = true;
      issues.add(Issue(
        id: 'battery_drain',
        title: 'Battery Drain Detected',
        description: 'Unusual battery drain detected. Check running apps.',
        severity: 'medium',
        detectedAt: DateTime.now(),
      ));
    }

    final result = ScanResult(
      scanTime: DateTime.now(),
      issues: issues,
      junkFilesFound: junkFilesFound,
      virusesFound: virusesFound,
      batteryIssue: batteryIssue,
      overheating: overheating,
    );

    // Save scan result
    await _saveScanResult(result);

    // Send notifications for critical issues
    for (final issue in issues) {
      if (issue.severity == 'high' || issue.severity == 'critical') {
        await NotificationService.showNotification(
          title: 'Mobile Issue Detected',
          body: '${issue.title}: ${issue.description}',
        );
      }
    }

    return result;
  }

  static Future<Map<String, dynamic>> _getDeviceInfo() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    final deviceInfo = await deviceInfoPlugin.deviceInfo;
    return deviceInfo.data;
  }

  static Future<void> _saveScanResult(ScanResult result) async {
    final scanData = {
      'scanTime': result.scanTime.toIso8601String(),
      'issues': result.issues.map((issue) => issue.toJson()).toList(),
      'junkFilesFound': result.junkFilesFound,
      'virusesFound': result.virusesFound,
      'batteryIssue': result.batteryIssue,
      'overheating': result.overheating,
    };

    final history = _prefs.getStringList(_scanHistoryKey) ?? [];
    history.add(jsonEncode(scanData));
    
    // Keep only last 50 scans
    if (history.length > 50) {
      history.removeAt(0);
    }

    await _prefs.setStringList(_scanHistoryKey, history);
    await _prefs.setString(_lastScanKey, jsonEncode(scanData));
  }

  static Future<List<ScanResult>> getScanHistory() async {
    final history = _prefs.getStringList(_scanHistoryKey) ?? [];
    return history.map((scanJson) {
      final scanData = jsonDecode(scanJson);
      return ScanResult(
        scanTime: DateTime.parse(scanData['scanTime']),
        issues: (scanData['issues'] as List)
            .map((issueJson) => Issue.fromJson(issueJson))
            .toList(),
        junkFilesFound: scanData['junkFilesFound'] ?? 0,
        virusesFound: scanData['virusesFound'] ?? 0,
        batteryIssue: scanData['batteryIssue'] ?? false,
        overheating: scanData['overheating'] ?? false,
      );
    }).toList().reversed.toList();
  }

  static Future<ScanResult?> getLastScan() async {
    final lastScanJson = _prefs.getString(_lastScanKey);
    if (lastScanJson == null) return null;

    final scanData = jsonDecode(lastScanJson);
    return ScanResult(
      scanTime: DateTime.parse(scanData['scanTime']),
      issues: (scanData['issues'] as List)
          .map((issueJson) => Issue.fromJson(issueJson))
          .toList(),
      junkFilesFound: scanData['junkFilesFound'] ?? 0,
      virusesFound: scanData['virusesFound'] ?? 0,
      batteryIssue: scanData['batteryIssue'] ?? false,
      overheating: scanData['overheating'] ?? false,
    );
  }

  static Future<void> cleanJunkFiles() async {
    // Simulate cleaning junk files
    await Future.delayed(const Duration(seconds: 2));
    // In real implementation, this would use platform-specific code
    await NotificationService.showNotification(
      title: 'Cleanup Complete',
      body: 'Junk files have been successfully removed!',
    );
  }

  static Future<void> removeViruses() async {
    // Simulate virus removal
    await Future.delayed(const Duration(seconds: 3));
    await NotificationService.showNotification(
      title: 'Virus Removal Complete',
      body: 'All detected viruses have been removed!',
    );
  }

  static Future<void> optimizeBattery() async {
    // Simulate battery optimization
    await Future.delayed(const Duration(seconds: 2));
    await NotificationService.showNotification(
      title: 'Battery Optimized',
      body: 'Battery performance has been optimized!',
    );
  }

  static Future<void> coolDownDevice() async {
    // Simulate device cooling
    await Future.delayed(const Duration(seconds: 2));
    await NotificationService.showNotification(
      title: 'Device Cooled',
      body: 'Device temperature has been normalized!',
    );
  }
}
