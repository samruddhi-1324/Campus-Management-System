import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:campus_care/core/network/api_client.dart';

class AcademicConcernsScreen extends StatefulWidget {
  const AcademicConcernsScreen({super.key});

  @override
  State<AcademicConcernsScreen> createState() => _AcademicConcernsScreenState();
}

class _AcademicConcernsScreenState extends State<AcademicConcernsScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _courseCodeController = TextEditingController();
  final _termController = TextEditingController();

  String _concernType = 'exam_grievance';
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _courseCodeController.dispose();
    _termController.dispose();
    super.dispose();
  }

  Future<void> _submitAcademicConcern() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      setState(() {
        _errorMessage = 'Please provide both concern title and detailed explanation.';
      });
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
        'course_code': _courseCodeController.text.trim().isEmpty ? null : _courseCodeController.text.trim(),
        'academic_term': _termController.text.trim().isEmpty ? null : _termController.text.trim(),
      });

      if (!mounted) return;

      final concernId = res.data['id'] ?? '';

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.shield_outlined, color: Colors.purple),
              SizedBox(width: 8),
              Text('Confidential Grievance Logged'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your academic concern has been securely filed under strict confidentiality.',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.08),
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  border: Border.all(color: Colors.purple.withOpacity(0.2)),
                ),
                child: Text(
                  'Record ID: $concernId\nOnly designated Academic Affairs officers have access.',
                  style: const TextStyle(fontSize: 12, color: Colors.purple),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _titleController.clear();
                _descriptionController.clear();
                _courseCodeController.clear();
                _termController.clear();
              },
              child: const Text('Done'),
            ),
          ],
        ),
      );
    } on DioException catch (e) {
      setState(() {
        _errorMessage = e.response?.data?['detail'] ?? 'Failed to submit academic concern';
      });
    } catch (_) {
      setState(() {
        _errorMessage = 'An unexpected error occurred. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confidential Academic Grievance', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Confidentiality Shield Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.08),
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    border: Border.all(color: Colors.purple.withOpacity(0.25)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.lock_person_outlined, color: Colors.purple, size: 28),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Strict Confidentiality Protection (FR-2.2)',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple, fontSize: 14),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Academic concerns are isolated from Facilities staff and visible only to Academic Affairs officers with logged audit trails.',
                              style: TextStyle(fontSize: 12, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.08),
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                  ),
                  const SizedBox(height: 16),
                ],
                DropdownButtonFormField<String>(
                  value: _concernType,
                  decoration: const InputDecoration(
                    labelText: 'Concern Type *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.school_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'exam_grievance', child: Text('Exam Grievance / Grading Dispute')),
                    DropdownMenuItem(value: 'grade_dispute', child: Text('Grade Dispute / Evaluation Appeal')),
                    DropdownMenuItem(value: 'course_scheduling', child: Text('Course Scheduling / Clash')),
                    DropdownMenuItem(value: 'faculty_advising', child: Text('Faculty Advising / Thesis Supervision')),
                    DropdownMenuItem(value: 'other', child: Text('Other Academic Matter')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _concernType = val);
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Subject / Concern Summary *',
                    hintText: 'e.g. Midterm grade discrepancy in CS301',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _courseCodeController,
                        decoration: const InputDecoration(
                          labelText: 'Course Code (Optional)',
                          hintText: 'e.g. CS301',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _termController,
                        decoration: const InputDecoration(
                          labelText: 'Academic Term (Optional)',
                          hintText: 'e.g. Fall 2026',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Detailed Explanation *',
                    hintText: 'Provide chronological details, relevant dates, exam questions, or communications...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitAcademicConcern,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Submit Confidential Grievance', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
