import 'package:flutter/material.dart';

class CoordinatorQueueScreen extends StatelessWidget {
  const CoordinatorQueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Coordinator Queue')),
      body: const Center(
        child: Text('Prioritized queue sorted by SLA & urgency.'),
      ),
    );
  }
}
