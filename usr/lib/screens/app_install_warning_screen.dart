import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class AppInstallWarningScreen extends StatelessWidget {
  const AppInstallWarningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Safety Check'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Installing App...',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Before installing this app, Mobile Doctor will scan it for potential security risks.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Security Analysis',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.security, color: Colors.green),
                        const SizedBox(width: 8),
                        const Text('Permission Check: Scanning...'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.verified_user, color: Colors.green),
                        const SizedBox(width: 8),
                        const Text('Virus Scan: Scanning...'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.privacy_tip, color: Colors.green),
                        const SizedBox(width: 8),
                        const Text('Privacy Analysis: Scanning...'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Simulate app analysis
                      _showAnalysisResult(context, true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Safe to Install'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _showAnalysisResult(context, false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Risk Detected'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAnalysisResult(BuildContext context, bool isSafe) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isSafe ? 'App is Safe' : 'Security Risk Detected'),
        content: Text(
          isSafe
              ? 'This app appears to be safe to install. No security risks detected.'
              : 'This app may contain security risks. We recommend not installing it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

// This would typically be called from a system-level hook
// For demo purposes, it's a separate screen
class AppInstallInterceptor {
  static Future<bool> checkAppSafety(String appPath) async {
    // In a real implementation, this would analyze the APK/IPA file
    // For now, we'll simulate the check
    await Future.delayed(const Duration(seconds: 2));
    
    // Simulate random safety check (80% safe, 20% risky)
    return (DateTime.now().millisecondsSinceEpoch % 5) != 0;
  }

  static Future<void> showInstallWarning(BuildContext context, String appPath) async {
    final isSafe = await checkAppSafety(appPath);
    
    if (!isSafe) {
      // Show warning dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Security Warning'),
          content: const Text(
            'This app has been flagged as potentially harmful. '
            'It may contain malware or request excessive permissions. '
            'Do you still want to install it?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Proceed with installation (in real app)
              },
              child: const Text('Install Anyway'),
            ),
          ],
        ),
      );
    }
  }
}