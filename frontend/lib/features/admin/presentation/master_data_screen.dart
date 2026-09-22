import 'package:flutter/material.dart';

class MasterDataScreen extends StatelessWidget {
  const MasterDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Master Data Management')),
      body: Center(
        child: Text('Buildings, Rooms, Departments, and Categories.'),
      ),
    );
  }
}
