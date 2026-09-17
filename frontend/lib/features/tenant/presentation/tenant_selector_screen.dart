import 'package:flutter/material.dart';

class TenantSelectorScreen extends StatefulWidget {
  const TenantSelectorScreen({super.key});

  @override
  State<TenantSelectorScreen> createState() => _TenantSelectorScreenState();
}

class _TenantSelectorScreenState extends State<TenantSelectorScreen> {
  String _selectedTenantId = 'inst-1';

  final List<Map<String, dynamic>> _institutions = [
    {
      'id': 'inst-1',
      'name': 'Apex University of Technology',
      'slug': 'apex-tech',
      'domain': 'apex.edu',
      'active_issues': 28,
      'is_active': true,
    },
    {
      'id': 'inst-2',
      'name': 'Metropolitan Medical & Health College',
      'slug': 'metro-health',
      'domain': 'metrohealth.edu',
      'active_issues': 14,
      'is_active': true,
    },
    {
      'id': 'inst-3',
      'name': 'St. Jude Institute of Management',
      'slug': 'st-jude',
      'domain': 'stjude.edu',
      'active_issues': 7,
      'is_active': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Institution Workspace'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Multi-Tenant Institution Selector (FR-3.4)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            const Text(
              'Switch between institutional domains and isolated tenant complaint systems.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: _institutions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final inst = _institutions[index];
                  final isSelected = inst['id'] == _selectedTenantId;

                  return Card(
                    elevation: isSelected ? 2 : 0.5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade200,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade200,
                        child: Icon(
                          Icons.account_balance,
                          color: isSelected ? Colors.white : Colors.grey.shade700,
                        ),
                      ),
                      title: Text(
                        inst['name'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      subtitle: Text('${inst['domain']} • ${inst['slug']}'),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedTenantId = inst['id'] as String;
                                });
                              },
                              child: const Text('Switch'),
                            ),
                      onTap: () {
                        setState(() {
                          _selectedTenantId = inst['id'] as String;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Switched institutional context successfully.')),
                  );
                },
                icon: const Icon(Icons.check),
                label: const Text('Confirm Institution Workspace'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
