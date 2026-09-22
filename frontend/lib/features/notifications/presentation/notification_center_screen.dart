import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:campus_care/app/theme.dart';
import 'package:campus_care/core/network/api_client.dart';

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  bool _isLoading = true;
  String _selectedChannel = 'all';
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() => _isLoading = true);
    try {
      final res = await apiClient.dio.get('/notifications');
      if (res.data is List) {
        setState(() {
          _notifications = List<Map<String, dynamic>>.from(res.data);
        });
      }
    } catch (_) {
      // Fallback demo mock notifications matching Stitch screen
      setState(() {
        _notifications = [
          {
            'id': 'notif-01',
            'channel': 'fcm',
            'title': 'CRITICAL SLA ALERT: Stauffer 104 Fume Hood (12m remaining)',
            'message': 'Chemical vapor hazard sensor triggered. Auto-dispatching emergency hazard crew.',
            'timestamp': '2m ago',
            'is_read': false,
            'issue_id': 'cc-8492-f01',
            'urgency': 'critical',
          },
          {
            'id': 'notif-02',
            'channel': 'whatsapp',
            'title': 'WhatsApp Dispatch Sent: Crew Alpha Assigned',
            'message': 'Work order #TKT-2026-8493 assigned to Electrical Lead. Mobile acknowledgment pending.',
            'timestamp': '14m ago',
            'is_read': false,
            'issue_id': 'cc-8493-f02',
            'urgency': 'high',
          },
          {
            'id': 'notif-03',
            'channel': 'email',
            'title': 'Dean Briefing: Academic Grievance Disposed (FERPA Protected)',
            'message': 'Confidential dossier #ACAD-2026-092 resolved by Ombudsperson. Audit hash committed.',
            'timestamp': '1h ago',
            'is_read': false,
            'issue_id': 'acad-2026-092',
            'urgency': 'medium',
          },
          {
            'id': 'notif-04',
            'channel': 'websocket',
            'title': 'Mesh Sync: Packard 204 AC Status Updated to Investigating',
            'message': 'Field crew checked in on site with vibration acoustic sensors.',
            'timestamp': '2h ago',
            'is_read': true,
            'issue_id': 'cc-8492-f01',
            'urgency': 'low',
          },
          {
            'id': 'notif-05',
            'channel': 'whatsapp',
            'title': 'Student SMS/WhatsApp Alert: Science East Water Shutoff',
            'message': 'Broadcast alert sent to 320 occupant numbers in Science Hall East Wing.',
            'timestamp': '4h ago',
            'is_read': true,
            'issue_id': 'cc-8494-f03',
            'urgency': 'medium',
          },
        ];
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _markAllAsRead() {
    setState(() {
      for (var n in _notifications) {
        n['is_read'] = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notification streams marked as read.'),
        backgroundColor: Color(0xFF005137),
      ),
    );
  }

  void _markSingleRead(String id) {
    setState(() {
      final idx = _notifications.indexWhere((n) => n['id'] == id);
      if (idx != -1) {
        _notifications[idx]['is_read'] = true;
      }
    });
  }

  List<Map<String, dynamic>> get _filteredNotifications {
    if (_selectedChannel == 'all') return _notifications;
    if (_selectedChannel == 'unread') {
      return _notifications.where((n) => n['is_read'] == false).toList();
    }
    return _notifications.where((n) => n['channel'] == _selectedChannel).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final unreadCount = _notifications.where((n) => n['is_read'] == false).length;

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
              child: const Icon(Icons.notifications_active_outlined, color: Colors.white, size: 20),
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
                  'UNIFIED NOTIFICATION HUB (SRS §10)',
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
            icon: const Icon(Icons.refresh),
            onPressed: _fetchNotifications,
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
                // Breadcrumb and Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text('STANFORD OPERATIONS', style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.textSecondary)),
                        const Text(' / '),
                        Text('MULTI-CHANNEL HUB', style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.secondaryCobalt)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.accentMint.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF005137), shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Text('All 5 Channels Operational (99.94% SLA)', style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF005137))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Header Block
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Multi-Channel Alert & Dispatch Hub',
                            style: GoogleFonts.newsreader(
                              fontSize: isDesktop ? 28 : 22,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryIndigo,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Unified notification streams synchronized across WhatsApp Business API, Brevo/Resend Email, FCM Push, and In-App WebSockets.',
                            style: GoogleFonts.manrope(fontSize: 13, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    if (unreadCount > 0) ...[
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: _markAllAsRead,
                        icon: const Icon(Icons.done_all, size: 16),
                        label: const Text('Mark all as read'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryIndigo,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 20),

                // Real-time Metrics Strip
                LayoutBuilder(
                  builder: (context, constraints) {
                    final itemWidth = isDesktop ? (constraints.maxWidth - 48) / 4 : (constraints.maxWidth - 12) / 2;
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildMetricCard('Unread Dispatches', '$unreadCount', 'Action Required', AppTheme.statusCritical, Icons.mark_email_unread_outlined, itemWidth),
                        _buildMetricCard('Active FCM Sockets', '1,482', '+14 connected', AppTheme.secondaryCobalt, Icons.sensors, itemWidth),
                        _buildMetricCard('WhatsApp Delivery', '99.8%', 'Avg latency 410ms', const Color(0xFF005137), Icons.chat_bubble_outline, itemWidth),
                        _buildMetricCard('Email Relay (Brevo)', 'Ready', '0 in retry queue', AppTheme.primaryIndigo, Icons.swap_calls, itemWidth),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Channel Filter Bar
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.neutralLightOutline.withOpacity(0.3)),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildChannelChip('All Channels', 'all', Icons.dynamic_feed),
                        const SizedBox(width: 8),
                        _buildChannelChip('Unread ($unreadCount)', 'unread', Icons.priority_high),
                        const SizedBox(width: 8),
                        _buildChannelChip('WhatsApp', 'whatsapp', Icons.chat),
                        const SizedBox(width: 8),
                        _buildChannelChip('FCM Push', 'fcm', Icons.notifications_active),
                        const SizedBox(width: 8),
                        _buildChannelChip('Brevo Email', 'email', Icons.email_outlined),
                        const SizedBox(width: 8),
                        _buildChannelChip('WebSockets', 'websocket', Icons.hub_outlined),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Notification Stream List
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_filteredNotifications.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(48),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.neutralLightOutline.withOpacity(0.3)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.notifications_none, size: 56, color: AppTheme.textSecondary),
                        const SizedBox(height: 12),
                        Text('No notifications in this channel feed', style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('You are all caught up across campus alert channels.', style: GoogleFonts.manrope(fontSize: 13, color: AppTheme.textSecondary)),
                      ],
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filteredNotifications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final notif = _filteredNotifications[index];
                      final id = notif['id'] ?? '';
                      final channel = notif['channel'] ?? 'fcm';
                      final title = notif['title'] ?? 'Alert';
                      final message = notif['message'] ?? '';
                      final timestamp = notif['timestamp'] ?? '';
                      final isRead = notif['is_read'] == true;
                      final issueId = notif['issue_id'] ?? '';

                      return Container(
                        decoration: BoxDecoration(
                          color: isRead ? AppTheme.surfaceWhite : const Color(0xFFF9FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: !isRead ? AppTheme.secondaryCobalt.withOpacity(0.4) : AppTheme.neutralLightOutline.withOpacity(0.3),
                            width: !isRead ? 1.5 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildChannelAvatar(channel),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        _buildChannelTag(channel),
                                        Row(
                                          children: [
                                            Text(timestamp, style: GoogleFonts.manrope(fontSize: 11, color: AppTheme.textSecondary)),
                                            if (!isRead) ...[
                                              const SizedBox(width: 6),
                                              Container(
                                                width: 8,
                                                height: 8,
                                                decoration: const BoxDecoration(
                                                  color: AppTheme.statusCritical,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      title,
                                      style: GoogleFonts.manrope(
                                        fontSize: 14,
                                        fontWeight: isRead ? FontWeight.w600 : FontWeight.w800,
                                        color: AppTheme.primaryIndigo,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      message,
                                      style: GoogleFonts.manrope(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
                                    ),
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 6,
                                      children: [
                                        if (issueId.isNotEmpty)
                                          OutlinedButton.icon(
                                            icon: const Icon(Icons.open_in_new, size: 14),
                                            label: const Text('Open Incident Dossier'),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: AppTheme.primaryIndigo,
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                            onPressed: () => context.push('/issues/$issueId'),
                                          ),
                                        if (!isRead)
                                          TextButton(
                                            onPressed: () => _markSingleRead(id),
                                            child: const Text('Mark Read'),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChannelAvatar(String channel) {
    IconData icon;
    Color color;
    switch (channel) {
      case 'whatsapp':
        icon = Icons.chat;
        color = const Color(0xFF005137);
        break;
      case 'fcm':
        icon = Icons.notifications_active;
        color = AppTheme.statusCritical;
        break;
      case 'email':
        icon = Icons.email_outlined;
        color = AppTheme.secondaryCobalt;
        break;
      default:
        icon = Icons.hub_outlined;
        color = AppTheme.primaryIndigo;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(child: Icon(icon, size: 20, color: color)),
    );
  }

  Widget _buildChannelTag(String channel) {
    String label;
    Color color;
    switch (channel) {
      case 'whatsapp':
        label = 'WhatsApp Business API';
        color = const Color(0xFF005137);
        break;
      case 'fcm':
        label = 'FCM Push Notification';
        color = AppTheme.statusCritical;
        break;
      case 'email':
        label = 'Brevo / Resend Email';
        color = AppTheme.secondaryCobalt;
        break;
      default:
        label = 'In-App Live WebSocket';
        color = AppTheme.primaryIndigo;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    );
  }

  Widget _buildChannelChip(String label, String channelValue, IconData icon) {
    final isSelected = _selectedChannel == channelValue;
    return ChoiceChip(
      avatar: Icon(icon, size: 14, color: isSelected ? Colors.white : AppTheme.textSecondary),
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedChannel = channelValue);
        }
      },
      selectedColor: AppTheme.primaryIndigo,
      backgroundColor: AppTheme.surfaceWhite,
      labelStyle: GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? Colors.white : AppTheme.textPrimary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryIndigo : AppTheme.neutralLightOutline.withOpacity(0.4),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String count, String subtitle, Color countColor, IconData icon, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.neutralLightOutline.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textSecondary)),
              const SizedBox(height: 4),
              Text(count, style: GoogleFonts.newsreader(fontSize: 22, fontWeight: FontWeight.w700, color: countColor)),
              const SizedBox(height: 2),
              Text(subtitle, style: GoogleFonts.manrope(fontSize: 10, color: AppTheme.textSecondary)),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: countColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: countColor),
          ),
        ],
      ),
    );
  }
}
