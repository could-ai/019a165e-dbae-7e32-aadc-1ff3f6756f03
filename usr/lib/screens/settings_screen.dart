import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _dailyScanEnabled = true;
  bool _autoCleanEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // In a real app, load these from shared preferences
    setState(() {
      _notificationsEnabled = true;
      _dailyScanEnabled = true;
      _autoCleanEnabled = false;
    });
  }

  Future<void> _requestPermissions() async {
    final status = await Permission.notification.request();
    if (status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification permission granted')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification permission denied')),
      );
    }
  }

  Future<void> _toggleDailyScan(bool value) async {
    setState(() {
      _dailyScanEnabled = value;
    });

    if (value) {
      await NotificationService.scheduleDailyScan();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Daily scan scheduled for 9 AM')),
      );
    } else {
      // In a real implementation, cancel the scheduled notification
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Daily scan disabled')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          // Permissions Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Permissions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          ListTile(
            title: const Text('Notification Permission'),
            subtitle: const Text('Allow app to send notifications about device issues'),
            trailing: ElevatedButton(
              onPressed: _requestPermissions,
              child: const Text('Grant'),
            ),
          ),
          const Divider(),

          // Scan Settings
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Scan Settings',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Daily Scan'),
            subtitle: const Text('Automatically scan device every day at 9 AM'),
            value: _dailyScanEnabled,
            onChanged: _toggleDailyScan,
          ),
          SwitchListTile(
            title: const Text('Auto Clean'),
            subtitle: const Text('Automatically clean junk files when found'),
            value: _autoCleanEnabled,
            onChanged: (value) {
              setState(() {
                _autoCleanEnabled = value;
              });
            },
          ),
          const Divider(),

          // Notification Settings
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Notifications',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Issue Notifications'),
            subtitle: const Text('Get notified when device issues are detected'),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          const Divider(),

          // About Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'About',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          ListTile(
            title: const Text('Version'),
            subtitle: const Text('1.0.0'),
          ),
          ListTile(
            title: const Text('About Mobile Doctor'),
            subtitle: const Text('Your device\'s health companion'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('About Mobile Doctor'),
                  content: const Text(
                    'Mobile Doctor helps you keep your device healthy by detecting issues, '
                    'cleaning junk files, removing viruses, and optimizing performance. '
                    'Stay informed about your device\'s health with regular scans and notifications.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}