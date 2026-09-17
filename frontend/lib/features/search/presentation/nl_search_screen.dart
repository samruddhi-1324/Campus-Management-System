import 'package:flutter/material.dart';

class NLSearchScreen extends StatefulWidget {
  const NLSearchScreen({super.key});

  @override
  State<NLSearchScreen> createState() => _NLSearchScreenState();
}

class _NLSearchScreenState extends State<NLSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  Map<String, dynamic>? _searchResponse;

  final List<String> _exampleQueries = [
    'show me all unresolved wifi issues from this month',
    'ac leaks in Main Building',
    'projector power failure in Science Block',
    'high urgency electrical issues',
  ];

  void _executeSearch(String query) {
    if (query.trim().isEmpty) return;
    setState(() {
      _isSearching = true;
      _searchController.text = query;
      // Simulated response representation matching NLSearchResponse
      _searchResponse = {
        'original_query': query,
        'parsed_filters': {
          'category_slug': query.toLowerCase().contains('wifi')
              ? 'wifi'
              : (query.toLowerCase().contains('ac') ? 'ac' : 'electrical'),
          'building_name': query.toLowerCase().contains('main')
              ? 'Main Academic Block'
              : (query.toLowerCase().contains('science') ? 'Science Block' : null),
          'is_unresolved': query.toLowerCase().contains('unresolved') || query.toLowerCase().contains('open'),
          'keywords': ['failure', 'leak', 'power'],
        },
        'results': [
          {
            'reference_number': 'CC-2026-0812',
            'title': 'Slow Wi-Fi connectivity and packet drop',
            'status': 'INVESTIGATING',
            'urgency': 'HIGH',
            'location_details': 'Room 304, 3rd Floor',
            'created_at': '2026-09-15T10:30:00Z',
          },
          {
            'reference_number': 'CC-2026-0794',
            'title': 'No internet access in Engineering Lab 2',
            'status': 'ASSIGNED',
            'urgency': 'MEDIUM',
            'location_details': 'Lab 202',
            'created_at': '2026-09-14T14:15:00Z',
          },
        ],
        'total_matched': 2,
      };
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filters = _searchResponse?['parsed_filters'] as Map<String, dynamic>?;
    final results = _searchResponse?['results'] as List<dynamic>?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Natural Language Search'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              onSubmitted: _executeSearch,
              decoration: InputDecoration(
                hintText: 'e.g. "show me all unresolved wifi issues"',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchResponse = null);
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.mic),
                      tooltip: 'Voice Search',
                      onPressed: () => _executeSearch('unresolved electrical issues'),
                    ),
                  ],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              ),
            ),
            const SizedBox(height: 12),

            // Suggested queries
            if (_searchResponse == null) ...[
              const Text(
                'Try asking in plain English:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _exampleQueries.map((q) {
                  return ActionChip(
                    avatar: const Icon(Icons.auto_awesome, size: 16),
                    label: Text(q),
                    onPressed: () => _executeSearch(q),
                  );
                }).toList(),
              ),
            ],

            // Active Parsed Filters
            if (filters != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.psychology, size: 18, color: Colors.blue),
                        SizedBox(width: 6),
                        Text(
                          'AI Parsed Query Filters',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (filters['category_slug'] != null)
                          Chip(
                            label: Text('Category: ${filters['category_slug']}'),
                            backgroundColor: Colors.blue.shade50,
                          ),
                        if (filters['building_name'] != null)
                          Chip(
                            label: Text('Building: ${filters['building_name']}'),
                            backgroundColor: Colors.indigo.shade50,
                          ),
                        if (filters['is_unresolved'] == true)
                          Chip(
                            label: const Text('Status: Unresolved'),
                            backgroundColor: Colors.amber.shade100,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Search Results List
            if (_isSearching)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (results != null && results.isNotEmpty)
              Expanded(
                child: ListView.separated(
                  itemCount: results.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = results[index] as Map<String, dynamic>;
                    return Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: item['urgency'] == 'HIGH' ? Colors.red.shade100 : Colors.blue.shade100,
                          child: Icon(
                            Icons.report_problem,
                            color: item['urgency'] == 'HIGH' ? Colors.red : Colors.blue,
                            size: 20,
                          ),
                        ),
                        title: Text(item['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${item['reference_number']} • ${item['location_details']}'),
                        trailing: Chip(
                          label: Text(item['status'] ?? ''),
                          labelStyle: const TextStyle(fontSize: 11),
                        ),
                        onTap: () {},
                      ),
                    );
                  },
                ),
              )
            else if (_searchResponse != null && (results == null || results.isEmpty))
              const Expanded(
                child: Center(
                  child: Text('No issues matched your natural language query.'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
