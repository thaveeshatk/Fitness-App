import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/notification_model.dart';
import '../../data/services/notification_service.dart';
import '../../../plan/presentation/screens/my_plan_screen.dart';
import '../../../progress/presentation/screens/goals_screen.dart';
import '../../../progress/presentation/screens/progress_screen.dart';
import '../../../workouts/presentation/screens/workouts_screen.dart';
import 'notification_settings_screen.dart';

/// Notification Center screen displaying all notifications with category filtering,
/// read/unread management, bulk actions, and deep-navigation to related features.
class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  String _selectedFilter = 'All';

  final List<String> _filters = [
    'All',
    'Unread',
    'Workouts',
    'Schedule',
    'Goals',
    'Adaptive Plan',
    'System',
  ];

  @override
  void initState() {
    super.initState();
    NotificationService.loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFFAFBFD);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(textPrimary, isDark),
            _buildFilterTabs(isDark),
            Expanded(
              child: ValueListenableBuilder<List<NotificationModel>>(
                valueListenable: NotificationService.notificationsNotifier,
                builder: (context, allNotifications, _) {
                  final filtered = _applyFilter(allNotifications);

                  if (filtered.isEmpty) {
                    return _buildEmptyState(textPrimary, textSecondary, isDark);
                  }

                  return RefreshIndicator(
                    onRefresh: () => NotificationService.loadNotifications(forceRefresh: true),
                    color: AppColors.primaryTeal,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        return _buildNotificationCard(
                          item,
                          cardBg,
                          textPrimary,
                          textSecondary,
                          isDark,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header Bar ─────────────────────────────────────────────────────────────
  Widget _buildHeader(Color textColor, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEEF2F7),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.chevron_left_rounded,
                  color: isDark ? Colors.white : const Color(0xFF334155),
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Notification Center',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: textColor,
                letterSpacing: -0.3,
              ),
            ),
          ),
          // Mark all as read button
          IconButton(
            tooltip: 'Mark all as read',
            icon: const Icon(Icons.done_all_rounded, size: 22),
            color: AppColors.primaryTeal,
            onPressed: () async {
              await NotificationService.markAllAsRead();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'All notifications marked as read',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                    ),
                    duration: const Duration(seconds: 1),
                    backgroundColor: AppColors.primaryTeal,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
          // Settings shortcut button
          IconButton(
            tooltip: 'Notification Settings',
            icon: const Icon(Icons.tune_rounded, size: 21),
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationSettingsScreen()),
              );
            },
          ),
          // Clear all button
          IconButton(
            tooltip: 'Clear all notifications',
            icon: const Icon(Icons.delete_sweep_outlined, size: 22),
            color: const Color(0xFFDC2626),
            onPressed: _showClearAllDialog,
          ),
        ],
      ),
    );
  }

  // ── Filter Tabs ────────────────────────────────────────────────────────────
  Widget _buildFilterTabs(bool isDark) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;

          return ChoiceChip(
            label: Text(
              filter,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
              ),
            ),
            selected: isSelected,
            selectedColor: AppColors.primaryTeal,
            backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
            showCheckmark: false,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected
                    ? AppColors.primaryTeal
                    : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              ),
            ),
            onSelected: (_) {
              setState(() {
                _selectedFilter = filter;
              });
            },
          );
        },
      ),
    );
  }

  // ── Notification Card ──────────────────────────────────────────────────────
  Widget _buildNotificationCard(
    NotificationModel item,
    Color cardBg,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFDC2626),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
      ),
      onDismissed: (_) {
        NotificationService.deleteNotification(item.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Notification removed',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500),
            ),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _handleNotificationTap(item),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: item.isRead
                ? cardBg
                : (isDark ? const Color(0xFF1A283B) : const Color(0xFFF0FDF9)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: item.isRead
                  ? (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))
                  : AppColors.primaryTeal.withValues(alpha: 0.3),
              width: item.isRead ? 1.0 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Icon
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isDark
                      ? item.type.iconColor.withValues(alpha: 0.2)
                      : item.type.iconBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.type.icon,
                  color: item.type.iconColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              // Content details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: item.isRead ? FontWeight.w700 : FontWeight.w800,
                              color: textPrimary,
                            ),
                          ),
                        ),
                        if (!item.isRead) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF3B30),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.message,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: textSecondary,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.type.displayName,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF475569),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item.timeAgo,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? const Color(0xFF64748B)
                                : const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Quick single delete or options
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.more_vert_rounded,
                  size: 18,
                  color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                ),
                onSelected: (val) {
                  if (val == 'toggle_read') {
                    if (item.isRead) {
                      // Mark unread
                      final list = NotificationService.notificationsNotifier.value;
                      final idx = list.indexWhere((n) => n.id == item.id);
                      if (idx != -1) {
                        list[idx] = list[idx].copyWith(isRead: false);
                        NotificationService.loadNotifications();
                      }
                    } else {
                      NotificationService.markAsRead(item.id);
                    }
                  } else if (val == 'delete') {
                    NotificationService.deleteNotification(item.id);
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'toggle_read',
                    child: Text(
                      item.isRead ? 'Mark as unread' : 'Mark as read',
                      style: GoogleFonts.plusJakartaSans(fontSize: 13),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      'Delete',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: const Color(0xFFDC2626),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Empty State ────────────────────────────────────────────────────────────
  Widget _buildEmptyState(Color textPrimary, Color textSecondary, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mark_email_read_outlined,
                size: 38,
                color: AppColors.primaryTeal,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "You're all caught up!",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "New workout reminders, weekly goal milestones, and adaptive plan updates will appear here.",
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helper Logic ───────────────────────────────────────────────────────────
  List<NotificationModel> _applyFilter(List<NotificationModel> list) {
    switch (_selectedFilter) {
      case 'Unread':
        return list.where((n) => !n.isRead).toList();
      case 'Workouts':
        return list.where((n) => n.type == NotificationType.workout).toList();
      case 'Schedule':
        return list.where((n) => n.type == NotificationType.schedule).toList();
      case 'Goals':
        return list.where((n) => n.type == NotificationType.goal).toList();
      case 'Adaptive Plan':
        return list.where((n) => n.type == NotificationType.adaptivePlan).toList();
      case 'System':
        return list.where((n) => n.type == NotificationType.system).toList();
      case 'All':
      default:
        return list;
    }
  }

  void _handleNotificationTap(NotificationModel item) async {
    // 1. Mark as read
    if (!item.isRead) {
      await NotificationService.markAsRead(item.id);
    }

    if (!mounted) return;

    // 2. Deep-navigate to relevant destination
    if (item.actionRoute == '/my-plan' || item.type == NotificationType.schedule) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MyPlanScreen()),
      );
    } else if (item.actionRoute == '/goals' || item.type == NotificationType.goal) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const GoalsScreen()),
      );
    } else if (item.actionRoute == '/progress' || item.type == NotificationType.progress) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProgressScreen()),
      );
    } else if (item.actionRoute == '/workouts' || item.type == NotificationType.workout) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const WorkoutsScreen()),
      );
    } else {
      // Fallback: Display details modal safely without navigation error
      _showDetailDialog(item);
    }
  }

  void _showDetailDialog(NotificationModel item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(item.type.icon, color: item.type.iconColor, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                item.title,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.message,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: const Color(0xFF475569),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Received ${item.timeAgo}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Close',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: AppColors.primaryTeal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Clear All Notifications?',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        content: Text(
          'This will permanently remove all notifications for your account. This action cannot be undone.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: const Color(0xFF64748B),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await NotificationService.clearAllNotifications();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'All notifications cleared',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500),
                    ),
                    backgroundColor: const Color(0xFF0F172A),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Text(
              'Clear All',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
