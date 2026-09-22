import 'package:flutter/material.dart';

class SupervisorWorkloadScreen extends StatelessWidget {
  const SupervisorWorkloadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Team Workload Overview')),
      body: Center(
        child: Text('Coordinator workload distribution & reassignments.'),
      ),
    );
  }
}
