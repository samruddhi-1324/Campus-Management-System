import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:campus_care/core/network/api_client.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _recommendations = [];
  String _selectedStatus = 'pending';

  @override
  void initState() {
    super.initState();
    _fetchRecommendations();
  }

  Future<void> _fetchRecommendations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await apiClient.dio.get('/recommendations', queryParameters: {
        if (_selectedStatus.isNotEmpty) 'status': _selectedStatus,
      });
      setState(() {
        _recommendations = res.data is List ? res.data : [];
      });
    } on DioException catch (e) {
      setState(() {
        _errorMessage = e.response?.data?['detail'] ?? 'Failed to load recommendations';
      });
    } catch (_) {
      setState(() {
        _errorMessage = 'An unexpected error occurred.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _recordDecision(String recommendationId, String decision) async {
    try {
      await apiClient.dio.post('/recommendations/$recommendationId/action', data: {
        'decision': decision,
        'notes': 'Decision recorded by Operations Head via AI Portal',
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Recommendation marked as $decision.'),
          backgroundColor: decision == 'accepted' ? Colors.green : Colors.blueGrey,
        ),
      );

      _fetchRecommendations();
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.response?.data?['detail'] ?? 'Failed to record decision.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Asset & Replacement Recommendations', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Recommendations',
            onPressed: _fetchRecommendations,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const Text('Filter Status:', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(width: 12),
                  ...['pending', 'accepted', 'acted', 'dismissed'].map((status) {
                    final isSelected = _selectedStatus == status;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(status.toUpperCase()),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedStatus = status);
                            _fetchRecommendations();
                          }
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          const Divider(height: 1),

          // Content Area
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 12),
                            ElevatedButton(onPressed: _fetchRecommendations, child: const Text('Retry')),
                          ],
                        ),
                      )
                    : _recommendations.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.auto_awesome_outlined, size: 64, color: Colors.grey.shade400),
                                const SizedBox(height: 16),
                                Text(
                                  'No $_selectedStatus recommendations found.',
                                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _recommendations.length,
                            itemBuilder: (context, index) {
                              final rec = _recommendations[index];
                              final confidence = ((rec['confidence_score'] ?? 0.85) * 100).toInt();
                              final cost = rec['estimated_cost'] ?? 0.0;
                              final recId = rec['id'] ?? '';
                              final evidence = rec['evidence_snapshot'] as Map<String, dynamic>?;

                              return Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                elevation: 2,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(12)),
                                  side: BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFEDE9FE),
                                              borderRadius: BorderRadius.all(Radius.circular(6)),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.psychology, size: 16, color: Color(0xFF7C3AED)),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'AI Recommendation ($confidence% Confidence)',
                                                  style: const TextStyle(color: Color(0xFF7C3AED), fontWeight: FontWeight.bold, fontSize: 12),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            'Est. Cost: \$${cost.toStringAsFixed(2)}',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        rec['title'] ?? 'Asset Replacement Advisory',
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        rec['justification'] ?? 'No justification provided.',
                                        style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
                                      ),
                                      if (evidence != null && evidence.isNotEmpty) ...[
                                        const SizedBox(height: 12),
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius: const BorderRadius.all(Radius.circular(8)),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            children: [
                                              if (evidence['failure_count'] != null)
                                                Text('Failures: ${evidence['failure_count']}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                                              if (evidence['historical_repair_cost'] != null)
                                                Text('Past Repair: \$${evidence['historical_repair_cost']}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                                              if (evidence['category'] != null)
                                                Text('Category: ${evidence['category']}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                                            ],
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 16),
                                      if (_selectedStatus == 'pending') ...[
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            OutlinedButton(
                                              onPressed: () => _recordDecision(recId, 'dismissed'),
                                              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                                              child: const Text('Dismiss'),
                                            ),
                                            const SizedBox(width: 12),
                                            ElevatedButton(
                                              onPressed: () => _recordDecision(recId, 'accepted'),
                                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A)),
                                              child: const Text('Accept & Approve'),
                                            ),
                                          ],
                                        ),
                                      ] else if (_selectedStatus == 'accepted') ...[
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: ElevatedButton.icon(
                                            icon: const Icon(Icons.check_circle_outline, size: 18),
                                            label: const Text('Mark as Acted / Procurement Initiated'),
                                            onPressed: () => _recordDecision(recId, 'acted'),
                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
