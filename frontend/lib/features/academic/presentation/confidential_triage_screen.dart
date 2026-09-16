import 'package:flutter/material.dart';

class ConfidentialTriageScreen extends StatelessWidget {
  final String concernId;

  const ConfidentialTriageScreen({super.key, required this.concernId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Confidential Review #$concernId')),
      body: const Center(
        child: Text('Academic Affairs officer private triage view.'),
      ),
    );
  }
}
