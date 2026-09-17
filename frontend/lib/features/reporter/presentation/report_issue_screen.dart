import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:campus_care/core/network/api_client.dart';

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  String _urgency = 'medium';
  String? _selectedCategoryId;
  String? _selectedBuildingId;

  List<dynamic> _categories = const [];
  List<dynamic> _buildings = const [];

  bool _isLoading = false;
  bool _isAnalyzingAI = false;
  String? _aiSuggestedUrgency;
  String? _aiRationale;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMasterData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadMasterData() async {
    try {
      final catRes = await apiClient.dio.get('/admin/categories');
      final buildRes = await apiClient.dio.get('/admin/buildings');
      setState(() {
        _categories = catRes.data as List<dynamic>;
        _buildings = buildRes.data as List<dynamic>;
      });
    } catch (_) {
      // Master data fallback or unseeded
    }
  }

  Future<void> _analyzeWithAI() async {
    final title = _titleController.text.trim();
    final desc = _descriptionController.text.trim();

    if (title.isEmpty || desc.isEmpty) return;

    setState(() {
      _isAnalyzingAI = true;
    });

    try {
      final res = await apiClient.dio.post('/ai/classify', data: {
        'title': title,
        'description': desc,
        'location': _locationController.text.trim(),
      });

      setState(() {
        _aiSuggestedUrgency = res.data['suggested_urgency'];
        _aiRationale = res.data['urgency_rationale'];
        if (res.data['suggested_category_id'] != null) {
          _selectedCategoryId = res.data['suggested_category_id'];
        }
        if (_aiSuggestedUrgency != null) {
          _urgency = _aiSuggestedUrgency!;
        }
      });
    } catch (_) {
      // AI advisory fallback
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzingAI = false;
        });
      }
    }
  }

  Future<void> _submitIssue() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      setState(() {
        _errorMessage = 'Please provide both an issue title and description.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await apiClient.dio.post('/issues/', data: {
        'title': title,
        'description': description,
        'location_details': _locationController.text.trim(),
        'category_id': _selectedCategoryId,
        'building_id': _selectedBuildingId,
        'urgency': _urgency,
      });

      final refNumber = res.data['reference_number'] ?? 'CC-NEW';

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Issue Reported Successfully!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your complaint reference number is:'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  refNumber,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue),
                ),
              ),
              const SizedBox(height: 12),
              const Text('You will receive updates as technicians investigate this issue.'),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                context.go('/reporter/issues');
              },
              child: const Text('View My Issues'),
            ),
          ],
        ),
      );
    } on DioException catch (e) {
      setState(() {
        _errorMessage = e.response?.data?['detail'] ?? 'Failed to submit issue';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred';
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
      appBar: AppBar(title: const Text('Report Facilities Issue')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                  ),
                  const SizedBox(height: 16),
                ],
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Issue Title *',
                    hintText: 'e.g. AC unit leaking in Computer Lab 301',
                    border: OutlineInputBorder(),
                  ),
                  onEditingComplete: _analyzeWithAI,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Detailed Description *',
                    hintText: 'Describe what happened, error codes, noise, water dripping, etc.',
                    border: OutlineInputBorder(),
                  ),
                  onEditingComplete: _analyzeWithAI,
                ),
                const SizedBox(height: 16),
                if (_isAnalyzingAI)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                        SizedBox(width: 8),
                        Text('AI analyzing issue context...', style: TextStyle(fontSize: 12, color: Colors.indigo)),
                      ],
                    ),
                  )
                else if (_aiSuggestedUrgency != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.indigo.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.indigo.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.auto_awesome, size: 16, color: Colors.indigo),
                            const SizedBox(width: 6),
                            Text(
                              'AI Suggestion: ${_aiSuggestedUrgency!.toUpperCase()} URGENCY',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo, fontSize: 13),
                            ),
                          ],
                        ),
                        if (_aiRationale != null) ...[
                          const SizedBox(height: 4),
                          Text(_aiRationale!, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                        ],
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                if (_categories.isNotEmpty) ...[
                  DropdownButtonFormField<String>(
                    value: _selectedCategoryId,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items: _categories.map((cat) {
                      return DropdownMenuItem<String>(
                        value: cat['id'].toString(),
                        child: Text(cat['name']?.toString() ?? 'Category'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() => _selectedCategoryId = val);
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                if (_buildings.isNotEmpty) ...[
                  DropdownButtonFormField<String>(
                    value: _selectedBuildingId,
                    decoration: const InputDecoration(
                      labelText: 'Building / Facility',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.business_outlined),
                    ),
                    items: _buildings.map((b) {
                      return DropdownMenuItem<String>(
                        value: b['id'].toString(),
                        child: Text(b['name']?.toString() ?? 'Building'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() => _selectedBuildingId = val);
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                TextField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location Details',
                    hintText: 'e.g. 3rd Floor, Next to Room 302',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _urgency,
                  decoration: const InputDecoration(
                    labelText: 'Urgency Level',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.flag_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'low', child: Text('Low (Cosmetic / Non-blocking)')),
                    DropdownMenuItem(value: 'medium', child: Text('Medium (Normal Maintenance)')),
                    DropdownMenuItem(value: 'high', child: Text('High (Disrupting Class / Work)')),
                    DropdownMenuItem(value: 'critical', child: Text('Critical (Safety / Hazard)')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _urgency = val);
                  },
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitIssue,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Submit Facilities Report', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
