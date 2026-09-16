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

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    // Reporter Routes
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
    // Coordinator Routes
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
    // Supervisor Routes
    GoRoute(
      path: '/supervisor/workload',
      builder: (context, state) => const SupervisorWorkloadScreen(),
    ),
    GoRoute(
      path: '/supervisor/sla-risks',
      builder: (context, state) => const SlaRiskScreen(),
    ),
    // Ops Head Routes
    GoRoute(
      path: '/ops/analytics',
      builder: (context, state) => const AnalyticsDashboardScreen(),
    ),
    // Admin Routes
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
    // Notifications Route
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationCenterScreen(),
    ),
  ],
);
