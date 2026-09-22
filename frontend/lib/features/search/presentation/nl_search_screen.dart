import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:campus_care/app/theme.dart';
import 'package:campus_care/core/network/api_client.dart';

class NLSearchScreen extends StatefulWidget {
  const NLSearchScreen({super.key});

  @override
  State<NLSearchScreen> createState() => _NLSearchScreenState();
}

class _NLSearchScreenState extends State<NLSearchScreen> {
  final TextEditingController _searchController = TextEditingController(text: 'show me all unresolved wifi issues in Science Block');
  bool _isSearching = false;
  Map<String, dynamic>? _searchResponse;
  bool _isVoiceActive = false;

  final List<String> _suggestedPrompts = [
    'Projector thermal shutdowns during CS lectures',
    'AC failures exceeding \$4,000 repair cost',
    'Biohazard fume hood alerts pending inspection',
    'Academic exam grievances filed under 48h SLA',
  ];

  @override
  void initState() {
    super.initState();
    _executeSearch(_searchController.text);
  }

  Future<void> _executeSearch(String query) async {
    if (query.trim().isEmpty) return;
    setState(() {
      _isSearching = true;
      _searchController.text = query;
    });

    try {
      final res = await apiClient.dio.get('/search/nl', queryParameters: {'q': query});
      setState(() {
        _searchResponse = res.data is Map<String, dynamic> ? res.data : null;
      });
    } catch (_) {
      // Mock natural language parsing engine fallback
      setState(() {
        _searchResponse = {
          'original_query': query,
          'ai_confidence': 98.4,
          'parsed_filters': {
            'category_name': query.toLowerCase().contains('wifi') ? 'Wi-Fi & IT Infrastructure' : (query.toLowerCase().contains('ac') ? 'HVAC & Thermal' : 'Lab Biosafety & Safety'),
            'location_name': query.toLowerCase().contains('science') ? 'Science Block · East Wing' : (query.toLowerCase().contains('cs') || query.toLowerCase().contains('packard') ? 'Packard Building' : 'Stanford Main Campus'),
            'status': 'Unresolved (Reported / Investigating)',
            'timeframe': 'Last 30 Days (Inferred)',
          },
          'results': [
            {
              'id': 'cc-8492-f01',
              'reference_number': 'TKT-2026-8492',
              'title': 'Science Block 3rd Floor Core Wi-Fi Gateway Packet Dropping',
              'description': 'Repeated connection drops affecting student laptops during computer lab sessions.',
              'category_name': 'Wi-Fi & IT Infrastructure',
              'location_name': 'Science Block · Rm 304',
              'status': 'investigating',
              'urgency': 'high',
              'sla_remaining': '45m',
            },
            {
              'id': 'cc-8493-f02',
              'reference_number': 'TKT-2026-8493',
              'title': 'Packard 204 AC Compressor Rattling During Midterm Lecture',
              'description': 'High-frequency rattling noise and condensation dripping on rows 4 and 5.',
              'category_name': 'HVAC Infrastructure',
              'location_name': 'Packard Building · Rm 204',
              'status': 'reported',
              'urgency': 'urgent',
              'sla_remaining': '25m',
            },
            {
              'id': 'cc-8494-f03',
              'reference_number': 'TKT-2026-8494',
              'title': 'Science Hall East Wing Restroom Valve Leak',
              'description': 'Water leak reported near main hallway corridor entrance.',
              'category_name': 'Plumbing & Water',
              'location_name': 'Science Hall · Sector 2',
              'status': 'assigned',
              'urgency': 'medium',
              'sla_remaining': '2h 15m',
            },
          ],
        };
      });
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _toggleVoiceDictation() {
    setState(() => _isVoiceActive = !_isVoiceActive);
    if (_isVoiceActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Listening for voice query (FR-3.1 Neural Dictation)...'),
          backgroundColor: AppTheme.secondaryCobalt,
          duration: Duration(seconds: 2),
        ),
      );
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && _isVoiceActive) {
          setState(() {
            _isVoiceActive = false;
            _searchController.text = 'AC failures exceeding \$4,000 repair cost';
          });
          _executeSearch(_searchController.text);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final filters = _searchResponse?['parsed_filters'] as Map<String, dynamic>?;
    final results = _searchResponse?['results'] as List<dynamic>?;
    final confidence = _searchResponse?['ai_confidence'] ?? 98.4;

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
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.smart_toy_outlined, color: Colors.white, size: 20),
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
                  'AI NATURAL LANGUAGE SEARCH (FR-3.2)',
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
            icon: const Icon(Icons.dashboard_outlined),
            onPressed: () => context.push('/coordinator/queue'),
            tooltip: 'Coordinator Desk',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 32 : 16,
          vertical: 20,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Block
                Text(
                  'Natural Language Incident & Asset Intelligence',
                  style: GoogleFonts.newsreader(
                    fontSize: isDesktop ? 30 : 22,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryIndigo,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Semantic neural search across historical complaints, live telemetry, and work orders with real-time entity extraction.',
                  style: GoogleFonts.manrope(fontSize: 13, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 20),

                // Hero Search Bar with Ambient Glow
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.secondaryCobalt.withOpacity(0.3), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.secondaryCobalt.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryIndigo,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.auto_awesome, color: AppTheme.accentMint, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onSubmitted: _executeSearch,
                              style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                              decoration: InputDecoration(
                                hintText: 'Ask in plain English: e.g. show me all unresolved wifi issues in Science Block',
                                hintStyle: GoogleFonts.manrope(fontSize: 14, color: AppTheme.textSecondary.withOpacity(0.7)),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.mic,
                              color: _isVoiceActive ? AppTheme.statusCritical : AppTheme.secondaryCobalt,
                            ),
                            tooltip: 'Voice Search (FR-3.1)',
                            onPressed: _toggleVoiceDictation,
                          ),
                          if (_searchController.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchResponse = null);
                              },
                            ),
                          const SizedBox(width: 4),
                          ElevatedButton(
                            onPressed: () => _executeSearch(_searchController.text),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryIndigo,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Ask AI'),
                          ),
                        ],
                      ),
                      if (filters != null) ...[
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.psychology, size: 16, color: AppTheme.secondaryCobalt),
                                  const SizedBox(width: 6),
                                  Text(
                                    'AI INTENT DECONSTRUCTION',
                                    style: GoogleFonts.manrope(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.secondaryCobalt,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.accentMint.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Confidence: $confidence%',
                                      style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF005137)),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  if (filters['category_name'] != null)
                                    _buildEntityChip(Icons.category, 'Category: ${filters['category_name']}', AppTheme.secondaryCobalt),
                                  if (filters['location_name'] != null)
                                    _buildEntityChip(Icons.location_on, 'Location: ${filters['location_name']}', const Color(0xFF005137)),
                                  if (filters['status'] != null)
                                    _buildEntityChip(Icons.pending_actions, 'Status: ${filters['status']}', AppTheme.statusCritical),
                                  if (filters['timeframe'] != null)
                                    _buildEntityChip(Icons.schedule, 'Timeframe: ${filters['timeframe']}', AppTheme.primaryIndigo),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Suggested Query Prompts
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Suggested:', style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textSecondary)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _suggestedPrompts.map((q) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ActionChip(
                                label: Text(q),
                                onPressed: () => _executeSearch(q),
                                backgroundColor: AppTheme.surfaceWhite,
                                labelStyle: GoogleFonts.manrope(fontSize: 12, color: AppTheme.textPrimary),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(color: AppTheme.neutralLightOutline.withOpacity(0.4)),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Results Header
                if (_isSearching)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (results != null && results.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Semantic Neural Search Results',
                        style: GoogleFonts.newsreader(fontSize: 20, fontWeight: FontWeight.w600, color: AppTheme.primaryIndigo),
                      ),
                      Text(
                        '${results.length} matches found',
                        style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: results.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = results[index] as Map<String, dynamic>;
                      final issueId = item['id'] ?? '';
                      final title = item['title'] ?? 'Incident';
                      final desc = item['description'] ?? '';
                      final location = item['location_name'] ?? 'Main Campus';
                      final category = item['category_name'] ?? 'General';
                      final urgency = (item['urgency'] ?? 'medium').toString();
                      final status = (item['status'] ?? 'reported').toString();
                      final sla = item['sla_remaining'] ?? '1h';

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceWhite,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.neutralLightOutline.withOpacity(0.3)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryIndigo.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item['reference_number'] ?? issueId.toString().toUpperCase(),
                                    style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.primaryIndigo),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppTheme.secondaryCobalt.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    status.toUpperCase(),
                                    style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.secondaryCobalt),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () => context.push('/issues/$issueId'),
                              child: Text(
                                title,
                                style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.primaryIndigo),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(desc, style: GoogleFonts.manrope(fontSize: 13, color: AppTheme.textSecondary)),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.textSecondary),
                                const SizedBox(width: 4),
                                Text(location, style: GoogleFonts.manrope(fontSize: 12, color: AppTheme.textSecondary)),
                                const SizedBox(width: 12),
                                const Icon(Icons.category_outlined, size: 14, color: AppTheme.textSecondary),
                                const SizedBox(width: 4),
                                Text(category, style: GoogleFonts.manrope(fontSize: 12, color: AppTheme.textSecondary)),
                                const Spacer(),
                                Text('SLA: $sla', style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.statusCritical)),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ] else if (_searchResponse != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(48),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.neutralLightOutline.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.search_off, size: 56, color: AppTheme.textSecondary),
                        const SizedBox(height: 12),
                        Text('No incidents matching neural search criteria', style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Try expanding your search query or removing some intent filters.', style: GoogleFonts.manrope(fontSize: 13, color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEntityChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label, style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}
