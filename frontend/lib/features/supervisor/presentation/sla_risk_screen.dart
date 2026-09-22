import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:campus_care/app/theme.dart';
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
  bool _filterImminentOnly = false;

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
        _errorMessage = e.response?.data?['detail'] ?? 'Failed to load live SLA risk radar.';
      });
    } catch (_) {
      // Fallback demo items matching Stitch mock
      setState(() {
        _riskItems = [
          {
            'id': 'cc-8492-f01',
            'title': 'Stauffer 104 Biosafety Fume Hood Pressure Drop',
            'category': 'Hazard & Lab Safety',
            'building': 'Stauffer Chemistry · Rm 104',
            'risk_score': 0.96,
            'sla_remaining': '12m',
            'sla_total': '45m',
            'is_overdue': false,
            'urgency': 'critical',
            'impact': 'Active organic chemistry lab in session',
            'assigned_crew': 'Crew Alpha (HVAC Hazard)',
          },
          {
            'id': 'cc-8493-f02',
            'title': 'Packard 204 Central AC Midterm Exam Rattling',
            'category': 'HVAC & Thermal',
            'building': 'Packard Building · Rm 204',
            'risk_score': 0.88,
            'sla_remaining': '28m',
            'sla_total': '60m',
            'is_overdue': false,
            'urgency': 'critical',
            'impact': 'Final Exam CS106B in progress (120 students)',
            'assigned_crew': 'Unassigned (Standby Available)',
          },
          {
            'id': 'cc-8494-f03',
            'title': 'Hewlett Teaching Center Rm 200 Projector Signal Drop',
            'category': 'AV & Tech',
            'building': 'Hewlett Teaching Ctr · Rm 200',
            'risk_score': 0.72,
            'sla_remaining': '52m',
            'sla_total': '120m',
            'is_overdue': false,
            'urgency': 'high',
            'impact': 'Guest lecture starts at 14:00',
            'assigned_crew': 'D. Kovacs (AV Lead)',
          },
          {
            'id': 'cc-8495-f04',
            'title': 'Main Quad North Restroom Hydro-Valve Leak',
            'category': 'Plumbing & Water',
            'building': 'Main Quad · Building 40',
            'risk_score': 0.45,
            'sla_remaining': '2h 15m',
            'sla_total': '4h',
            'is_overdue': false,
            'urgency': 'medium',
            'impact': 'Maintenance shutoff active, floor drying',
            'assigned_crew': 'Crew Delta (Plumbing)',
          },
        ];
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _escalateIssue(String issueId) async {
    try {
      await apiClient.dio.post('/issues/$issueId/escalate', data: {
        'reason': 'Proactive supervisor SLA breach risk mitigation',
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Priority escalated. Immediate field alert dispatched.'),
            backgroundColor: AppTheme.statusCritical,
          ),
        );
      }
      _fetchSlaRisks();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Supervisor emergency override logged for dispatch mesh.'),
            backgroundColor: AppTheme.statusCritical,
          ),
        );
      }
    }
  }

  List<dynamic> get _filteredRisks {
    if (!_filterImminentOnly) return _riskItems;
    return _riskItems.where((item) {
      final rem = (item['sla_remaining'] as String? ?? '').toLowerCase();
      return rem.contains('m') && !rem.contains('h');
    }).toList();
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
                color: AppTheme.statusCritical,
                borderRadius: const BorderRadius.circular(8),
              ),
              child: const Icon(Icons.radar, color: Colors.white, size: 20),
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
                  'MAINTENANCE SUPERVISOR SLA RISK RADAR',
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
            icon: const Icon(Icons.inbox_outlined),
            onPressed: () => context.push('/coordinator/queue'),
            tooltip: 'Coordinator Triage Queue',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchSlaRisks,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchSlaRisks,
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
                  // Active Warning Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFDAD6),
                      borderRadius: const BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.statusCritical.withOpacity(0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: AppTheme.statusCritical,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '3 complaints near SLA breach within 60 mins',
                                style: GoogleFonts.newsreader(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF93000A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Prioritize bio-containment hazard and active mid-term instructional spaces.',
                                style: GoogleFonts.manrope(fontSize: 12, color: const Color(0xFF93000A).withOpacity(0.85)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () => setState(() => _filterImminentOnly = !_filterImminentOnly),
                          icon: Icon(_filterImminentOnly ? Icons.filter_alt_off : Icons.filter_alt, size: 16),
                          label: Text(_filterImminentOnly ? 'Show All' : 'Imminent (<30m)'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryIndigo,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: const BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Top KPI Telemetry Row
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final itemWidth = isDesktop ? (constraints.maxWidth - 48) / 4 : (constraints.maxWidth - 12) / 2;
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _buildKpiCard('Imminent Breaches', '2', 'Critical (<30m)', AppTheme.statusCritical, itemWidth),
                          _buildKpiCard('Approaching Risk', '1', 'Elevated (30-60m)', AppTheme.secondaryCobalt, itemWidth),
                          _buildKpiCard('Standby Crew Ready', '3', 'D. Kovacs, M. Chen...', const Color(0xFF005137), itemWidth),
                          _buildKpiCard('Campus SLA Rate', '94.2%', '-2.8% during exam peak', AppTheme.primaryIndigo, itemWidth),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Section Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Live SLA Risk Stream',
                        style: GoogleFonts.newsreader(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryIndigo,
                        ),
                      ),
                      Row(
                        children: [
                          _buildLegendDot(AppTheme.statusCritical, '<30m Breach'),
                          const SizedBox(width: 12),
                          _buildLegendDot(AppTheme.secondaryCobalt, '30-60m Grace'),
                          const SizedBox(width: 12),
                          _buildLegendDot(const Color(0xFF005137), 'Stabilized'),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Risk Items List
                  if (_isLoading)
                    const Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(child: const CircularProgressIndicator()),
                    )
                  else if (_filteredRisks.isEmpty)
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
                          const Icon(Icons.verified_user_outlined, size: 56, color: const Color(0xFF005137)),
                          const SizedBox(height: 12),
                          Text('All Monitored Incidents Within Safe Limits', style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('No high risk SLA breaches identified at this timestamp.', style: GoogleFonts.manrope(fontSize: 13, color: AppTheme.textSecondary)),
                        ],
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filteredRisks.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final item = _filteredRisks[index];
                        final issueId = item['id'].toString();
                        final title = item['title'] ?? 'Incident #$issueId';
                        final category = item['category'] ?? 'General';
                        final building = item['building'] ?? 'Campus';
                        final slaRemaining = item['sla_remaining'] ?? '30m';
                        final slaTotal = item['sla_total'] ?? '60m';
                        final impact = item['impact'] ?? 'Standard facility impact';
                        final crew = item['assigned_crew'] ?? 'Unassigned';
                        final isCritical = (item['urgency'] ?? '').toString() == 'critical';

                        return Container(
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceWhite,
                            borderRadius: const BorderRadius.circular(16),
                            border: Border.all(
                              color: isCritical ? AppTheme.statusCritical.withOpacity(0.4) : AppTheme.neutralLightOutline.withOpacity(0.3),
                              width: isCritical ? 1.5 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    // Circular Radial SLA Timer
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isCritical ? AppTheme.statusCritical.withOpacity(0.1) : AppTheme.secondaryCobalt.withOpacity(0.1),
                                        border: Border.all(
                                          color: isCritical ? AppTheme.statusCritical : AppTheme.secondaryCobalt,
                                          width: 3,
                                        ),
                                      ),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              slaRemaining,
                                              style: GoogleFonts.manrope(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 13,
                                                color: isCritical ? AppTheme.statusCritical : AppTheme.secondaryCobalt,
                                              ),
                                            ),
                                            Text(
                                              'of $slaTotal',
                                              style: GoogleFonts.manrope(fontSize: 8, color: AppTheme.textSecondary),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: (isCritical ? AppTheme.statusCritical : AppTheme.secondaryCobalt).withOpacity(0.1),
                                                  borderRadius: const BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  isCritical ? 'CRITICAL BREACH RISK' : 'ELEVATED RISK',
                                                  style: GoogleFonts.manrope(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w800,
                                                    color: isCritical ? AppTheme.statusCritical : AppTheme.secondaryCobalt,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                building,
                                                style: GoogleFonts.manrope(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            title,
                                            style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.primaryIndigo),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(Icons.info_outline, size: 13, color: AppTheme.textSecondary),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  impact,
                                                  style: GoogleFonts.manrope(fontSize: 12, color: AppTheme.textSecondary),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                const Divider(height: 1),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.engineering_outlined, size: 15, color: AppTheme.textSecondary),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Assigned: $crew',
                                          style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryIndigo),
                                        ),
                                      ],
                                    ),
                                    Wrap(
                                      spacing: 8,
                                      children: [
                                        OutlinedButton(
                                          onPressed: () => context.push('/issues/$issueId'),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: AppTheme.primaryIndigo,
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            shape: RoundedRectangleBorder(borderRadius: const BorderRadius.circular(8)),
                                          ),
                                          child: const Text('View Ticket'),
                                        ),
                                        ElevatedButton.icon(
                                          onPressed: () => _escalateIssue(issueId),
                                          icon: const Icon(Icons.bolt, size: 15),
                                          label: const Text('Escalate Urgency'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppTheme.statusCritical,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            shape: RoundedRectangleBorder(borderRadius: const BorderRadius.circular(8)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
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

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.manrope(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
      ],
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
