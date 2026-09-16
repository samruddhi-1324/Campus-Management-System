import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const Scaffold(
        body: Center(
          child: Text('Campus Care — Issue Tracker'),
        ),
      ),
    ),
    // Role-specific and feature routes will be mounted in Phase 1:
    // /login
    // /reporter/issues
    // /reporter/new
    // /coordinator/queue
    // /supervisor/workload
    // /ops/analytics
    // /admin/settings
  ],
);
