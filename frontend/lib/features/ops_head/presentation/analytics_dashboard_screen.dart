import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:campus_care/core/network/api_client.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _summary;
  List<dynamic> _drilldownIssues = [];
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _fetchAnalytics();
  }

  Future<void> _fetchAnalytics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await apiClient.dio.get('/analytics/drilldown');
      setState(() {
        _summary = res.data;
        _drilldownIssues = res.data['issues'] is List ? res.data['issues'] : [];
      });
    } on DioException catch (e) {
      setState(() {
        _errorMessage = e.response?.data?['detail'] ?? 'Failed to load analytics dashboard';
      });
    } catch (_) {
      setState(() {
        _errorMessage = 'An unexpected error occurred while compiling analytics data.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _exportCsv() async {
    setState(() {
      _isExporting = true;
    });

    try {
      final res = await apiClient.dio.get('/analytics/export');
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.file_download_done, color: Colors.teal),
              SizedBox(width: 8),
              Text('CSV Export Ready (FR-2.10)'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Campus operations CSV export generated successfully:'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                ),
                child: Text(
                  'Payload Preview:\n${res.data.toString().split('\n').take(4).join('\n')}...',
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Dismiss'),
            ),
          ],
        ),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.response?.data?['detail'] ?? 'Export failed'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Widget _buildKpiCard(String label, String value, IconData icon, Color color) {
    return Card(
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
                Text(label, style: const TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w600)),
                Icon(icon, color: color, size: 28),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalIssues = _summary?['total_count'] ?? 0;
    final resolvedCount = _summary?['resolved_count'] ?? 0;
    final slaCompliance = totalIssues > 0 ? (((totalIssues - (_summary?['breached_count'] ?? 0)) / totalIssues) * 100).toStringAsFixed(1) : '100.0';
    final avgResolutionHours = (_summary?['avg_resolution_hours'] ?? 4.2).toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Executive Operations & Analytics', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchAnalytics,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              icon: _isExporting
                  ? const SizedBox(height: 14, width: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.download, size: 18),
              label: const Text('Export CSV'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A)),
              onPressed: _isExporting ? null : _exportCsv,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.bar_chart, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: _fetchAnalytics, child: const Text('Retry')),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // KPI Row
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth > 700) {
                            return Row(
                              children: [
                                Expanded(child: _buildKpiCard('Total Tickets', '$totalIssues', Icons.receipt_long, const Color(0xFF1E3A8A))),
                                const SizedBox(width: 16),
                                Expanded(child: _buildKpiCard('Resolved', '$resolvedCount', Icons.check_circle_outline, Colors.teal)),
                                const SizedBox(width: 16),
                                Expanded(child: _buildKpiCard('SLA Compliance', '$slaCompliance%', Icons.speed, Colors.green)),
                                const SizedBox(width: 16),
                                Expanded(child: _buildKpiCard('Avg MTTR', '$avgResolutionHours h', Icons.schedule, Colors.orange)),
                              ],
                            );
                          } else {
                            return Column(
                              children: [
                                _buildKpiCard('Total Tickets', '$totalIssues', Icons.receipt_long, const Color(0xFF1E3A8A)),
                                const SizedBox(height: 12),
                                _buildKpiCard('Resolved', '$resolvedCount', Icons.check_circle_outline, Colors.teal),
                                const SizedBox(height: 12),
                                _buildKpiCard('SLA Compliance', '$slaCompliance%', Icons.speed, Colors.green),
                                const SizedBox(height: 12),
                                _buildKpiCard('Avg MTTR', '$avgResolutionHours h', Icons.schedule, Colors.orange),
                              ],
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 24),

                      // Drilldown Section Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Complaints Drilldown Queue (FR-2.9)',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${_drilldownIssues.length} items',
                            style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Drilldown Items List
                      if (_drilldownIssues.isEmpty)
                        Card(
                          elevation: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Center(
                              child: Text(
                                'No filtered records in the drilldown buffer.',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _drilldownIssues.length,
                          itemBuilder: (context, index) {
                            final issue = _drilldownIssues[index];
                            final id = issue['id'] ?? '';
                            final title = issue['title'] ?? 'Ticket #$id';
                            final category = issue['category'] ?? 'General';
                            final status = issue['status'] ?? 'submitted';
                            final building = issue['building'] ?? 'Main Campus';

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 1,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                                side: BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: const Color(0xFF1E3A8A).withOpacity(0.1),
                                  child: const Icon(Icons.assignment_outlined, color: Color(0xFF1E3A8A)),
                                ),
                                title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('$building • $category'),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: const BorderRadius.all(Radius.circular(6)),
                                  ),
                                  child: Text(
                                    status.toString().toUpperCase(),
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
    );
  }
}
