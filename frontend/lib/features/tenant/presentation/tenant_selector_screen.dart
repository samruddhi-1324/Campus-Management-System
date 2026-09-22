import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:campus_care/app/theme.dart';

class TenantSelectorScreen extends StatefulWidget {
  const TenantSelectorScreen({super.key});

  @override
  State<TenantSelectorScreen> createState() => _TenantSelectorScreenState();
}

class _TenantSelectorScreenState extends State<TenantSelectorScreen> {
  String _selectedTenantId = 'inst-1';
  String _searchQuery = '';
  String _activeFilter = 'all';

  final List<Map<String, dynamic>> _institutions = [
    {
      'id': 'inst-1',
      'name': 'Apex University of Technology',
      'slug': 'apex-tech',
      'domain': 'apex.edu',
      'partition': 'TENANT-0941',
      'active_issues': 28,
      'sla_compliance': '99.4%',
      'region': 'Main Quad / Central',
      'badge': 'A',
      'color': const Color(0xFF070235),
      'is_verified': true,
      'is_enrolled': true,
    },
    {
      'id': 'inst-2',
      'name': 'Metropolitan Medical & Health College',
      'slug': 'metro-health',
      'domain': 'metrohealth.edu',
      'partition': 'TENANT-1082',
      'active_issues': 14,
      'sla_compliance': '98.8%',
      'region': 'North Medical Wing',
      'badge': 'M',
      'color': const Color(0xFF0051D5),
      'is_verified': true,
      'is_enrolled': true,
    },
    {
      'id': 'inst-3',
      'name': 'St. Jude Institute of Management',
      'slug': 'st-jude',
      'domain': 'stjude.edu',
      'partition': 'TENANT-2419',
      'active_issues': 7,
      'sla_compliance': '100%',
      'region': 'Downtown Campus',
      'badge': 'S',
      'color': const Color(0xFF002819),
      'is_verified': true,
      'is_enrolled': false,
    },
    {
      'id': 'inst-4',
      'name': 'Pacific Coast Engineering Academy',
      'slug': 'pacific-eng',
      'domain': 'pacific-eng.edu',
      'partition': 'TENANT-3310',
      'active_issues': 35,
      'sla_compliance': '97.2%',
      'region': 'Ocean Tech Park',
      'badge': 'P',
      'color': const Color(0xFF1E1B4B),
      'is_verified': true,
      'is_enrolled': false,
    },
  ];

  List<Map<String, dynamic>> get _filteredInstitutions {
    return _institutions.where((inst) {
      final name = (inst['name'] as String).toLowerCase();
      final domain = (inst['domain'] as String).toLowerCase();
      final query = _searchQuery.toLowerCase();
      final matchesSearch = name.contains(query) || domain.contains(query);

      if (!matchesSearch) return false;

      if (_activeFilter == 'verified') return inst['is_verified'] == true;
      if (_activeFilter == 'incidents') return (inst['active_issues'] as int) > 10;
      if (_activeFilter == 'enrolled') return inst['is_enrolled'] == true;
      return true;
    }).toList();
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
              child: const Icon(Icons.corporate_fare, color: Colors.white, size: 20),
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
                  'HIGHER-ED ENTERPRISE',
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
            onPressed: () => context.go('/auth/login'),
            icon: const Icon(Icons.logout, size: 20),
            tooltip: 'Sign Out',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroHeader(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchAndFilters(context),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Provisioned Campus Environments',
                              style: GoogleFonts.newsreader(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryIndigo,
                              ),
                            ),
                            Text(
                              'Isolated cryptographic schema spaces with continuous automated SLA dispatch routines.',
                              style: GoogleFonts.manrope(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainerLow,
                            borderRadius: const BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.outlineVariant),
                          ),
                          child: Text(
                            '${_filteredInstitutions.length} Active Partitions',
                            style: GoogleFonts.manrope(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryIndigo,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildInstitutionsGrid(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppTheme.primaryIndigo,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 840;
              return isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(child: _buildHeroText()),
                        const SizedBox(width: 32),
                        _buildCurrentSessionBadge(),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeroText(),
                        const SizedBox(height: 24),
                        _buildCurrentSessionBadge(),
                      ],
                    );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeroText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: const BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.tertiaryMint,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'FEDERATED IDENTITY PARTITIONING',
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: AppTheme.tertiaryMint,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'ISO/IEC 27001 Certified',
              style: GoogleFonts.manrope(
                fontSize: 11,
                color: const Color(0xFF8683BA),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'Institutional Workspace Switcher',
          style: GoogleFonts.newsreader(
            fontSize: 32,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select an authenticated collegiate domain to manage facilities, SLA resolution, and automated AI triage telemetry across distributed campuses.',
          style: GoogleFonts.manrope(
            fontSize: 14,
            color: const Color(0xFFC8C5D0),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentSessionBadge() {
    final current = _institutions.firstWhere((i) => i['id'] == _selectedTenantId);
    return Container(
      width: 320,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: const BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ACTIVE WORKSPACE',
                style: GoogleFonts.manrope(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: const Color(0xFF8683BA),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.tertiaryMint,
                  borderRadius: const BorderRadius.circular(12),
                ),
                child: Text(
                  'Verified Node',
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryIndigo,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                radius: 18,
                child: Text(
                  current['badge'] as String,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryIndigo,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      current['name'] as String,
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${current['domain']} • ${current['partition']}',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        color: const Color(0xFFC8C5D0),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 20, color: Colors.white12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RLS Protected Partition',
                style: GoogleFonts.manrope(fontSize: 11, color: const Color(0xFF8683BA)),
              ),
              Text(
                'Latency: 14ms',
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.tertiaryMint,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: const BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Column(
        children: [
          TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: 'Filter institutional domains by name, state code, or partition key...',
              prefixIcon: const Icon(Icons.search, color: AppTheme.outline),
              filled: true,
              fillColor: AppTheme.surfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius: const BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('all', 'All Campuses'),
                const SizedBox(width: 8),
                _buildFilterChip('verified', 'Verified Domains'),
                const SizedBox(width: 8),
                _buildFilterChip('incidents', 'Active Incidents'),
                const SizedBox(width: 8),
                _buildFilterChip('enrolled', 'My Enrolled'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _activeFilter == key;
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
      onSelected: (_) => setState(() => _activeFilter = key),
    );
  }

  Widget _buildInstitutionsGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 900 ? 2 : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _filteredInstitutions.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 200,
          ),
          itemBuilder: (context, index) {
            final inst = _filteredInstitutions[index];
            final isSelected = inst['id'] == _selectedTenantId;

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surfaceWhite,
                borderRadius: const BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppTheme.secondaryCobalt : AppTheme.outlineVariant,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: (inst['color'] as Color).withOpacity(0.12),
                        radius: 22,
                        child: Text(
                          inst['badge'] as String,
                          style: GoogleFonts.manrope(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: inst['color'] as Color,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              inst['name'] as String,
                              style: GoogleFonts.manrope(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${inst['domain']} • ${inst['region']}',
                              style: GoogleFonts.manrope(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryCobalt.withOpacity(0.1),
                            borderRadius: const BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check, size: 14, color: AppTheme.secondaryCobalt),
                              const SizedBox(width: 4),
                              Text(
                                'Current',
                                style: GoogleFonts.manrope(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.secondaryCobalt,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMetricPill(
                        'Active Issues',
                        '${inst['active_issues']}',
                        (inst['active_issues'] as int) > 20 ? AppTheme.statusHigh : AppTheme.secondaryCobalt,
                      ),
                      _buildMetricPill(
                        'SLA Health',
                        inst['sla_compliance'] as String,
                        AppTheme.statusLow,
                      ),
                      _buildMetricPill(
                        'Partition',
                        inst['partition'] as String,
                        AppTheme.textSecondary,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Encrypted Domain Node',
                        style: GoogleFonts.manrope(fontSize: 11, color: AppTheme.outline),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() => _selectedTenantId = inst['id'] as String);
                          context.go('/reporter/issues');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSelected ? AppTheme.primaryIndigo : AppTheme.surfaceContainerLow,
                          foregroundColor: isSelected ? Colors.white : AppTheme.textPrimary,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          minimumSize: const Size(0, 36),
                        ),
                        child: Text(
                          isSelected ? 'Enter Workspace' : 'Switch & Open',
                          style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMetricPill(String label, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: const BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.manrope(fontSize: 10, color: AppTheme.textSecondary),
          ),
          Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

