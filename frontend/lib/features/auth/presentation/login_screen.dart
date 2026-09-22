import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:campus_care/app/theme.dart';
import 'package:campus_care/core/network/api_client.dart';
import 'package:campus_care/core/storage/secure_storage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'admin@campuscare.edu');
  final _passwordController = TextEditingController(text: 'Admin@123456');
  final _nameController = TextEditingController();

  bool _isRegistering = false;
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedRolePreset = 'admin';

  final List<Map<String, String>> _rolePresets = [
    {'role': 'reporter', 'label': 'Student / Reporter', 'email': 'student@campuscare.edu'},
    {'role': 'coordinator', 'label': 'Triage Coordinator', 'email': 'coordinator@campuscare.edu'},
    {'role': 'supervisor', 'label': 'Maintenance Supervisor', 'email': 'supervisor@campuscare.edu'},
    {'role': 'academic_officer', 'label': 'Academic Officer', 'email': 'academic@campuscare.edu'},
    {'role': 'ops_head', 'label': 'Operations Head', 'email': 'opshead@campuscare.edu'},
    {'role': 'admin', 'label': 'System Admin', 'email': 'admin@campuscare.edu'},
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _applyRolePreset(String roleKey, String email) {
    setState(() {
      _selectedRolePreset = roleKey;
      _emailController.text = email;
      _passwordController.text = 'Admin@123456';
    });
  }

  Future<void> _handleAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty || (_isRegistering && name.isEmpty)) {
      setState(() {
        _errorMessage = 'Please complete all required fields.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isRegistering) {
        await apiClient.dio.post('/auth/register', data: {
          'email': email,
          'password': password,
          'full_name': name,
          'role': 'reporter',
        });
      }

      final response = await apiClient.dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final accessToken = response.data['access_token'] as String;
      final role = response.data['role'] as String;

      await secureStorageService.saveToken(accessToken);

      if (!mounted) return;

      if (role == 'coordinator' || role == 'supervisor') {
        context.go('/coordinator/queue');
      } else if (role == 'academic_officer') {
        context.go('/academic/triage');
      } else if (role == 'ops_head') {
        context.go('/ops/analytics');
      } else if (role == 'admin') {
        context.go('/admin/master-data');
      } else {
        context.go('/reporter/issues');
      }
    } on DioException catch (e) {
      setState(() {
        _errorMessage = e.response?.data?['detail'] ?? 'Authentication failed. Please check credentials.';
      });
    } catch (e) {
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
      backgroundColor: AppTheme.backgroundLight,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 960;
          return Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 32 : 16,
                vertical: isDesktop ? 40 : 20,
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: isDesktop ? 1160 : 540,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryIndigo.withOpacity(0.08),
                      blurRadius: 32,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(flex: 6, child: _buildLeftHeroPanel(context)),
                          Expanded(flex: 6, child: _buildRightAuthCard(context, isDesktop)),
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildMobileHeader(context),
                          _buildRightAuthCard(context, false),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLeftHeroPanel(BuildContext context) {
    return Container(
      color: AppTheme.primaryIndigo,
      padding: const EdgeInsets.all(40),
      child: Stack(
        children: [
          // Background ambient gradient orbs
          Positioned(
            top: -60,
            left: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.secondaryCobalt.withOpacity(0.35),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            right: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.tertiaryMint.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.secondaryContainer.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_awesome, color: Color(0xFFDBE1FF), size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'CAMPUS CARE v3.0',
                          style: GoogleFonts.manrope(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: const Color(0xFFDBE1FF),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.tertiaryMint,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Mesh Grid Online',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          color: const Color(0xFF8683BA),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Title & Subtitle
              Text(
                'Intelligent Campus Facilities & Operational Resolution',
                style: GoogleFonts.newsreader(
                  fontSize: 34,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Connecting students, coordinators, and leadership with real-time AI triage, proactive maintenance, and transparent issue lifecycles.',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  color: const Color(0xFFC8C5D0),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),

              // Blueprint SLA Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryContainer.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.secondaryContainer.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryIndigo,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.hub_outlined, color: AppTheme.tertiaryMint, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Live SLA Health',
                            style: GoogleFonts.manrope(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFC8C5D0),
                            ),
                          ),
                          Text(
                            '99.4% On-time Resolution',
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.verified, color: AppTheme.tertiaryMint, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Node Synced',
                          style: GoogleFonts.manrope(
                            fontSize: 11,
                            color: AppTheme.tertiaryMint,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // 4 Pillar Grid
              Row(
                children: [
                  Expanded(
                    child: _buildPillarCard(
                      icon: Icons.psychology_outlined,
                      title: 'AI Urgency Scoring',
                      desc: 'Context-aware timing prior to lectures or exams.',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPillarCard(
                      icon: Icons.filter_center_focus_outlined,
                      title: 'Smart Duplicate Triage',
                      desc: 'Auto-merges multi-reporter complaints.',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildPillarCard(
                      icon: Icons.lock_person_outlined,
                      title: 'Confidential Locker',
                      desc: 'Restricted access for sensitive grievances.',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPillarCard(
                      icon: Icons.radar_outlined,
                      title: 'Predictive Radar',
                      desc: 'Equipment recurrence & fatigue alerts.',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPillarCard({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFDBE1FF), size: 20),
          const SizedBox(height: 6),
          Text(
            title,
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            desc,
            style: GoogleFonts.manrope(
              fontSize: 10,
              color: const Color(0xFFC8C5D0),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMobileHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppTheme.primaryIndigo,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Color(0xFFDBE1FF), size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'CAMPUS CARE v3.0',
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFDBE1FF),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.tertiaryMint,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Online',
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      color: AppTheme.tertiaryMint,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Campus Facilities & Grievance Portal',
            style: GoogleFonts.newsreader(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'AI-powered issue resolution mesh network',
            style: GoogleFonts.manrope(
              fontSize: 12,
              color: const Color(0xFFC8C5D0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightAuthCard(BuildContext context, bool isDesktop) {
    return Padding(
      padding: EdgeInsets.all(isDesktop ? 40 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isRegistering ? 'Create Account' : 'Institutional Sign-In',
                    style: GoogleFonts.manrope(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Campus Care Universal SSO & Security Mesh',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => context.go('/tenant/select'),
                tooltip: 'Switch Campus Workspace',
                icon: const Icon(Icons.swap_horiz, color: AppTheme.secondaryCobalt),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Role Switcher Quick Selector Pills (FR-PLAT-01 testing)
          Text(
            'QUICK ROLE SELECTOR',
            style: GoogleFonts.manrope(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _rolePresets.map((preset) {
              final isSelected = _selectedRolePreset == preset['role'];
              return ChoiceChip(
                label: Text(
                  preset['label']!,
                  style: GoogleFonts.manrope(
                    fontSize: 11,
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
                onSelected: (val) {
                  if (val) {
                    _applyRolePreset(preset['role']!, preset['email']!);
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.statusUrgent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
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
            const SizedBox(height: 16),
          ],

          if (_isRegistering) ...[
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person_outline, size: 20),
              ),
            ),
            const SizedBox(height: 14),
          ],

          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Institutional Email ID',
              prefixIcon: Icon(Icons.alternate_email, size: 20),
            ),
          ),
          const SizedBox(height: 14),

          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password / Security PIN',
              prefixIcon: Icon(Icons.lock_outline, size: 20),
            ),
          ),
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: _isLoading ? null : _handleAuth,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isRegistering ? 'Create Institutional Account' : 'Authenticate & Enter Campus',
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
          ),
          const SizedBox(height: 14),

          Center(
            child: TextButton(
              onPressed: () {
                setState(() {
                  _isRegistering = !_isRegistering;
                  _errorMessage = null;
                });
              },
              child: Text(
                _isRegistering
                    ? 'Already have credentials? Sign in'
                    : "New campus student or staff? Register here",
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.secondaryCobalt,
                ),
              ),
            ),
          ),
          const Divider(height: 28),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shield_outlined, size: 14, color: AppTheme.outline),
              const SizedBox(width: 6),
              Text(
                'End-to-End Encrypted • Multi-Tenant Campus Node',
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

