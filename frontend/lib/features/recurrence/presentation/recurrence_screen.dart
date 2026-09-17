import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:campus_care/core/network/api_client.dart';

class RecurrenceScreen extends StatefulWidget {
  const RecurrenceScreen({super.key});

  @override
  State<RecurrenceScreen> createState() => _RecurrenceScreenState();
}

class _RecurrenceScreenState extends State<RecurrenceScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _patterns = [];
  int _windowDays = 30;
  int _minFailures = 3;

  @override
  void initState() {
    super.initState();
    _fetchRecurrencePatterns();
  }

  Future<void> _fetchRecurrencePatterns() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await apiClient.dio.get('/recurrence/patterns', queryParameters: {
        'window_days': _windowDays,
        'min_failures': _minFailures,
      });
      setState(() {
        _patterns = res.data is List ? res.data : [];
      });
    } on DioException catch (e) {
      setState(() {
        _errorMessage = e.response?.data?['detail'] ?? 'Failed to load recurrent failure patterns';
      });
    } catch (_) {
      setState(() {
        _errorMessage = 'An unexpected error occurred while analyzing recurrence patterns.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _convertToRecommendation(Map<String, dynamic> pattern) async {
    try {
      final res = await apiClient.dio.post('/recurrence/patterns/convert-to-recommendation', data: {
        'category': pattern['category'],
        'building': pattern['building'],
        'room_number': pattern['room_number'],
        'failure_count': pattern['failure_count'],
        'sample_issue_ids': pattern['sample_issue_ids'] ?? [],
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.data['message'] ?? 'Successfully converted to replacement recommendation.'),
          backgroundColor: Colors.green,
        ),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.response?.data?['detail'] ?? 'Failed to convert pattern.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recurrent Failure & Asset Fatigue Tracker', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchRecurrencePatterns,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Parameters
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                const Icon(Icons.history_toggle_off, color: Color(0xFF1E3A8A)),
                const SizedBox(width: 8),
                const Text('Analysis Window:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(width: 12),
                DropdownButton<int>(
                  value: _windowDays,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 14, child: Text('Last 14 Days')),
                    DropdownMenuItem(value: 30, child: Text('Last 30 Days')),
                    DropdownMenuItem(value: 60, child: Text('Last 60 Days')),
                    DropdownMenuItem(value: 90, child: Text('Last 90 Days')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _windowDays = val);
                      _fetchRecurrencePatterns();
                    }
                  },
                ),
                const Spacer(),
                const Text('Min Failures:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: _minFailures,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 2, child: Text('≥ 2 occurrences')),
                    DropdownMenuItem(value: 3, child: Text('≥ 3 occurrences')),
                    DropdownMenuItem(value: 5, child: Text('≥ 5 occurrences')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _minFailures = val);
                      _fetchRecurrencePatterns();
                    }
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Pattern List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.warning_amber_rounded, size: 48, color: Colors.orange),
                            const SizedBox(height: 16),
                            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 12),
                            ElevatedButton(onPressed: _fetchRecurrencePatterns, child: const Text('Retry')),
                          ],
                        ),
                      )
                    : _patterns.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
                                const SizedBox(height: 16),
                                Text(
                                  'No recurrent failure hotspots detected in the last $_windowDays days.',
                                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _patterns.length,
                            itemBuilder: (context, index) {
                              final p = _patterns[index];
                              final category = p['category'] ?? 'General';
                              final building = p['building'] ?? 'Main Campus';
                              final room = p['room_number'];
                              final count = p['failure_count'] ?? 0;
                              final sampleTitles = (p['sample_issue_titles'] as List<dynamic>?) ?? [];

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
                                            decoration: BoxDecoration(
                                              color: Colors.red.withOpacity(0.12),
                                              borderRadius: const BorderRadius.all(Radius.circular(6)),
                                            ),
                                            child: Text(
                                              '$count RECURRING FAILURES',
                                              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
                                            ),
                                          ),
                                          Text(
                                            'Rolling $_windowDays-day window',
                                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        '$category Hotspot: $building ${room != null ? '• Room $room' : ''}',
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      if (sampleTitles.isNotEmpty) ...[
                                        const SizedBox(height: 10),
                                        const Text('Associated Repeated Complaints:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.black54)),
                                        const SizedBox(height: 4),
                                        ...sampleTitles.map((t) => Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 2),
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Text('• ', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                                  Expanded(child: Text(t.toString(), style: const TextStyle(fontSize: 13))),
                                                ],
                                              ),
                                            )),
                                      ],
                                      const SizedBox(height: 16),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: ElevatedButton.icon(
                                          icon: const Icon(Icons.auto_fix_high, size: 18),
                                          label: const Text('Convert to Replacement Recommendation'),
                                          onPressed: () => _convertToRecommendation(p),
                                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A)),
                                        ),
                                      ),
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
