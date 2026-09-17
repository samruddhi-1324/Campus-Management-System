import 'package:flutter/material.dart';

class AuditLogsScreen extends StatelessWidget {
  const AuditLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('System Audit Logs')),
      body: const Center(
        child: Text('Immutable audit log entries (FR-1.27).'),
      ),
    );
  }
}
