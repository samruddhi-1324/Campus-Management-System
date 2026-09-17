import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:campus_care/core/network/api_client.dart';

class SlaRiskScreen extends StatefulWidget {
  const SlaRiskScreen({super.key});

  @override
  State<SlaRiskScreen> createState() => _SlaRiskScreenState();
}

class _SlaRiskScreenState extends State<SlaRiskScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _riskItems = [];

  @override
  void initState() {
    super.initState();
    _fetchSlaRisks();
  }

  Future<void> _fetchSlaRisks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await apiClient.dio.get('/sla/at-risk');
      setState(() {
        _riskItems = res.data is List ? res.data : [];
      });
    } on DioException catch (e) {
      setState(() {
        _errorMessage = e.response?.data?['detail'] ?? 'Failed to load SLA risk radar.';
      });
    } catch (_) {
      setState(() {
        _errorMessage = 'An unexpected error occurred while fetching SLA risks.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _escalateIssue(String issueId) async {
    try {
      await apiClient.dio.post('/issues/$issueId/escalate', data: {
        'reason': 'Proactive SLA breach risk mitigation from Supervisor Radar',
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Issue priority escalated successfully.'),
          backgroundColor: Colors.orange,
        ),
      );

      _fetchSlaRisks();
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.response?.data?['detail'] ?? 'Failed to escalate issue.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Real-Time SLA Risk & Breach Radar', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchSlaRisks,
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
                      const Icon(Icons.timer_off_outlined, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: _fetchSlaRisks, child: const Text('Retry')),
                    ],
                  ),
                )
              : _riskItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.verified_user_outlined, size: 64, color: Colors.green),
                          const SizedBox(height: 16),
                          Text(
                            'All active campus issues are strictly within SLA limits.',
                            style: TextStyle(fontSize: 16, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _riskItems.length,
                      itemBuilder: (context, index) {
                        final item = _riskItems[index];
                        final issueId = item['id'] ?? '';
                        final title = item['title'] ?? 'Complaint #$issueId';
                        final category = item['category'] ?? 'General';
                        final building = item['building'] ?? 'Main Campus';
                        final urgencyMultiplier = (item['urgency_multiplier'] ?? 1.0) as num;
                        final riskScore = (item['breach_risk_score'] ?? 0.85) as num;
                        final isOverdue = item['is_overdue'] ?? false;
                        final hoursRemaining = item['hours_remaining'] ?? 2.5;

                        final riskColor = isOverdue ? Colors.red : (riskScore > 0.7 ? Colors.orange : Colors.amber);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: const BorderRadius.all(Radius.circular(12)),
                            side: BorderSide(color: riskColor.withOpacity(0.4), width: 1.5),
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
                                        color: riskColor.withOpacity(0.12),
                                        borderRadius: const BorderRadius.all(Radius.circular(6)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(isOverdue ? Icons.alarm_off : Icons.warning_amber_rounded, size: 16, color: riskColor),
                                          const SizedBox(width: 4),
                                          Text(
                                            isOverdue ? 'SLA BREACHED / OVERDUE' : 'AT-RISK (${(riskScore * 100).toInt()}% Breach Risk)',
                                            style: TextStyle(color: riskColor, fontWeight: FontWeight.bold, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      isOverdue ? 'Overdue by ${hoursRemaining.abs()}h' : '$hoursRemaining hrs left',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: riskColor, fontSize: 14),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  title,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  children: [
                                    Chip(
                                      avatar: const Icon(Icons.apartment, size: 16),
                                      label: Text(building),
                                    ),
                                    Chip(
                                      avatar: const Icon(Icons.category, size: 16),
                                      label: Text(category),
                                    ),
                                    if (urgencyMultiplier > 1.0)
                                      Chip(
                                        backgroundColor: Colors.red.shade50,
                                        avatar: const Icon(Icons.trending_up, size: 16, color: Colors.red),
                                        label: Text('Priority Multiplier: ${urgencyMultiplier}x', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    OutlinedButton.icon(
                                      icon: const Icon(Icons.visibility, size: 18),
                                      label: const Text('View Ticket'),
                                      onPressed: () {},
                                    ),
                                    const SizedBox(width: 12),
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.flash_on, size: 18),
                                      label: const Text('Escalate Urgency'),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
                                      onPressed: () => _escalateIssue(issueId),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
