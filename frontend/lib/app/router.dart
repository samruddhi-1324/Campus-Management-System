import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:campus_care/features/auth/presentation/login_screen.dart';
import 'package:campus_care/features/reporter/presentation/report_issue_screen.dart';
import 'package:campus_care/features/reporter/presentation/my_issues_screen.dart';
import 'package:campus_care/features/reporter/presentation/issue_detail_screen.dart';
import 'package:campus_care/features/coordinator/presentation/coordinator_queue_screen.dart';
import 'package:campus_care/features/coordinator/presentation/issue_triage_screen.dart';
import 'package:campus_care/features/supervisor/presentation/supervisor_workload_screen.dart';
import 'package:campus_care/features/supervisor/presentation/sla_risk_screen.dart';
import 'package:campus_care/features/ops_head/presentation/analytics_dashboard_screen.dart';
import 'package:campus_care/features/admin/presentation/admin_settings_screen.dart';
import 'package:campus_care/features/admin/presentation/master_data_screen.dart';
import 'package:campus_care/features/admin/presentation/audit_logs_screen.dart';
import 'package:campus_care/features/notifications/presentation/notification_center_screen.dart';
import 'package:campus_care/features/academic/presentation/academic_concerns_screen.dart';
import 'package:campus_care/features/academic/presentation/confidential_triage_screen.dart';
import 'package:campus_care/features/recommendations/presentation/recommendations_screen.dart';
import 'package:campus_care/features/recurrence/presentation/recurrence_screen.dart';
import 'package:campus_care/features/search/presentation/nl_search_screen.dart';
import 'package:campus_care/features/historical_trends/presentation/multi_year_trends_screen.dart';
import 'package:campus_care/features/tenant/presentation/tenant_selector_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    // Phase 1: Reporter Routes
    GoRoute(
      path: '/reporter/issues',
      builder: (context, state) => const MyIssuesScreen(),
    ),
    GoRoute(
      path: '/reporter/new',
      builder: (context, state) => const ReportIssueScreen(),
    ),
    GoRoute(
      path: '/reporter/issues/:id',
      builder: (context, state) => IssueDetailScreen(
        issueId: state.pathParameters['id'] ?? '',
      ),
    ),
    // Phase 1: Coordinator Routes
    GoRoute(
      path: '/coordinator/queue',
      builder: (context, state) => const CoordinatorQueueScreen(),
    ),
    GoRoute(
      path: '/coordinator/issues/:id/triage',
      builder: (context, state) => IssueTriageScreen(
        issueId: state.pathParameters['id'] ?? '',
      ),
    ),
    // Phase 1: Supervisor Routes
    GoRoute(
      path: '/supervisor/workload',
      builder: (context, state) => const SupervisorWorkloadScreen(),
    ),
    GoRoute(
      path: '/supervisor/sla-risks',
      builder: (context, state) => const SlaRiskScreen(),
    ),
    // Phase 1: Ops Head Routes
    GoRoute(
      path: '/ops/analytics',
      builder: (context, state) => const AnalyticsDashboardScreen(),
    ),
    // Phase 1: Admin Routes
    GoRoute(
      path: '/admin/settings',
      builder: (context, state) => const AdminSettingsScreen(),
    ),
    GoRoute(
      path: '/admin/master-data',
      builder: (context, state) => const MasterDataScreen(),
    ),
    GoRoute(
      path: '/admin/audit-logs',
      builder: (context, state) => const AuditLogsScreen(),
    ),
    // Phase 1: Notifications Route
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationCenterScreen(),
    ),
    // Phase 2: Academic Concerns Routes
    GoRoute(
      path: '/academic/concerns',
      builder: (context, state) => const AcademicConcernsScreen(),
    ),
    GoRoute(
      path: '/academic/concerns/:id/confidential-review',
      builder: (context, state) => ConfidentialTriageScreen(
        concernId: state.pathParameters['id'] ?? '',
      ),
    ),
    // Phase 2: AI Recommendations & Recurrence Routes
    GoRoute(
      path: '/recommendations',
      builder: (context, state) => const RecommendationsScreen(),
    ),
    GoRoute(
      path: '/recurrence/patterns',
      builder: (context, state) => const RecurrenceScreen(),
    ),
    // Phase 3: Natural Language Search Route
    GoRoute(
      path: '/search',
      builder: (context, state) => const NLSearchScreen(),
    ),
    // Phase 3: Multi-Year Historical Trends Route
    GoRoute(
      path: '/ops/historical-trends',
      builder: (context, state) => const MultiYearTrendsScreen(),
    ),
    // Phase 3: Multi-Institution Selector Route
    GoRoute(
      path: '/institution/select',
      builder: (context, state) => const TenantSelectorScreen(),
    ),
  ],
);
