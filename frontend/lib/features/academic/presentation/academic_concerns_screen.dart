import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:campus_care/app/theme.dart';
import 'package:campus_care/core/network/api_client.dart';

class AcademicConcernsScreen extends StatefulWidget {
  const AcademicConcernsScreen({super.key});

  @override
  State<AcademicConcernsScreen> createState() => _AcademicConcernsScreenState();
}

class _AcademicConcernsScreenState extends State<AcademicConcernsScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _courseCodeController = TextEditingController(text: 'CS-482 / Advanced Distributed Systems');
  final _termController = TextEditingController(text: 'Fall 2026');
  final _facultyController = TextEditingController(text: 'Prof. Henderson · Dept of Computer Science');

  String _concernType = 'grading_dispute';
  bool _isAnonymous = false;
  bool _isLoading = false;
  String? _errorMessage;

  final List<Map<String, String>> _grievanceTypes = [
    {'key': 'grading_dispute', 'label': 'Grading & Evaluation Dispute'},
    {'key': 'thesis_impasse', 'label': 'Thesis / Capstone Committee Impasse'},
    {'key': 'research_ethics', 'label': 'Research Ethics & Authorship'},
    {'key': 'faculty_conduct', 'label': 'Faculty Conduct & Pedagogy'},
    {'key': 'retaliation', 'label': 'Retaliation & Bias Protection'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _courseCodeController.dispose();
    _termController.dispose();
    _facultyController.dispose();
    super.dispose();
  }

  Future<void> _submitAcademicConcern() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      setState(() => _errorMessage = 'Please provide both concern summary and detailed statement.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await apiClient.dio.post('/academic/concerns', data: {
        'title': title,
        'description': description,
        'concern_type': _concernType,
        'course_code': _courseCodeController.text.trim(),
        'academic_term': _termController.text.trim(),
        'is_anonymous': _isAnonymous,
      });

      if (!mounted) return;
      final concernId = res.data['id'] ?? 'AC-8821';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Confidential Grievance Dossier #$concernId logged securely.'),
          backgroundColor: AppTheme.primaryIndigo,
        ),
      );
      context.go('/reporter/issues');
    } on DioException catch (e) {
      setState(() {
        _errorMessage = e.response?.data?['detail'] ?? 'Failed to submit grievance.';
      });
    } catch (_) {
      setState(() => _errorMessage = 'An error occurred while submitting encrypted dossier.');
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
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: const Icon(Icons.shield_outlined, color: Colors.white, size: 20),
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
                  'CONFIDENTIAL ACADEMIC GRIEVANCE',
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
            icon: const Icon(Icons.lock_person_outlined, color: AppTheme.secondaryCobalt),
            onPressed: () => context.push('/academic/triage'),
            tooltip: 'Academic Officer Workspace',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
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
                          Expanded(flex: 7, child: _buildFormCard(context)),
                          const SizedBox(width: 24),
                          Expanded(flex: 5, child: _buildCharterPanel(context)),
                        ],
                      )
                    : Column(
                        children: [
                          _buildFormCard(context),
                          const SizedBox(height: 24),
                          _buildCharterPanel(context),
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Privacy Shield Ribbon
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.primaryIndigo,
              borderRadius: const BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.security, color: AppTheme.tertiaryMint, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FERPA & Whistleblower Protected Dossier',
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Isolated from public facilities tickets. Visible strictly to Academic Ombudspersons.',
                        style: GoogleFonts.manrope(fontSize: 11, color: const Color(0xFFC8C5D0)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Anonymity Toggle Strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow,
              borderRadius: const BorderRadius.circular(12),
              border: Border.all(color: AppTheme.outlineVariant),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Anonymize My Submission',
                      style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                    ),
                    Text(
                      'Masks student identity token from academic panel review',
                      style: GoogleFonts.manrope(fontSize: 11, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
                Switch.adaptive(
                  value: _isAnonymous,
                  activeColor: AppTheme.secondaryCobalt,
                  onChanged: (val) => setState(() => _isAnonymous = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.statusUrgent.withOpacity(0.08),
                borderRadius: const BorderRadius.circular(10),
                border: Border.all(color: AppTheme.statusUrgent.withOpacity(0.3)),
              ),
              child: Text(
                _errorMessage!,
                style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.statusUrgent),
              ),
            ),
            const SizedBox(height: 18),
          ],

          Text('GRIEVANCE CLASSIFICATION', style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.textSecondary)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _grievanceTypes.map((item) {
              final isSelected = _concernType == item['key'];
              return ChoiceChip(
                label: Text(
                  item['label']!,
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
                onSelected: (_) => setState(() => _concernType = item['key']!),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          Text('CONCERN SUMMARY', style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.textSecondary)),
          const SizedBox(height: 6),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              hintText: 'e.g. Unfair grading criteria deviation on Midterm exam weighting',
              prefixIcon: Icon(Icons.edit_note, size: 20),
            ),
          ),
          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('COURSE CODE', style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.textSecondary)),
                    const SizedBox(height: 6),
                    TextField(controller: _courseCodeController, decoration: const InputDecoration(hintText: 'e.g. CS-482')),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ACADEMIC TERM', style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.textSecondary)),
                    const SizedBox(height: 6),
                    TextField(controller: _termController, decoration: const InputDecoration(hintText: 'e.g. Fall 2026')),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          Text('FACULTY / COMMITTEE INVOLVED', style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.textSecondary)),
          const SizedBox(height: 6),
          TextField(controller: _facultyController, decoration: const InputDecoration(hintText: 'e.g. Prof. Henderson · Dept Chair')),
          const SizedBox(height: 18),

          Text('DETAILED STATEMENT & TIMELINE OF EVENTS', style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.textSecondary)),
          const SizedBox(height: 6),
          TextField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Provide specific dates, syllabus clauses violated, and prior informal communications attempted...',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 24),

          ElevatedButton.icon(
            onPressed: _isLoading ? null : _submitAcademicConcern,
            icon: _isLoading
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.lock_outline, size: 18),
            label: Text(_isLoading ? 'Submitting Encrypted Dossier...' : 'File Confidential Academic Grievance'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryIndigo,
              padding: const EdgeInsets.symmetric(vertical: 16),
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharterPanel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primaryIndigo,
        borderRadius: const BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.policy_outlined, color: AppTheme.tertiaryMint, size: 22),
              const SizedBox(width: 8),
              Text(
                'ACADEMIC OMBUDS CHARTER',
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppTheme.tertiaryMint,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text(
            'Institutional Rights & Protections',
            style: GoogleFonts.newsreader(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Academic concerns are governed under University Senate Regulation Section 4.12.',
            style: GoogleFonts.manrope(fontSize: 12, color: const Color(0xFFC8C5D0)),
          ),
          const SizedBox(height: 20),

          _buildCharterItem(Icons.timer_outlined, '72-Hour Review SLA', 'An Academic Officer reviews submissions within 3 business days.'),
          const SizedBox(height: 14),
          _buildCharterItem(Icons.security, 'Zero Retaliation Guarantee', 'Strict disciplinary enforcement against adverse student evaluation impact.'),
          const SizedBox(height: 14),
          _buildCharterItem(Icons.history_edu, 'Immutable Audit Trail', 'All officer views and disposition decisions are permanently logged.'),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.primaryContainer,
              borderRadius: const BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_user_outlined, color: AppTheme.tertiaryMint, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Case assigned to Designated Ombudsperson Panel on submission.',
                    style: GoogleFonts.manrope(fontSize: 11, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharterItem(IconData icon, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFFDBE1FF), size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 2),
              Text(desc, style: GoogleFonts.manrope(fontSize: 11, color: const Color(0xFFC8C5D0))),
            ],
          ),
        ),
      ],
    );
  }
}
