import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:campus_care/core/network/api_client.dart';

class ConfidentialTriageScreen extends StatefulWidget {
  final String concernId;

  const ConfidentialTriageScreen({super.key, required this.concernId});

  @override
  State<ConfidentialTriageScreen> createState() => _ConfidentialTriageScreenState();
}

class _ConfidentialTriageScreenState extends State<ConfidentialTriageScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _concern;
  final _privateNotesController = TextEditingController();
  final _resolutionNotesController = TextEditingController();
  String _selectedStatus = 'under_investigation';
  bool _isSaving = false;

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
      _errorMessage = null;
    });

    try {
      final res = await apiClient.dio.get('/academic/concerns/${widget.concernId}');
      setState(() {
        _concern = res.data;
        _selectedStatus = _concern?['status'] ?? 'under_investigation';
        _privateNotesController.text = _concern?['private_officer_notes'] ?? '';
      });
    } on DioException catch (e) {
      setState(() {
        _errorMessage = e.response?.data?['detail'] ?? 'Failed to load confidential concern.';
      });
    } catch (_) {
      setState(() {
        _errorMessage = 'An unexpected error occurred while fetching details.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateConcern() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final res = await apiClient.dio.patch('/academic/concerns/${widget.concernId}', data: {
        'status': _selectedStatus,
        'private_officer_notes': _privateNotesController.text.trim().isEmpty ? null : _privateNotesController.text.trim(),
        'resolution_notes': _resolutionNotesController.text.trim().isEmpty ? null : _resolutionNotesController.text.trim(),
      });

      if (!mounted) return;

      setState(() {
        _concern = res.data;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Academic grievance disposition updated securely.'),
          backgroundColor: Colors.green,
        ),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.response?.data?['detail'] ?? 'Failed to update concern.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confidential Review #${widget.concernId.length > 8 ? widget.concernId.substring(0, 8) : widget.concernId}'),
        backgroundColor: Colors.purple.shade900,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shield_outlined, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontSize: 16)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchConcernDetails,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Audit Log Security Notice
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.08),
                              borderRadius: const BorderRadius.all(Radius.circular(12)),
                              border: Border.all(color: Colors.purple.withOpacity(0.3)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.security, color: Colors.purple, size: 28),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Confidential Access Logged (NFR-SEC-01)',
                                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Your access timestamp, identity, and role have been permanently recorded in the confidential audit log.',
                                        style: TextStyle(fontSize: 12, color: Colors.black87),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Concern Info Card
                          Card(
                            elevation: 1,
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
                                      Expanded(
                                        child: Text(
                                          _concern?['title'] ?? 'Academic Grievance',
                                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.purple.withOpacity(0.12),
                                          borderRadius: const BorderRadius.all(Radius.circular(6)),
                                        ),
                                        child: Text(
                                          (_concern?['status'] ?? 'submitted').toString().toUpperCase(),
                                          style: TextStyle(color: Colors.purple.shade800, fontWeight: FontWeight.bold, fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 8,
                                    children: [
                                      Chip(
                                        avatar: const Icon(Icons.school, size: 16),
                                        label: Text('Type: ${_concern?['concern_type'] ?? 'General'}'),
                                      ),
                                      if (_concern?['course_code'] != null)
                                        Chip(
                                          avatar: const Icon(Icons.book, size: 16),
                                          label: Text('Course: ${_concern?['course_code']}'),
                                        ),
                                      if (_concern?['academic_term'] != null)
                                        Chip(
                                          avatar: const Icon(Icons.calendar_month, size: 16),
                                          label: Text('Term: ${_concern?['academic_term']}'),
                                        ),
                                    ],
                                  ),
                                  const Divider(height: 28),
                                  const Text('Student Explanation:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  const SizedBox(height: 8),
                                  Text(
                                    _concern?['description'] ?? 'No description provided.',
                                    style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Triage Disposition Form
                          Card(
                            elevation: 1,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                              side: BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Academic Officer Triage & Action', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 16),
                                  DropdownButtonFormField<String>(
                                    value: _selectedStatus,
                                    decoration: const InputDecoration(
                                      labelText: 'Disposition Status',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.flag_outlined),
                                    ),
                                    items: const [
                                      DropdownMenuItem(value: 'submitted', child: Text('Submitted / New')),
                                      DropdownMenuItem(value: 'under_investigation', child: Text('Under Confidential Investigation')),
                                      DropdownMenuItem(value: 'escalated', child: Text('Escalated to Department Head / Dean')),
                                      DropdownMenuItem(value: 'resolved', child: Text('Resolved')),
                                      DropdownMenuItem(value: 'closed', child: Text('Closed / Dismissed')),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) setState(() => _selectedStatus = val);
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                    controller: _privateNotesController,
                                    maxLines: 3,
                                    decoration: const InputDecoration(
                                      labelText: 'Confidential Officer Notes (Restricted View)',
                                      hintText: 'Internal academic notes visible only to authorized Academic Affairs officers...',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                    controller: _resolutionNotesController,
                                    maxLines: 3,
                                    decoration: const InputDecoration(
                                      labelText: 'Resolution Summary (Visible to Student upon resolution)',
                                      hintText: 'Outcome or action taken for the student...',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: _isSaving ? null : _updateConcern,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.purple.shade800,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                    ),
                                    child: _isSaving
                                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                        : const Text('Save Confidential Disposition', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}
