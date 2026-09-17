import 'package:flutter/material.dart';

class IssueDetailScreen extends StatelessWidget {
  final String issueId;

  const IssueDetailScreen({super.key, required this.issueId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Issue #$issueId')),
      body: const Center(
        child: Text('Issue timeline and resolution details.'),
      ),
    );
  }
}
