import 'package:flutter/material.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin System Configuration')),
      body: Center(
        child: Text('Manage system settings, users, and teams.'),
      ),
    );
  }
}
