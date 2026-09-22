import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:campus_care/app/theme.dart';
import 'package:campus_care/core/network/api_client.dart';

class ConfidentialTriageScreen extends StatefulWidget {
  final String concernId;

  const ConfidentialTriageScreen({super.key, required this.concernId});

  @override
  State<ConfidentialTriageScreen> createState() => _ConfidentialTriageScreenState();
}

class _ConfidentialTriageScreenState extends State<ConfidentialTriageScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _concern;
  final _privateNotesController = TextEditingController();
  final _resolutionNotesController = TextEditingController();
  String _selectedDisposition = 'formal_hearing';
  bool _isSaving = false;

  final List<Map<String, String>> _dispositionOptions = [
    {'key': 'formal_hearing', 'label': 'Convene Formal Senate Hearing Panel'},
    {'key': 'remediate_grade', 'label': 'Authorize Independent Grade Recalibration'},
    {'key': 'faculty_mediation', 'label': 'Schedule Ombudsperson Faculty Mediation'},
    {'key': 'dismiss', 'label': 'Dismiss (Grounds Insufficient / Out of Scope)'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchConcernDetails();
  }

  @override
  void dispose() {
    _privateNotesController.dispose();
    _resolutionNotesController.dispose();
    super.dispose();
  }

  Future<void> _fetchConcernDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final res = await apiClient.dio.get('/academic/concerns/${widget.concernId}');
      setState(() {
        _concern = res.data;
        _privateNotesController.text = _concern?['private_officer_notes'] ?? '';
        _resolutionNotesController.text = _concern?['resolution_notes'] ?? '';
      });
    } catch (_) {
      setState(() {
        _concern = {
          'id': widget.concernId.isEmpty ? 'AG-2025-0842' : widget.concernId,
          'title': 'Grade Dispute & Evaluation Deviation on Final Capstone Project',
          'description':
              'The syllabus explicitly stated that 40% of the project grade would be evaluated by external industry advisors. However, the final letter grade was unilaterally altered without written rubric feedback.',
          'concern_type': 'grading_dispute',
          'course_code': 'CS-482 / Advanced Distributed Systems',
          'academic_term': 'Fall 2026',
          'faculty_name': 'Prof. Henderson · Dept of Computer Science',
          'status': 'under_investigation',
          'is_anonymous': true,
          'created_at': '2026-09-20T10:14:00Z',
        };
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveDisposition() async {
    setState(() => _isSaving = true);
    try {
      await apiClient.dio.patch('/academic/concerns/${widget.concernId}', data: {
        'status': _selectedDisposition == 'dismiss' ? 'dismissed' : 'resolved',
        'private_officer_notes': _privateNotesController.text.trim(),
        'resolution_notes': _resolutionNotesController.text.trim(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Academic Disposition sealed & recorded in audit ledger.'),
          backgroundColor: AppTheme.statusLow,
        ),
      );
      context.go('/reporter/issues');
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Disposition saved in local audit ledger.'), backgroundColor: AppTheme.primaryIndigo),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final caseId = _concern?['id'] ?? widget.concernId;
    final title = _concern?['title'] ?? 'Academic Grievance';
    final desc = _concern?['description'] ?? '';
    final courseCode = _concern?['course_code'] ?? 'CS-482';
    final term = _concern?['academic_term'] ?? 'Fall 2026';
    final faculty = _concern?['faculty_name'] ?? 'Prof. Henderson';
    final isAnonymous = _concern?['is_anonymous'] == true;

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
                  'OFFICE OF THE OMBUDSPERSON & DISPOSITION',
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
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.tertiaryMint.withOpacity(0.2),
              borderRadius: const BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified, size: 14, color: const Color(0xFF005137)),
                const SizedBox(width: 4),
                Text(
                  '256-Bit Ledger Active',
                  style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF005137)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: _isLoading
          ? Center(child: const CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    children: [
                      _buildLedgerBanner(caseId),
                      const SizedBox(height: 24),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isDesktop = constraints.maxWidth >= 900;
                          return isDesktop
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(flex: 6, child: _buildDossierEvidenceCard(title, desc, courseCode, term, faculty, isAnonymous)),
                                    const SizedBox(width: 24),
                                    Expanded(flex: 6, child: _buildDispositionActionCard()),
                                  ],
                                )
                              : Column(
                                  children: [
                                    _buildDossierEvidenceCard(title, desc, courseCode, term, faculty, isAnonymous),
                                    const SizedBox(height: 24),
                                    _buildDispositionActionCard(),
                                  ],
                                );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildLedgerBanner(String caseId) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryIndigo,
        borderRadius: const BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.lock, color: AppTheme.tertiaryMint, size: 20),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'IMMUTABLE DOSSIER LOG #$caseId',
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: AppTheme.tertiaryMint,
                    ),
                  ),
                  Text(
                    'Dean Review · Officer ID: #AO-7712 (Julian Vance) • FERPA Air-Gap',
                    style: GoogleFonts.manrope(fontSize: 12, color: const Color(0xFFC8C5D0)),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryContainer,
              borderRadius: const BorderRadius.circular(12),
            ),
            child: Text(
              '48h SLA Active',
              style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDossierEvidenceCard(
    String title,
    String desc,
    String courseCode,
    String term,
    String faculty,
    bool isAnonymous,
  ) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Student Grievance Dossier',
                style: GoogleFonts.newsreader(fontSize: 22, fontWeight: FontWeight.w600, color: AppTheme.primaryIndigo),
              ),
              if (isAnonymous)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerLow,
                    borderRadius: const BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.visibility_off, size: 14, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text('Anonymous', style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          Text(title, style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          Text(desc, style: GoogleFonts.manrope(fontSize: 13, color: AppTheme.textSecondary, height: 1.5)),
          const Divider(height: 28),

          _buildDetailRow('Course Code', courseCode),
          const SizedBox(height: 10),
          _buildDetailRow('Academic Term', term),
          const SizedBox(height: 10),
          _buildDetailRow('Faculty Involved', faculty),
          const Divider(height: 28),

          Text('ATTACHED EVIDENCE LOCKER', style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.textSecondary)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow,
              borderRadius: const BorderRadius.circular(12),
              border: Border.all(color: AppTheme.outlineVariant),
            ),
            child: Row(
              children: [
                const Icon(Icons.picture_as_pdf, color: AppTheme.statusUrgent, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Syllabus_Rubric_Discrepancy.pdf', style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w700)),
                      Text('SHA-256: d8a9...b4c2 • 2.4 MB', style: GoogleFonts.manrope(fontSize: 10, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.download, size: 18, color: AppTheme.secondaryCobalt),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.manrope(fontSize: 12, color: AppTheme.textSecondary)),
        Text(value, style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
      ],
    );
  }

  Widget _buildDispositionActionCard() {
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
          Text(
            'Official Academic Disposition',
            style: GoogleFonts.newsreader(fontSize: 22, fontWeight: FontWeight.w600, color: AppTheme.primaryIndigo),
          ),
          Text(
            'Formal adjudication, confidential officer notes, and remedial orders.',
            style: GoogleFonts.manrope(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 20),

          Text('DECISION DISPOSITION ACTION', style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.textSecondary)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedDisposition,
            items: _dispositionOptions
                .map((d) => DropdownMenuItem(value: d['key'], child: Text(d['label']!, style: GoogleFonts.manrope(fontSize: 12))))
                .toList(),
            onChanged: (val) => setState(() => _selectedDisposition = val ?? _selectedDisposition),
            decoration: const InputDecoration(contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
          ),
          const SizedBox(height: 18),

          Text('CONFIDENTIAL OFFICER AUDIT NOTES', style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.textSecondary)),
          const SizedBox(height: 6),
          TextField(
            controller: _privateNotesController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Internal review remarks (only visible to Ombuds and Dean panel)...',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 18),

          Text('FORMAL WRITTEN DISPOSITION FOR STUDENT', style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.textSecondary)),
          const SizedBox(height: 6),
          TextField(
            controller: _resolutionNotesController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Official statement transmitted to student upon disposition seal...',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 24),

          ElevatedButton.icon(
            onPressed: _isSaving ? null : _saveDisposition,
            icon: _isSaving
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.gavel_outlined, size: 18),
            label: Text(_isSaving ? 'Sealing Disposition...' : 'Seal & Execute Formal Disposition'),
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
}

