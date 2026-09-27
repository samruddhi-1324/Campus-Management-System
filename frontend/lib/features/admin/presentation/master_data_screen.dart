import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:campus_care/app/theme.dart';

class MasterDataScreen extends StatefulWidget {
  const MasterDataScreen({super.key});

  @override
  State<MasterDataScreen> createState() => _MasterDataScreenState();
}

class _MasterDataScreenState extends State<MasterDataScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  final List<Map<String, dynamic>> _buildings = [
    {
      'name': 'Packard Electrical Engineering',
      'code': 'BLDG-ENG-01',
      'wings': 3,
      'floors': 4,
      'rooms': 42,
      'active_issues': 5,
      'status': 'Optimal',
    },
    {
      'name': 'Gates Computer Science Building',
      'code': 'BLDG-CS-02',
      'wings': 2,
      'floors': 5,
      'rooms': 58,
      'active_issues': 2,
      'status': 'Optimal',
    },
    {
      'name': 'Cecil H. Green Library',
      'code': 'BLDG-LIB-01',
      'wings': 4,
      'floors': 6,
      'rooms': 110,
      'active_issues': 8,
      'status': 'Attention',
    },
    {
      'name': 'Science & Bio-Safety Facility',
      'code': 'BLDG-BIO-03',
      'wings': 2,
      'floors': 3,
      'rooms': 28,
      'active_issues': 1,
      'status': 'Optimal',
    },
    {
      'name': 'Tressider Student Union',
      'code': 'BLDG-STU-01',
      'wings': 2,
      'floors': 2,
      'rooms': 35,
      'active_issues': 4,
      'status': 'Optimal',
    },
  ];

  final List<Map<String, dynamic>> _departments = [
    {
      'name': 'HVAC & Climate Infrastructure',
      'head': 'Eng. Robert Chen',
      'technicians': 8,
      'avg_sla': '3.2 hrs',
      'icon': Icons.air,
      'color': AppTheme.secondaryCobalt,
    },
    {
      'name': 'Electrical & Power Systems',
      'head': 'Eng. Priya Sharma',
      'technicians': 12,
      'avg_sla': '2.4 hrs',
      'icon': Icons.lightbulb_outline,
      'color': AppTheme.statusHigh,
    },
    {
      'name': 'Plumbing & Hydraulic Networks',
      'head': 'Supervisor Dave Miller',
      'technicians': 6,
      'avg_sla': '4.1 hrs',
      'icon': Icons.water_drop_outlined,
      'color': AppTheme.secondaryContainer,
    },
    {
      'name': 'Campus IT & Wi-Fi Telemetry',
      'head': 'Tech Lead Alex Mercer',
      'technicians': 10,
      'avg_sla': '1.8 hrs',
      'icon': Icons.wifi_tethering,
      'color': AppTheme.tertiaryDim,
    },
    {
      'name': 'Facilities & Structural Carpentry',
      'head': 'Supervisor Manuel Ortiz',
      'technicians': 5,
      'avg_sla': '5.6 hrs',
      'icon': Icons.handyman_outlined,
      'color': AppTheme.statusMedium,
    },
  ];

  final List<Map<String, dynamic>> _slaPolicies = [
    {
      'level': 'P1 Critical',
      'desc': 'Classroom/Lab immediate disruption or hazard',
      'target': '4 Hours',
      'escalation': 'Alert Ops Head after 2.5h',
      'color': AppTheme.statusUrgent,
    },
    {
      'level': 'P2 High',
      'desc': 'Major equipment failure impacting multiple users',
      'target': '12 Hours',
      'escalation': 'Alert Maintenance Head after 8h',
      'color': AppTheme.statusHigh,
    },
    {
      'level': 'P3 Medium',
      'desc': 'Standard maintenance or non-urgent repair',
      'target': '24 Hours',
      'escalation': 'Daily Digest Notification',
      'color': AppTheme.statusMedium,
    },
    {
      'level': 'P4 Low',
      'desc': 'Cosmetic or scheduled long-term maintenance',
      'target': '48 Hours',
      'escalation': 'Weekly Review',
      'color': AppTheme.statusLow,
    },
  ];

  final List<Map<String, dynamic>> _users = [
    {'name': 'Samruddhi Admin', 'email': 'samruddhi@campuscare.edu', 'role': 'System Administrator', 'badge': 'Superuser'},
    {'name': 'Alex Mercer', 'email': 'admin@campuscare.edu', 'role': 'System Administrator', 'badge': 'Admin'},
    {'name': 'Sarah Lin', 'email': 'student@campuscare.edu', 'role': 'Student / Reporter', 'badge': 'Reporter'},
    {'name': 'Elena Rostova', 'email': 'coordinator@campuscare.edu', 'role': 'Triage Coordinator', 'badge': 'Staff'},
    {'name': 'Marcus Vance', 'email': 'supervisor@campuscare.edu', 'role': 'Maintenance Supervisor', 'badge': 'Staff'},
    {'name': 'Dr. Alistair Finch', 'email': 'academic@campuscare.edu', 'role': 'Academic Officer', 'badge': 'Ombudsperson'},
    {'name': 'Dr. Victoria Chase', 'email': 'opshead@campuscare.edu', 'role': 'Operations Head', 'badge': 'Executive'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryIndigo,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Master Data & Institutional Admin',
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              'Apex University of Tech • Partition #TENANT-0941',
              style: GoogleFonts.manrope(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFC4C1FB),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.domain, color: Colors.white),
            tooltip: 'Workspace Switcher',
            onPressed: () => context.go('/tenant/select'),
          ),
          IconButton(
            icon: const Icon(Icons.analytics_outlined, color: Colors.white),
            tooltip: 'Operations Analytics',
            onPressed: () => context.go('/ops/analytics'),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Sign Out',
            onPressed: () => context.go('/login'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.tertiaryMint,
          indicatorWeight: 3,
          labelColor: AppTheme.tertiaryMint,
          unselectedLabelColor: const Color(0xFFC4C1FB),
          labelStyle: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w700),
          tabs: const [
            Tab(icon: Icon(Icons.apartment, size: 18), text: 'Topology'),
            Tab(icon: Icon(Icons.handyman, size: 18), text: 'Departments'),
            Tab(icon: Icon(Icons.timer_outlined, size: 18), text: 'SLA Matrix'),
            Tab(icon: Icon(Icons.people_outline, size: 18), text: 'RBAC Users'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTopologyTab(),
          _buildDepartmentsTab(),
          _buildSlaTab(),
          _buildUsersTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.secondaryCobalt,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(
          _tabController.index == 0
              ? 'Add Building'
              : _tabController.index == 1
                  ? 'Add Department'
                  : _tabController.index == 2
                      ? 'Add Policy'
                      : 'Invite User',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w700),
        ),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Configuration dialog opened for tab ${_tabController.index + 1}'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppTheme.primaryIndigo,
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopologyTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Search & Filter
        TextField(
          decoration: InputDecoration(
            hintText: 'Search campus buildings, wings, or rooms...',
            prefixIcon: const Icon(Icons.search, color: AppTheme.outline),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.neutralLightOutline),
            ),
          ),
          onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
        ),
        const SizedBox(height: 16),

        // Quick Stats Strip
        Row(
          children: [
            Expanded(
              child: _buildMetricCard('Total Buildings', '5', Icons.apartment, AppTheme.primaryIndigo),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard('Monitored Rooms', '273', Icons.meeting_room_outlined, AppTheme.secondaryCobalt),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard('Active Incidents', '20', Icons.warning_amber_rounded, AppTheme.statusHigh),
            ),
          ],
        ),
        const SizedBox(height: 20),

        Text(
          'Campus Buildings & Spaces',
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 12),

        ..._buildings
            .where((b) => b['name'].toString().toLowerCase().contains(_searchQuery))
            .map((building) {
          final isOptimal = building['status'] == 'Optimal';
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.neutralLightOutline.withOpacity(0.5)),
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
                    Expanded(
                      child: Text(
                        building['name'],
                        style: GoogleFonts.manrope(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryIndigo,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isOptimal ? AppTheme.tertiaryMint.withOpacity(0.2) : AppTheme.statusHigh.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        building['status'],
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isOptimal ? const Color(0xFF005137) : AppTheme.statusHigh,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Identifier: ${building['code']}',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildBuildingMeta(Icons.domain, '${building['wings']} Wings'),
                    _buildBuildingMeta(Icons.layers_outlined, '${building['floors']} Floors'),
                    _buildBuildingMeta(Icons.meeting_room_outlined, '${building['rooms']} Rooms'),
                    _buildBuildingMeta(Icons.bolt, '${building['active_issues']} Issues', isIssue: true),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildDepartmentsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Operational Maintenance Departments',
          style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 12),
        ..._departments.map((dept) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.neutralLightOutline.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: (dept['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(dept['icon'] as IconData, color: dept['color'] as Color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dept['name'],
                        style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.primaryIndigo),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Head: ${dept['head']} • ${dept['technicians']} Techs',
                        style: GoogleFonts.manrope(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      dept['avg_sla'],
                      style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.secondaryCobalt),
                    ),
                    Text(
                      'Avg SLA',
                      style: GoogleFonts.manrope(fontSize: 10, color: AppTheme.outline),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildSlaTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Automated Resolution SLA Policies',
          style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 12),
        ..._slaPolicies.map((policy) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: (policy['color'] as Color).withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      policy['level'],
                      style: GoogleFonts.manrope(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: policy['color'] as Color,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: (policy['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Target: ${policy['target']}',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: policy['color'] as Color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  policy['desc'],
                  style: GoogleFonts.manrope(fontSize: 12, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.bolt, size: 14, color: AppTheme.outline),
                    const SizedBox(width: 4),
                    Text(
                      policy['escalation'],
                      style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildUsersTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Role-Based Access Control (RBAC)',
          style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 12),
        ..._users.map((u) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.neutralLightOutline.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryIndigo,
                  child: Text(
                    u['name']![0],
                    style: GoogleFonts.manrope(fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        u['name']!,
                        style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primaryIndigo),
                      ),
                      Text(
                        u['email']!,
                        style: GoogleFonts.manrope(fontSize: 11, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.outlineVariant),
                  ),
                  child: Text(
                    u['badge']!,
                    style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primaryIndigo),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.neutralLightOutline.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.primaryIndigo),
          ),
          Text(
            title,
            style: GoogleFonts.manrope(fontSize: 10, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildBuildingMeta(IconData icon, String label, {bool isIssue = false}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: isIssue ? AppTheme.statusHigh : AppTheme.outline),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 11,
            fontWeight: isIssue ? FontWeight.w700 : FontWeight.w500,
            color: isIssue ? AppTheme.statusHigh : AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

