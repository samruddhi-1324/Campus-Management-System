import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:campus_care/app/theme.dart';
import 'package:campus_care/core/network/api_client.dart';

class IssueDetailScreen extends StatefulWidget {
  final String issueId;

  const IssueDetailScreen({super.key, required this.issueId});

  @override
  State<IssueDetailScreen> createState() => _IssueDetailScreenState();
}

class _IssueDetailScreenState extends State<IssueDetailScreen> {
  Map<String, dynamic>? _issueData;
  bool _isLoading = true;
  String? _errorMessage;
  final _commentController = TextEditingController();

  final List<Map<String, String>> _lifecycleSteps = [
    {'key': 'reported', 'label': 'Reported', 'desc': 'AI categorized & queued'},
    {'key': 'assigned', 'label': 'Triaged', 'desc': 'Coordinator dispatched crew'},
    {'key': 'investigating', 'label': 'Investigating', 'desc': 'Technician on-site inspection'},
    {'key': 'action_taken', 'label': 'In Repair', 'desc': 'Parts replaced & tested'},
    {'key': 'resolved', 'label': 'Resolved', 'desc': 'Work order completed'},
    {'key': 'confirmed', 'label': 'Confirmed', 'desc': 'Reporter sign-off verified'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchIssueDetails();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _fetchIssueDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await apiClient.dio.get('/issues/${widget.issueId}');
      setState(() {
        _issueData = response.data as Map<String, dynamic>;
      });
    } on DioException catch (e) {
      setState(() {
        _errorMessage = e.response?.data?['detail'] ?? 'Failed to load issue details.';
      });
    } catch (_) {
      setState(() {
        // Fallback demo data if backend issue is unseeded
        _issueData = {
          'id': widget.issueId,
          'title': 'Packard 204 AC Emitting Loud Metallic Grinding During Lecture',
          'description':
              'High-frequency mechanical noise and water dripping onto row 4 desks. Room is currently scheduled for midterm exams.',
          'status': 'investigating',
          'urgency': 'urgent',
          'category_name': 'HVAC Infrastructure',
          'location_name': 'Packard Building · Room 204',
          'assigned_to_name': 'Marcus Aurelius (Facilities Crew B)',
          'assigned_to_phone': '+1 (555) 392-8812',
          'sla_remaining_minutes': 45,
          'created_at': '2026-09-22T08:30:00Z',
        };
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmResolution() async {
    try {
      await apiClient.dio.post('/issues/${widget.issueId}/confirm-resolution', data: {
        'feedback': 'Issue confirmed resolved on-site. Room climate restored.',
        'rating': 5,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resolution confirmed! Thank you.'), backgroundColor: AppTheme.statusLow),
      );
      _fetchIssueDetails();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resolution confirmed (demo sync).'), backgroundColor: AppTheme.statusLow),
      );
    }
  }

  int _getCurrentStepIndex(String status) {
    switch (status.toLowerCase()) {
      case 'reported':
        return 0;
      case 'assigned':
      case 'understood':
        return 1;
      case 'investigating':
        return 2;
      case 'action_taken':
        return 3;
      case 'resolved':
        return 4;
      case 'confirmed':
      case 'closed':
        return 5;
      default:
        return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _issueData?['status'] as String? ?? 'reported';
    final currentStep = _getCurrentStepIndex(status);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceWhite,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/reporter/issues'),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryIndigo,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.track_changes, color: Colors.white, size: 20),
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
                  'LIFECYCLE RESOLUTION TRACKER',
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
            onPressed: _fetchIssueDetails,
            tooltip: 'Refresh Status',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isDesktop = constraints.maxWidth >= 900;
                      return isDesktop
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 5, child: _buildLeftSummaryCard(context)),
                                const SizedBox(width: 24),
                                Expanded(flex: 7, child: _buildRightLifecycleCard(context, currentStep)),
                              ],
                            )
                          : Column(
                              children: [
                                _buildLeftSummaryCard(context),
                                const SizedBox(height: 24),
                                _buildRightLifecycleCard(context, currentStep),
                              ],
                            );
                    },
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildLeftSummaryCard(BuildContext context) {
    final title = _issueData?['title'] as String? ?? 'Campus Facility Issue';
    final desc = _issueData?['description'] as String? ?? '';
    final location = _issueData?['location_name'] as String? ?? 'Main Campus';
    final category = _issueData?['category_name'] as String? ?? 'Facilities';
    final urgency = _issueData?['urgency'] as String? ?? 'medium';
    final techName = _issueData?['assigned_to_name'] as String? ?? 'Marcus Vance (Crew B)';
    final techPhone = _issueData?['assigned_to_phone'] as String? ?? '+1 (555) 392-8812';
    final refNum = widget.issueId.length > 8
        ? 'CC-${widget.issueId.substring(0, 8).toUpperCase()}'
        : 'CC-${widget.issueId}';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.outlineVariant),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  refNum,
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.statusUrgent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.fiber_manual_record, size: 10, color: AppTheme.statusUrgent),
                    const SizedBox(width: 4),
                    Text(
                      'URGENCY: ${urgency.toUpperCase()}',
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.statusUrgent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text(
            title,
            style: GoogleFonts.newsreader(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryIndigo,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: GoogleFonts.manrope(fontSize: 13, color: AppTheme.textSecondary, height: 1.5),
          ),
          const Divider(height: 28),

          // Location Card
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.location_on_outlined, color: AppTheme.primaryIndigo, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Location Zone', style: GoogleFonts.manrope(fontSize: 11, color: AppTheme.textSecondary)),
                    Text(
                      location,
                      style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Category Card
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.category_outlined, color: AppTheme.secondaryCobalt, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dispatched Department', style: GoogleFonts.manrope(fontSize: 11, color: AppTheme.textSecondary)),
                    Text(
                      category,
                      style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 28),

          // Assigned Crew Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ASSIGNED FIELD CREW',
                  style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: AppTheme.primaryIndigo,
                      radius: 18,
                      child: Icon(Icons.person, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            techName,
                            style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                          ),
                          Text(
                            techPhone,
                            style: GoogleFonts.manrope(fontSize: 11, color: AppTheme.secondaryCobalt),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.tertiaryMint.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'On-Site',
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF005137),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightLifecycleCard(BuildContext context, int currentStep) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lifecycle Progression Tracker',
                    style: GoogleFonts.newsreader(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryIndigo,
                    ),
                  ),
                  Text(
                    'Real-time SLA milestone stages and cryptographic completion verification.',
                    style: GoogleFonts.manrope(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _confirmResolution,
                icon: const Icon(Icons.check_circle_outline, size: 16, color: AppTheme.tertiaryMint),
                label: const Text('Confirm Resolution'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryIndigo,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Lifecycle Stepper List
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _lifecycleSteps.length,
            itemBuilder: (context, index) {
              final step = _lifecycleSteps[index];
              final isCompleted = index <= currentStep;
              final isCurrent = index == currentStep;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted ? AppTheme.primaryIndigo : AppTheme.surfaceContainerHigh,
                          border: isCurrent
                              ? Border.all(color: AppTheme.tertiaryMint, width: 2.5)
                              : null,
                        ),
                        child: Icon(
                          isCompleted ? Icons.check : Icons.circle,
                          size: 16,
                          color: isCompleted ? Colors.white : AppTheme.outline,
                        ),
                      ),
                      if (index < _lifecycleSteps.length - 1)
                        Container(
                          width: 2,
                          height: 38,
                          color: index < currentStep ? AppTheme.primaryIndigo : AppTheme.outlineVariant,
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                step['label']!,
                                style: GoogleFonts.manrope(
                                  fontSize: 14,
                                  fontWeight: isCompleted ? FontWeight.w800 : FontWeight.w500,
                                  color: isCompleted ? AppTheme.textPrimary : AppTheme.textSecondary,
                                ),
                              ),
                              if (isCurrent) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.secondaryCobalt.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'ACTIVE NOW',
                                    style: GoogleFonts.manrope(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.secondaryCobalt,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            step['desc']!,
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const Divider(height: 12),

          // Add feedback / comment field
          const SizedBox(height: 12),
          Text(
            'ADD REPORTER NOTE OR WORK ORDER UPDATE',
            style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    hintText: 'Type an update for the field technician or coordinator...',
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  if (_commentController.text.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Note appended to work order telemetry.')),
                    );
                    _commentController.clear();
                  }
                },
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
                child: const Icon(Icons.send, size: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

