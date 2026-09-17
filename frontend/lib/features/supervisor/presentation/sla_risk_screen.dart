import 'package:flutter/material.dart';

class SlaRiskScreen extends StatelessWidget {
  const SlaRiskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SLA Risk & Escalations')),
      body: const Center(
        child: Text('Issues at risk of missing expected resolution window.'),
      ),
    );
  }
}
