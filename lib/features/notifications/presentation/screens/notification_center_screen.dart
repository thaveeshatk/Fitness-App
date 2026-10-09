import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../data/models/notification_model.dart';
import '../../data/services/notification_service.dart';

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  String _filter = 'All'; // 'All', 'Unread', 'Read'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFBFD),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, color: Color(0xFF334155), size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: Color(0xFF0284C7)),
            onPressed: () => NotificationService.markAllAsRead(),
            tooltip: 'Mark all as read',
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
            onPressed: _confirmClearAll,
            tooltip: 'Clear all',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildFilterTabs(),
            Expanded(
              child: ValueListenableBuilder<List<NotificationModel>>(
                valueListenable: NotificationService.notificationsNotifier,
                builder: (context, notifications, child) {
                  final filteredNotifs = _getFilteredNotifications(notifications);
                  
                  if (filteredNotifs.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredNotifs.length,
                    itemBuilder: (context, index) {
                      final notif = filteredNotifs[index];
                      return _buildNotificationItem(notif);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<NotificationModel> _getFilteredNotifications(List<NotificationModel> notifications) {
    if (_filter == 'Unread') return notifications.where((n) => !n.isRead).toList();
    if (_filter == 'Read') return notifications.where((n) => n.isRead).toList();
    return notifications;
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          _buildTab('All'),
          const SizedBox(width: 8),
          _buildTab('Unread'),
          const SizedBox(width: 8),
          _buildTab('Read'),
        ],
      ),
    );
  }

  Widget _buildTab(String label) {
    final isSelected = _filter == label;
    return GestureDetector(
      onTap: () => setState(() => _filter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00635A) : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'When you get notifications,\nthey\'ll show up here.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel notif) {
    return Dismissible(
      key: Key(notif.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        NotificationService.deleteNotification(notif.id);
      },
      child: GestureDetector(
        onTap: () {
          if (!notif.isRead) {
            NotificationService.markAsRead(notif.id);
          }
          // Navigate based on notif.actionUrl or relatedEntityType if needed
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notif.isRead ? Colors.white : const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: notif.isRead ? Colors.transparent : const Color(0xFF00635A).withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIconForCategory(notif.category, notif.isRead),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notif.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        Text(
                          timeago.format(notif.createdAt, locale: 'en_short'),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notif.message,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: const Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              if (!notif.isRead) ...[
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0284C7),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconForCategory(String category, bool isRead) {
    IconData iconData;
    Color color;
    switch (category) {
      case 'workout_completed':
        iconData = Icons.emoji_events;
        color = Colors.amber;
        break;
      case 'workout_reminder':
        iconData = Icons.fitness_center;
        color = const Color(0xFF00635A);
        break;
      case 'plan_updated':
        iconData = Icons.trending_up;
        color = const Color(0xFF0284C7);
        break;
      case 'inactivity':
        iconData = Icons.directions_run;
        color = Colors.deepOrange;
        break;
      default:
        iconData = Icons.notifications;
        color = const Color(0xFF64748B);
    }
    
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isRead ? const Color(0xFFF1F5F9) : color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: isRead ? const Color(0xFF94A3B8) : color, size: 20),
    );
  }

  Future<void> _confirmClearAll() async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear all notifications?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
        content: Text('This action cannot be undone.', style: GoogleFonts.plusJakartaSans()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldClear == true) {
      await NotificationService.clearAll();
    }
  }
}
