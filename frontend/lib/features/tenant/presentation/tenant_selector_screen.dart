import 'package:flutter/material.dart';

class TenantSelectorScreen extends StatelessWidget {
  const TenantSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Institution')),
      body: const Center(
        child: Text('Multi-institution workspace selector (FR-3.4).'),
      ),
    );
  }
}
