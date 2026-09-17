import 'package:flutter/material.dart';

class RecommendationsScreen extends StatelessWidget {
  const RecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Advisory Recommendations')),
      body: const Center(
        child: Text('Preventive maintenance, resolution & resourcing suggestions.'),
      ),
    );
  }
}
