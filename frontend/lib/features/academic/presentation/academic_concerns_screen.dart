import 'package:flutter/material.dart';

class AcademicConcernsScreen extends StatelessWidget {
  const AcademicConcernsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Academic Grievances & Concerns')),
      body: const Center(
        child: Text('Confidential academic concerns reporting & tracking.'),
      ),
    );
  }
}
