import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:campus_care/core/network/api_client.dart';

class CoordinatorQueueScreen extends StatefulWidget {
  const CoordinatorQueueScreen({super.key});

  @override
  State<CoordinatorQueueScreen> createState() => _CoordinatorQueueScreenState();
}

class _CoordinatorQueueScreenState extends State<CoordinatorQueueScreen> {
  List<dynamic> _queue = [];
  bool _isLoading = true;
  String? _statusFilter;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchQueue();
  }

  Future<void> _fetchQueue() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final queryParams = <String, dynamic>{};
      if (_statusFilter != null) {
        queryParams['status_filter'] = _statusFilter;
      }

      final response = await apiClient.dio.get('/issues/queue', queryParameters: queryParams);
      setState(() {
        _queue = response.data as List<dynamic>;
      });
    } on DioException catch (e) {
      setState(() {
        _errorMessage = e.response?.data?['detail'] ?? 'Failed to load coordinator queue';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateStatus(String issueId, String nextStatus) async {
    try {
      await apiClient.dio.patch('/issues/$issueId/status', data: {
        'status': nextStatus,
        'message': 'Status advanced by coordinator.',
        'visibility': 'external',
      });
      _fetchQueue();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Issue status updated to ${nextStatus.replaceAll('_', ' ').toUpperCase()}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update status (Check state machine rules).')),
        );
      }
    }
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.deepOrange;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coordinator Triage Queue', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchQueue,
          ),
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () => context.push('/ops/analytics'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All Open'),
                  selected: _statusFilter == null,
                  onSelected: (val) {
                    setState(() => _statusFilter = null);
                    _fetchQueue();
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Reported'),
                  selected: _statusFilter == 'reported',
                  onSelected: (val) {
                    setState(() => _statusFilter = val ? 'reported' : null);
                    _fetchQueue();
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Assigned'),
                  selected: _statusFilter == 'assigned',
                  onSelected: (val) {
                    setState(() => _statusFilter = val ? 'assigned' : null);
                    _fetchQueue();
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Investigating'),
                  selected: _statusFilter == 'investigating',
                  onSelected: (val) {
                    setState(() => _statusFilter = val ? 'investigating' : null);
                    _fetchQueue();
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Action Taken'),
                  selected: _statusFilter == 'action_taken',
                  onSelected: (val) {
                    setState(() => _statusFilter = val ? 'action_taken' : null);
                    _fetchQueue();
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Queue List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
                    : _queue.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_outline, size: 64, color: Colors.green[300]),
                                const SizedBox(height: 16),
                                const Text('No pending issues in this queue!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: _queue.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final item = _queue[index];
                              final urgency = (item['urgency'] ?? 'medium').toString();
                              final status = (item['status'] ?? 'reported').toString();
                              final urgencyColor = _getUrgencyColor(urgency);

                              return Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            item['reference_number'] ?? '',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: urgencyColor.withOpacity(0.12),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: urgencyColor.withOpacity(0.4)),
                                            ),
                                            child: Text(
                                              urgency.toUpperCase(),
                                              style: TextStyle(color: urgencyColor, fontWeight: FontWeight.bold, fontSize: 11),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        item['title'] ?? '',
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item['description'] ?? '',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(color: Colors.grey[700], fontSize: 13),
                                      ),
                                      const SizedBox(height: 12),
                                      Wrap(
                                        spacing: 8,
                                        children: [
                                          if (status == 'reported')
                                            ElevatedButton.icon(
                                              icon: const Icon(Icons.assignment_ind, size: 16),
                                              label: const Text('Mark Understood'),
                                              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                                              onPressed: () => _updateStatus(item['id'], 'understood'),
                                            ),
                                          if (status == 'understood' || status == 'assigned')
                                            ElevatedButton.icon(
                                              icon: const Icon(Icons.search, size: 16),
                                              label: const Text('Investigate'),
                                              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                                              onPressed: () => _updateStatus(item['id'], 'investigating'),
                                            ),
                                          if (status == 'investigating')
                                            ElevatedButton.icon(
                                              icon: const Icon(Icons.build, size: 16),
                                              label: const Text('Action Taken'),
                                              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                                              onPressed: () => _updateStatus(item['id'], 'action_taken'),
                                            ),
                                          if (status == 'action_taken')
                                            ElevatedButton.icon(
                                              icon: const Icon(Icons.check, size: 16),
                                              label: const Text('Mark Resolved'),
                                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                              onPressed: () => _updateStatus(item['id'], 'resolved'),
                                            ),
                                        ],
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
