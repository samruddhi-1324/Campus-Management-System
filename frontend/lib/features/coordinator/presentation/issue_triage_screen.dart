import 'package:flutter/material.dart';

class IssueTriageScreen extends StatelessWidget {
  final String issueId;

  const IssueTriageScreen({super.key, required this.issueId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Triage Issue #$issueId')),
      body: Center(
        child: Text('AI Insights, Internal Notes & Status Updates.'),
      ),
    );
  }
}
