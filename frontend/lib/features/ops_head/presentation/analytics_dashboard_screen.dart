import 'package:flutter/material.dart';

class AnalyticsDashboardScreen extends StatelessWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Campus Operations Analytics')),
      body: const Center(
        child: Text('Campus trends, volume by category/building & AI summary.'),
      ),
    );
  }
}
