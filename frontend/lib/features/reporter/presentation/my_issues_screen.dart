import 'package:flutter/material.dart';

class MyIssuesScreen extends StatelessWidget {
  const MyIssuesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Reported Issues')),
      body: const Center(
        child: Text('Your reported issues will appear here.'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('New Report'),
      ),
    );
  }
}
