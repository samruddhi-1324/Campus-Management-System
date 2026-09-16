import 'package:flutter/material.dart';

class SupervisorWorkloadScreen extends StatelessWidget {
  const SupervisorWorkloadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Team Workload Overview')),
      body: const Center(
        child: Text('Coordinator workload distribution & reassignments.'),
      ),
    );
  }
}
