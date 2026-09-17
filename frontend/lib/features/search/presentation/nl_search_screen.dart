import 'package:flutter/material.dart';

class NLSearchScreen extends StatelessWidget {
  const NLSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Natural Language Search')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'e.g. "show me all unresolved wifi issues from this month"',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.mic),
                  onPressed: () {},
                ),
                border: const OutlineInputBorder(),
              ),
            ),
            const Expanded(
              child: Center(
                child: Text('AI will parse your query and show filtered results.'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
