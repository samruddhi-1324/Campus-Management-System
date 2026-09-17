import 'package:flutter/material.dart';

class MultiYearTrendsScreen extends StatelessWidget {
  const MultiYearTrendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Multi-Year Historical Pattern Mining')),
      body: const Center(
        child: Text('Seasonal spikes, long-term equipment trends & failure patterns.'),
      ),
    );
  }
}
