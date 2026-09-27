import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:campus_care/app/theme.dart';

class WorkflowScreenItem {
  final int step;
  final String title;
  final String subtitle;
  final String route;
  final IconData icon;

  const WorkflowScreenItem({
    required this.step,
    required this.title,
    required this.subtitle,
    required this.route,
    required this.icon,
  });
}

const List<WorkflowScreenItem> workflowScreens = [
  WorkflowScreenItem(step: 1, title: 'Auth & Login', subtitle: 'Role-based Persona Sign-in', route: '/login', icon: Icons.login),
  WorkflowScreenItem(step: 2, title: 'Campus Switcher', subtitle: 'Multi-Tenant Partitioning', route: '/tenant/select', icon: Icons.domain),
  WorkflowScreenItem(step: 3, title: 'Complaints Dashboard', subtitle: 'Live Influx & In-Progress Tickets', route: '/reporter/issues', icon: Icons.dashboard_outlined),
  WorkflowScreenItem(step: 4, title: 'Voice & AI Issue Filing', subtitle: 'Category, Voice Input & Photos', route: '/reporter/new', icon: Icons.add_alert_outlined),
  WorkflowScreenItem(step: 5, title: 'Lifecycle Tracker', subtitle: '5-Step Progress & Proof Review', route: '/reporter/issues/CC-8492', icon: Icons.track_changes),
  WorkflowScreenItem(step: 6, title: 'Coordinator Triage Desk', subtitle: 'AI Urgency & Team Dispatching', route: '/coordinator/queue', icon: Icons.assignment_turned_in_outlined),
  WorkflowScreenItem(step: 7, title: 'Supervisor SLA Radar', subtitle: 'Countdown Rings & Work Orders', route: '/supervisor/sla-risks', icon: Icons.timelapse),
  WorkflowScreenItem(step: 8, title: 'AI Semantic Search', subtitle: 'Conversational Query Engine', route: '/search', icon: Icons.search),
  WorkflowScreenItem(step: 9, title: 'Equipment Fatigue Radar', subtitle: 'Recurring Asset Breakdown Map', route: '/recurrence/patterns', icon: Icons.radar),
  WorkflowScreenItem(step: 10, title: 'Executive Analytics', subtitle: 'Campus Heatmap & MTTR Metrics', route: '/ops/analytics', icon: Icons.analytics_outlined),
  WorkflowScreenItem(step: 11, title: 'Academic Grievance Form', subtitle: 'Confidential Disciplinary Filing', route: '/academic/concerns', icon: Icons.school_outlined),
  WorkflowScreenItem(step: 12, title: 'Notification Center', subtitle: 'Multi-Channel Alert Feed', route: '/notifications', icon: Icons.notifications_none),
  WorkflowScreenItem(step: 13, title: 'Academic Officer Review', subtitle: 'Anonymized Disposition Desk', route: '/academic/concerns/GR-1048/confidential-review', icon: Icons.gavel_outlined),
  WorkflowScreenItem(step: 14, title: 'AI Maintenance Engine', subtitle: 'Predictive Part Replacement', route: '/recommendations', icon: Icons.auto_awesome),
];

class WorkflowSequenceBar extends StatelessWidget {
  final int currentStep;

  const WorkflowSequenceBar({super.key, required this.currentStep});

  void _showTourSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Stitch Screen Tour',
                          style: GoogleFonts.manrope(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primaryIndigo,
                          ),
                        ),
                        Text(
                          'Jump directly to any of the 14 Stitch screens',
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  itemCount: workflowScreens.length,
                  itemBuilder: (ctx, index) {
                    final item = workflowScreens[index];
                    final isCurrent = item.step == currentStep;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isCurrent ? AppTheme.primaryIndigo.withOpacity(0.06) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isCurrent ? AppTheme.primaryIndigo : AppTheme.neutralLightOutline.withOpacity(0.6),
                          width: isCurrent ? 1.5 : 1,
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isCurrent ? AppTheme.primaryIndigo : AppTheme.surfaceContainerLow,
                          child: Text(
                            '${item.step}',
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: isCurrent ? Colors.white : AppTheme.primaryIndigo,
                            ),
                          ),
                        ),
                        title: Text(
                          item.title,
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                            color: isCurrent ? AppTheme.primaryIndigo : AppTheme.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          item.subtitle,
                          style: GoogleFonts.manrope(fontSize: 11, color: AppTheme.textSecondary),
                        ),
                        trailing: Icon(
                          item.icon,
                          size: 20,
                          color: isCurrent ? AppTheme.secondaryCobalt : AppTheme.outline,
                        ),
                        onTap: () {
                          Navigator.pop(ctx);
                          context.go(item.route);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final prevIndex = (currentStep - 2 + workflowScreens.length) % workflowScreens.length;
    final nextIndex = currentStep % workflowScreens.length;

    final prevItem = workflowScreens[prevIndex];
    final nextItem = workflowScreens[nextIndex];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primaryIndigo.withOpacity(0.96),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Previous button
          InkWell(
            onTap: () => context.go(prevItem.route),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.arrow_back, size: 14, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    'Prev',
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Step Badge (Click to open tour sheet)
          InkWell(
            onTap: () => _showTourSheet(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.secondaryCobalt.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.tertiaryMint.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  Text(
                    'Step $currentStep/14',
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.tertiaryMint,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.unfold_more, size: 14, color: AppTheme.tertiaryMint),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Next button
          InkWell(
            onTap: () => context.go(nextItem.route),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.secondaryCobalt,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.secondaryCobalt.withOpacity(0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(
                    'Next (${nextItem.step})',
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward, size: 14, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
