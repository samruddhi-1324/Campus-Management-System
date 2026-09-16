import 'package:flutter/material.dart';

class RecurrenceScreen extends StatelessWidget {
  const RecurrenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recurring Failure Patterns')),
      body: const Center(
        child: Text('Equipment & location recurring failure patterns and replacement flags.'),
      ),
    );
  }
}
