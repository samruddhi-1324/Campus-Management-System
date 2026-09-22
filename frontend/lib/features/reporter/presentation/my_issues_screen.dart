import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:campus_care/app/theme.dart';
import 'package:campus_care/core/network/api_client.dart';

class MyIssuesScreen extends StatefulWidget {
  const MyIssuesScreen({super.key});

  @override
  State<MyIssuesScreen> createState() => _MyIssuesScreenState();
}

class _MyIssuesScreenState extends State<MyIssuesScreen> {
  List<dynamic> _issues = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedStatusFilter = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchMyIssues();
  }

  Future<void> _fetchMyIssues() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await apiClient.dio.get('/issues/my');
      setState(() {
        _issues = response.data as List<dynamic>;
      });
    } on DioException catch (e) {
      setState(() {
        _errorMessage = e.response?.data?['detail'] ?? 'Failed to load issues';
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

  List<dynamic> get _filteredIssues {
    return _issues.where((issue) {
      final title = (issue['title'] as String? ?? '').toLowerCase();
      final location = (issue['location_name'] as String? ?? '').toLowerCase();
      final status = (issue['status'] as String? ?? '').toLowerCase();
      final matchesQuery = title.contains(_searchQuery.toLowerCase()) ||
          location.contains(_searchQuery.toLowerCase());

      if (!matchesQuery) return false;
      if (_selectedStatusFilter == 'active') {
        return status != 'resolved' && status != 'closed' && status != 'confirmed';
      }
      if (_selectedStatusFilter == 'in_progress') {
        return status == 'assigned' || status == 'investigating' || status == 'action_taken';
      }
      if (_selectedStatusFilter == 'resolved') {
        return status == 'resolved' || status == 'closed' || status == 'confirmed';
      }
      return true;
    }).toList();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'reported':
        return AppTheme.secondaryCobalt;
      case 'assigned':
      case 'understood':
      case 'investigating':
      case 'action_taken':
        return AppTheme.statusHigh;
      case 'resolved':
      case 'confirmed':
      case 'closed':
        return AppTheme.statusLow;
      case 'reopened':
      case 'escalated':
        return AppTheme.statusUrgent;
      default:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = _issues.where((i) {
      final s = (i['status'] as String? ?? '').toLowerCase();
      return s != 'resolved' && s != 'closed' && s != 'confirmed';
    }).length;

    final inProgressCount = _issues.where((i) {
      final s = (i['status'] as String? ?? '').toLowerCase();
      return s == 'assigned' || s == 'investigating' || s == 'action_taken';
    }).length;

    final resolvedCount = _issues.where((i) {
      final s = (i['status'] as String? ?? '').toLowerCase();
      return s == 'resolved' || s == 'closed' || s == 'confirmed';
    }).length;

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
              child: const Icon(Icons.confirmation_number_outlined, color: Colors.white, size: 20),
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
                  'REPORTER DASHBOARD',
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
            icon: const Icon(Icons.search, size: 22),
            onPressed: () => context.push('/search'),
            tooltip: 'Semantic AI Search',
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, size: 22),
            onPressed: () => context.push('/notifications'),
            tooltip: 'Notification Center',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, size: 22),
            onPressed: _fetchMyIssues,
            tooltip: 'Refresh Tickets',
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/issues/report'),
        backgroundColor: AppTheme.primaryIndigo,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_circle_outline, color: AppTheme.tertiaryMint),
        label: Text(
          'Report Issue',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w700),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchMyIssues,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderKpis(activeCount, inProgressCount, resolvedCount),
                const SizedBox(height: 24),
                _buildFilterBar(),
                const SizedBox(height: 20),
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(48.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_errorMessage != null)
                  _buildErrorState()
                else if (_filteredIssues.isEmpty)
                  _buildEmptyState()
                else
                  _buildIssuesList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderKpis(int active, int inProgress, int resolved) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'CAMPUS OPERATIONS SERVICE DESK',
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.outlineVariant,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Active Dispatch Grid',
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.secondaryCobalt,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Institutional Grievance & Work Orders',
                  style: GoogleFonts.newsreader(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryIndigo,
                  ),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () => context.push('/issues/report'),
              icon: const Icon(Icons.mic, color: AppTheme.tertiaryMint, size: 18),
              label: const Text('Voice / AI Report'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryIndigo,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildKpiPill('Active', '$active', AppTheme.primaryContainer, Colors.white, Icons.layers_outlined),
              const SizedBox(width: 8),
              _buildKpiPill('In Progress', '$inProgress', AppTheme.surfaceContainerHigh, AppTheme.secondaryCobalt, Icons.sync),
              const SizedBox(width: 8),
              _buildKpiPill('Resolved', '$resolved', const Color(0xFFE8F8F0), AppTheme.statusLow, Icons.check_circle_outline),
              const SizedBox(width: 8),
              _buildKpiPill('Avg Resolution', '3.8 hrs', AppTheme.surfaceWhite, AppTheme.primaryIndigo, Icons.speed),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKpiPill(String label, String count, Color bgColor, Color textColor, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.manrope(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: textColor.withOpacity(0.85),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            count,
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Column(
        children: [
          TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: 'Search ticket reference, location, or equipment...',
              prefixIcon: const Icon(Icons.search, color: AppTheme.outline),
              filled: true,
              fillColor: AppTheme.surfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatusChip('all', 'All Tickets (${_issues.length})'),
                const SizedBox(width: 8),
                _buildStatusChip('active', 'Active'),
                const SizedBox(width: 8),
                _buildStatusChip('in_progress', 'In Progress'),
                const SizedBox(width: 8),
                _buildStatusChip('resolved', 'Resolved'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String key, String label) {
    final isSelected = _selectedStatusFilter == key;
    return ChoiceChip(
      label: Text(
        label,
        style: GoogleFonts.manrope(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? Colors.white : AppTheme.textPrimary,
        ),
      ),
      selected: isSelected,
      selectedColor: AppTheme.primaryIndigo,
      backgroundColor: AppTheme.surfaceContainerLow,
      side: BorderSide(
        color: isSelected ? AppTheme.primaryIndigo : AppTheme.outlineVariant,
      ),
      onSelected: (_) => setState(() => _selectedStatusFilter = key),
    );
  }

  Widget _buildIssuesList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredIssues.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final issue = _filteredIssues[index];
        final id = issue['id'] as String? ?? '';
        final title = issue['title'] as String? ?? 'Untitled Issue';
        final desc = issue['description'] as String? ?? '';
        final status = issue['status'] as String? ?? 'reported';
        final urgency = issue['urgency'] as String? ?? 'medium';
        final location = issue['location_name'] as String? ?? 'Campus Quad';
        final category = issue['category_name'] as String? ?? 'Facilities';
        final ticketRef = id.length > 8 ? 'TICK-${id.substring(0, 8).toUpperCase()}' : 'TICK-$id';

        return InkWell(
          onTap: () => context.push('/issues/$id'),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.surfaceWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.outlineVariant),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppTheme.outlineVariant),
                          ),
                          child: Text(
                            ticketRef,
                            style: GoogleFonts.manrope(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryContainer.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            category,
                            style: GoogleFonts.manrope(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryIndigo,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _getStatusColor(status),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (desc.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 16, color: AppTheme.outline),
                        const SizedBox(width: 4),
                        Text(
                          location,
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Icon(Icons.priority_high, size: 16, color: AppTheme.statusHigh),
                        Text(
                          urgency.toUpperCase(),
                          style: GoogleFonts.manrope(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.statusHigh,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'Track Resolution',
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.secondaryCobalt,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward, size: 14, color: AppTheme.secondaryCobalt),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppTheme.surfaceContainerLow,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.task_alt, size: 48, color: AppTheme.outline),
            ),
            const SizedBox(height: 16),
            Text(
              'No Reported Complaints Found',
              style: GoogleFonts.newsreader(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryIndigo,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Have an issue on campus? Submit a report with voice or photos.',
              style: GoogleFonts.manrope(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () => context.push('/issues/report'),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Report New Issue'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppTheme.statusUrgent),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'An error occurred',
              style: GoogleFonts.manrope(color: AppTheme.statusUrgent, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchMyIssues,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

