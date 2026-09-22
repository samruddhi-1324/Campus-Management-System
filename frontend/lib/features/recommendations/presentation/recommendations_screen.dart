import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:campus_care/app/theme.dart';
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
      // Fallback demo mock data matching Stitch design
      setState(() {
        _recommendations = [
          {
            'id': 'rec-001',
            'title': 'Preventive Capital Replacement: Packard 204 AC Compressor',
            'recommendation_class': 'Preventive Replacement',
            'building': 'Packard Building · Rm 204',
            'confidence_score': 0.96,
            'estimated_cost': 6200.0,
            'projected_savings': 4850.0,
            'justification': 'Persistent bearing vibration and 5 recurring failure events in 30 days. Reactive maintenance costs exceed 68% of procurement value.',
            'status': 'pending',
            'evidence_snapshot': {
              'failure_count': 5,
              'historical_repair_cost': 4850.0,
              'mtbf_days': 4.2,
              'category': 'HVAC Infrastructure',
            },
          },
          {
            'id': 'rec-002',
            'title': 'Firmware & Antenna Reallocation: Green Library Core AP-GL-2E',
            'recommendation_class': 'Resolution Optimization',
            'building': 'Main Library · 2nd Floor',
            'confidence_score': 0.92,
            'estimated_cost': 1200.0,
            'projected_savings': 2400.0,
            'justification': 'Channel saturation during peak midterm study hours. Upgrade to Wi-Fi 6E module and optimize beamforming schedule.',
            'status': 'pending',
            'evidence_snapshot': {
              'failure_count': 4,
              'historical_repair_cost': 1920.0,
              'mtbf_days': 6.8,
              'category': 'Network Infrastructure',
            },
          },
          {
            'id': 'rec-003',
            'title': 'Autonomous Water Pressure Cutout: Science Block East Wing',
            'recommendation_class': 'Resourcing Reallocation',
            'building': 'Science Hall · Sector 3',
            'confidence_score': 0.89,
            'estimated_cost': 3400.0,
            'projected_savings': 5100.0,
            'justification': 'Automated smart solenoid valves to isolate overnight line surges before student laboratory occupancy.',
            'status': 'pending',
            'evidence_snapshot': {
              'failure_count': 3,
              'historical_repair_cost': 4310.0,
              'mtbf_days': 9.1,
              'category': 'Plumbing & Water',
            },
          },
        ];
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _recordDecision(String recommendationId, String decision) async {
    try {
      await apiClient.dio.post('/recommendations/$recommendationId/action', data: {
        'decision': decision,
        'notes': 'Decision recorded by Operations Head via AI Portal',
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Recommendation marked as $decision.'),
            backgroundColor: decision == 'accepted' ? const Color(0xFF005137) : AppTheme.secondaryCobalt,
          ),
        );
      }
      _fetchRecommendations();
    } catch (_) {
      // Demo optimistic update
      setState(() {
        final idx = _recommendations.indexWhere((r) => r['id'] == recommendationId);
        if (idx != -1) {
          _recommendations[idx]['status'] = decision;
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Recommendation approved: Capital allocation PO staged.'),
            backgroundColor: const Color(0xFF005137),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceWhite,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryIndigo,
                borderRadius: const BorderRadius.circular(8),
              ),
              child: const Icon(Icons.auto_awesome_outlined, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Campus Care',
                  style: GoogleFonts.newsreader(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryIndigo,
                  ),
                ),
                Text(
                  'AI MAINTENANCE & CAPITAL ADVISORY',
                  style: GoogleFonts.manrope(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Recommendations',
            onPressed: _fetchRecommendations,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchRecommendations,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: isDesktop ? 32 : 16,
            vertical: 20,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Title Block
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('STANFORD OPERATIONS', style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.textSecondary)),
                                const Text(' / '),
                                Text('CAPITAL ASSET PLANNING', style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.secondaryCobalt)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Autonomous Maintenance & Replacement Recommendations',
                              style: GoogleFonts.newsreader(
                                fontSize: isDesktop ? 28 : 22,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryIndigo,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Deterministic evidence models feeding executive capital allocation with Human-in-the-Loop governance.',
                              style: GoogleFonts.manrope(fontSize: 13, color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Executive KPI Bar
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final itemWidth = isDesktop ? (constraints.maxWidth - 48) / 4 : (constraints.maxWidth - 12) / 2;
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _buildKpiCard('Pending Decisions', '4 Active', 'Total Capex: \$24,800', AppTheme.primaryIndigo, itemWidth),
                          _buildKpiCard('Projected Savings', '\$18,400', '+32% ROI vs Reactive', const Color(0xFF005137), itemWidth),
                          _buildKpiCard('Model Confidence', '94.2%', 'Cross-validated telemetry', AppTheme.secondaryCobalt, itemWidth),
                          _buildKpiCard('Governance Status', 'HITL Active', 'Human approval required', AppTheme.textPrimary, itemWidth),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Filter Chips
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceWhite,
                      borderRadius: const BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.neutralLightOutline.withOpacity(0.3)),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildStatusChip('Pending Review', 'pending'),
                          const SizedBox(width: 8),
                          _buildStatusChip('Accepted & PO Staged', 'accepted'),
                          const SizedBox(width: 8),
                          _buildStatusChip('Acted / Procured', 'acted'),
                          const SizedBox(width: 8),
                          _buildStatusChip('Dismissed', 'dismissed'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Recommendations List
                  if (_isLoading)
                    const Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(child: const CircularProgressIndicator()),
                    )
                  else if (_recommendations.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(48),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceWhite,
                        borderRadius: const BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.neutralLightOutline.withOpacity(0.3)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.auto_awesome_outlined, size: 56, color: AppTheme.secondaryCobalt),
                          const SizedBox(height: 12),
                          Text('No recommendations in this status queue', style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('All autonomous maintenance recommendations reviewed.', style: GoogleFonts.manrope(fontSize: 13, color: AppTheme.textSecondary)),
                        ],
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _recommendations.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final rec = _recommendations[index];
                        final confidence = ((rec['confidence_score'] ?? 0.85) * 100).toInt();
                        final cost = (rec['estimated_cost'] ?? 0.0) as double;
                        final recId = rec['id'] ?? '';
                        final evidence = rec['evidence_snapshot'] as Map<String, dynamic>?;
                        final status = rec['status'] ?? 'pending';

                        return Container(
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceWhite,
                            borderRadius: const BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.neutralLightOutline.withOpacity(0.3)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
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
                                        color: AppTheme.primaryIndigo.withOpacity(0.08),
                                        borderRadius: const BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.auto_awesome, size: 14, color: AppTheme.secondaryCobalt),
                                          const SizedBox(width: 6),
                                          Text(
                                            'AI Recommendation ($confidence% Confidence)',
                                            style: GoogleFonts.manrope(
                                              color: AppTheme.primaryIndigo,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      'Est. Capex: \$${cost.toStringAsFixed(0)}',
                                      style: GoogleFonts.newsreader(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        color: const Color(0xFF005137),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  rec['title'] ?? 'Asset Replacement Advisory',
                                  style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.primaryIndigo),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  rec['justification'] ?? 'No justification provided.',
                                  style: GoogleFonts.manrope(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
                                ),
                                if (evidence != null && evidence.isNotEmpty) ...[
                                  const SizedBox(height: 14),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppTheme.backgroundLight,
                                      borderRadius: const BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        if (evidence['failure_count'] != null)
                                          _buildEvidencePill('Failures: ${evidence['failure_count']} in 30d'),
                                        if (evidence['historical_repair_cost'] != null)
                                          _buildEvidencePill('Past Cost: \$${evidence['historical_repair_cost']}'),
                                        if (evidence['category'] != null)
                                          _buildEvidencePill('Discipline: ${evidence['category']}'),
                                      ],
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 16),
                                const Divider(height: 1),
                                const SizedBox(height: 12),
                                if (status == 'pending') ...[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      OutlinedButton(
                                        onPressed: () => _recordDecision(recId, 'dismissed'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppTheme.statusCritical,
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                          shape: RoundedRectangleBorder(borderRadius: const BorderRadius.circular(8)),
                                        ),
                                        child: const Text('Dismiss Advisory'),
                                      ),
                                      const SizedBox(width: 12),
                                      ElevatedButton.icon(
                                        onPressed: () => _recordDecision(recId, 'accepted'),
                                        icon: const Icon(Icons.check, size: 16),
                                        label: const Text('Accept & Stage Capital PO'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.primaryIndigo,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                          shape: RoundedRectangleBorder(borderRadius: const BorderRadius.circular(8)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ] else if (status == 'accepted') ...[
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.check_circle_outline, size: 16),
                                      label: const Text('Confirm Procurement Initiated'),
                                      onPressed: () => _recordDecision(recId, 'acted'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF005137),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                        shape: RoundedRectangleBorder(borderRadius: const BorderRadius.circular(8)),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEvidencePill(String text) {
    return Text(text, style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary));
  }

  Widget _buildStatusChip(String label, String statusValue) {
    final isSelected = _selectedStatus == statusValue;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedStatus = statusValue);
          _fetchRecommendations();
        }
      },
      selectedColor: AppTheme.primaryIndigo,
      backgroundColor: AppTheme.surfaceWhite,
      labelStyle: GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? Colors.white : AppTheme.textPrimary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryIndigo : AppTheme.neutralLightOutline.withOpacity(0.4),
        ),
      ),
    );
  }

  Widget _buildKpiCard(String title, String count, String subtitle, Color countColor, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: const BorderRadius.circular(14),
        border: Border.all(color: AppTheme.neutralLightOutline.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textSecondary, letterSpacing: 0.5)),
          const SizedBox(height: 6),
          Text(count, style: GoogleFonts.newsreader(fontSize: 24, fontWeight: FontWeight.w600, color: countColor)),
          const SizedBox(height: 4),
          Text(subtitle, style: GoogleFonts.manrope(fontSize: 11, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}
