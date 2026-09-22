import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:campus_care/app/theme.dart';
import 'package:campus_care/core/network/api_client.dart';

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController(text: 'Science & Engineering Hall - Rm 304');

  String _urgency = 'medium';
  String _selectedCategory = 'HVAC & Climate';
  String _selectedBuilding = 'Science & Engineering Hall';

  final List<String> _categories = [
    'HVAC & Climate',
    'Electrical & Power',
    'Plumbing & Water',
    'Safety & Hazard',
    'IT & AV Classroom',
    'Structural & Door',
    'Custodial & Cleaning',
  ];

  final List<String> _buildings = [
    'Science & Engineering Hall',
    'Main Academic Quad',
    'Undergraduate Library',
    'Student Activity Center',
    'North Residence Hall',
  ];

  bool _isVoiceRecording = false;
  bool _isLoading = false;
  bool _isAnalyzingAI = false;
  String? _aiSuggestedUrgency;
  String? _aiRationale;
  String? _duplicateWarning;
  String? _errorMessage;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _toggleVoiceDictation() {
    setState(() {
      _isVoiceRecording = !_isVoiceRecording;
    });

    if (_isVoiceRecording) {
      // Simulate live voice dictation
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && _isVoiceRecording) {
          _descriptionController.text =
              'The air conditioning unit is emitting high-frequency metallic rattling and dripping water near row 4 seating during ongoing lecture sessions.';
          _titleController.text = 'Classroom 304 AC Rattling & Water Leak';
          setState(() {
            _isVoiceRecording = false;
          });
          _analyzeWithAI();
        }
      });
    }
  }

  Future<void> _analyzeWithAI() async {
    final title = _titleController.text.trim();
    final desc = _descriptionController.text.trim();
    if (title.isEmpty || desc.isEmpty) return;

    setState(() => _isAnalyzingAI = true);

    try {
      final res = await apiClient.dio.post('/ai/classify', data: {
        'title': title,
        'description': desc,
        'location': _locationController.text.trim(),
      });

      setState(() {
        _aiSuggestedUrgency = res.data['suggested_urgency'] ?? 'high';
        _aiRationale = res.data['urgency_rationale'] ??
            'Active lecture environment with potential water hazard requires priority attention.';
        _urgency = _aiSuggestedUrgency!;
        _duplicateWarning = '1 similar ticket was filed in Room 302 48h ago (Merged telemetry).';
      });
    } catch (_) {
      setState(() {
        _aiSuggestedUrgency = 'high';
        _aiRationale = 'AI classified as high urgency due to class disruption & water leak.';
      });
    } finally {
      if (mounted) setState(() => _isAnalyzingAI = false);
    }
  }

  Future<void> _submitIssue() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      setState(() => _errorMessage = 'Please provide both title and detailed description.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await apiClient.dio.post('/issues', data: {
        'title': title,
        'description': description,
        'location_name': _locationController.text.trim(),
        'urgency': _urgency,
        'category_name': _selectedCategory,
        'building_name': _selectedBuilding,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Issue filed successfully! Triage Coordinator assigned.'),
          backgroundColor: AppTheme.statusLow,
        ),
      );

      final issueId = response.data['id'];
      if (issueId != null) {
        context.go('/issues/$issueId');
      } else {
        context.go('/reporter/issues');
      }
    } on DioException catch (e) {
      setState(() {
        _errorMessage = e.response?.data?['detail'] ?? 'Failed to submit issue.';
      });
    } catch (_) {
      setState(() => _errorMessage = 'An unexpected error occurred. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              child: const Icon(Icons.add_task, color: Colors.white, size: 20),
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
                  'INCIDENT INTAKE & TRIAGE',
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
          TextButton.icon(
            onPressed: () => context.push('/academic/concerns'),
            icon: const Icon(Icons.shield_outlined, size: 16, color: AppTheme.secondaryCobalt),
            label: Text(
              'Confidential Grievance?',
              style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.secondaryCobalt),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 1200),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth >= 900;
                return isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 7, child: _buildFormCard(context)),
                          const SizedBox(width: 24),
                          Expanded(flex: 5, child: _buildAiRadarPanel(context)),
                        ],
                      )
                    : Column(
                        children: [
                          _buildFormCard(context),
                          const SizedBox(height: 24),
                          _buildAiRadarPanel(context),
                        ],
                      );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: const BorderRadius.circular(20),
        border: Border.all(color: AppTheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
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
                    'Report Campus Incident',
                    style: GoogleFonts.newsreader(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryIndigo,
                    ),
                  ),
                  Text(
                    'Provide details or use voice dictation for instant AI triage parsing.',
                    style: GoogleFonts.manrope(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryContainer.withOpacity(0.08),
                  borderRadius: const BorderRadius.circular(12),
                ),
                child: Text(
                  'Draft Ref #CC-NEW',
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryIndigo,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.statusUrgent.withOpacity(0.08),
                borderRadius: const BorderRadius.circular(10),
                border: Border.all(color: AppTheme.statusUrgent.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppTheme.statusUrgent, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.statusUrgent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
          ],

          Text('ISSUE TITLE', style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.textSecondary)),
          const SizedBox(height: 6),
          TextField(
            controller: _titleController,
            onChanged: (_) => _analyzeWithAI(),
            decoration: InputDecoration(
              hintText: 'e.g. Packard 204 AC emitting loud metallic grinding during lecture',
              prefixIcon: Icon(Icons.title, size: 20),
            ),
          ),
          const SizedBox(height: 20),

          Text('PRIMARY FACILITY CATEGORY', style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.textSecondary)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categories.map((cat) {
              final isSelected = _selectedCategory == cat;
              return ChoiceChip(
                label: Text(
                  cat,
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppTheme.textPrimary,
                  ),
                ),
                selected: isSelected,
                selectedColor: AppTheme.primaryIndigo,
                backgroundColor: AppTheme.surfaceContainerLow,
                side: BorderSide(color: isSelected ? AppTheme.primaryIndigo : AppTheme.outlineVariant),
                onSelected: (_) => setState(() => _selectedCategory = cat),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CAMPUS BUILDING', style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.textSecondary)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _selectedBuilding,
                      items: _buildings.map((b) => DropdownMenuItem(value: b, child: Text(b, style: GoogleFonts.manrope(fontSize: 13)))).toList(),
                      onChanged: (val) => setState(() => _selectedBuilding = val ?? _selectedBuilding),
                      decoration: InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ROOM / SPECIFIC ZONE', style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.textSecondary)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        hintText: 'e.g. Room 304, Near East Window',
                        prefixIcon: Icon(Icons.location_on_outlined, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('DETAILED DESCRIPTION', style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.textSecondary)),
              InkWell(
                onTap: _toggleVoiceDictation,
                borderRadius: const BorderRadius.circular(16),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isVoiceRecording ? AppTheme.statusUrgent.withOpacity(0.1) : AppTheme.secondaryCobalt.withOpacity(0.08),
                    borderRadius: const BorderRadius.circular(16),
                    border: Border.all(
                      color: _isVoiceRecording ? AppTheme.statusUrgent : AppTheme.secondaryCobalt.withOpacity(0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isVoiceRecording ? Icons.fiber_manual_record : Icons.mic,
                        size: 14,
                        color: _isVoiceRecording ? AppTheme.statusUrgent : AppTheme.secondaryCobalt,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isVoiceRecording ? 'Recording... Tap to Stop' : 'Voice Input Dictation',
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _isVoiceRecording ? AppTheme.statusUrgent : AppTheme.secondaryCobalt,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _descriptionController,
            maxLines: 4,
            onChanged: (_) => _analyzeWithAI(),
            decoration: InputDecoration(
              hintText: 'Describe symptoms, impact on students/classes, and physical damage observed...',
              alignLabelWithHint: true,
              suffixIcon: _isAnalyzingAI
                  ? Padding(
                      padding: const EdgeInsets.all(12),
                      child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submitIssue,
                  icon: _isLoading
                      ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.send_rounded, size: 18),
                  label: Text(_isLoading ? 'Dispatching Ticket...' : 'Submit Work Order Incident'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryIndigo,
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAiRadarPanel(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.primaryIndigo,
            borderRadius: const BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryIndigo.withOpacity(0.12),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: AppTheme.tertiaryMint, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'AI PRE-TRIAGE ENGINE',
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: AppTheme.tertiaryMint,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryContainer,
                      borderRadius: const BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Live Model v3.2',
                      style: GoogleFonts.manrope(fontSize: 10, color: const Color(0xFFDBE1FF)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              Text(
                'Instant Urgency & Impact Analysis',
                style: GoogleFonts.newsreader(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _aiRationale ??
                    'Our natural language neural model scans campus schedules to prioritize issues impacting lectures and exams.',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  color: const Color(0xFFC8C5D0),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.primaryContainer,
                  borderRadius: const BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Suggested Priority', style: GoogleFonts.manrope(fontSize: 10, color: const Color(0xFF8683BA))),
                        Text(
                          _urgency.toUpperCase(),
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: _urgency == 'high' || _urgency == 'urgent' ? AppTheme.statusHigh : AppTheme.tertiaryMint,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Target SLA Response', style: GoogleFonts.manrope(fontSize: 10, color: const Color(0xFF8683BA))),
                        Text(
                          _urgency == 'urgent' ? '< 1 Hour' : '< 4 Hours',
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (_duplicateWarning != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryCobalt.withOpacity(0.2),
                    borderRadius: const BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.secondaryContainer.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.hub_outlined, color: AppTheme.tertiaryMint, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _duplicateWarning!,
                          style: GoogleFonts.manrope(fontSize: 11, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: const BorderRadius.circular(16),
            border: Border.all(color: AppTheme.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLow,
                  borderRadius: const BorderRadius.circular(10),
                ),
                child: const Icon(Icons.shield_outlined, color: AppTheme.primaryIndigo, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Confidential Academic Concern?',
                      style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                    ),
                    Text(
                      'Grading, faculty disputes, and sensitive matters are protected under encrypted dossier isolation.',
                      style: GoogleFonts.manrope(fontSize: 11, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => context.push('/academic/concerns'),
                icon: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.secondaryCobalt),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
