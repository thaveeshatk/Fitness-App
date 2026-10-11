import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/notification_preferences.dart';
import '../../data/services/notification_service.dart';

/// Dedicated Notification Settings page allowing users to configure master toggles,
/// category alerts, preferred reminder time, and reminder days.
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  late NotificationPreferences _preferences;
  bool _isLoading = true;

  final List<String> _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentPreferences();
  }

  Future<void> _loadCurrentPreferences() async {
    final prefs = await NotificationService.loadPreferences();
    if (mounted) {
      setState(() {
        _preferences = prefs;
        _isLoading = false;
      });
    }
  }

  Future<void> _updatePreferences(NotificationPreferences newPrefs) async {
    setState(() {
      _preferences = newPrefs;
    });
    await NotificationService.updatePreferences(newPrefs);
  }

  Future<void> _resetToDefaults() async {
    final defaults = NotificationPreferences.defaults();
    await _updatePreferences(defaults);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Preferences restored to defaults',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primaryTeal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFFAFBFD);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        bottom: false,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryTeal,
                ),
              )
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(textPrimary, isDark),
                    const SizedBox(height: 24),

                    // Master Toggle Card
                    _buildMasterToggleCard(cardBg, textPrimary, textSecondary, isDark),
                    const SizedBox(height: 24),

                    // Reminders & Activities
                    _buildSectionHeader('WORKOUT & SCHEDULE REMINDERS'),
                    const SizedBox(height: 12),
                    _buildToggleCard(
                      icon: Icons.fitness_center_rounded,
                      iconColor: const Color(0xFF00635A),
                      iconBg: const Color(0xFFE6FAF3),
                      title: 'Workout Reminders',
                      description: 'Remind me about upcoming and scheduled workout sessions',
                      value: _preferences.workoutReminders,
                      enabled: _preferences.enabled,
                      cardBg: cardBg,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      onChanged: (val) {
                        _updatePreferences(_preferences.copyWith(workoutReminders: val));
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildToggleCard(
                      icon: Icons.calendar_month_rounded,
                      iconColor: const Color(0xFF0284C7),
                      iconBg: const Color(0xFFE0F2FE),
                      title: 'Schedule Reminders',
                      description: 'Alert me when upcoming scheduled activities require attention',
                      value: _preferences.scheduleReminders,
                      enabled: _preferences.enabled,
                      cardBg: cardBg,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      onChanged: (val) {
                        _updatePreferences(_preferences.copyWith(scheduleReminders: val));
                      },
                    ),
                    const SizedBox(height: 24),

                    // Goals & Progress
                    _buildSectionHeader('GOALS & PROGRESS UPDATES'),
                    const SizedBox(height: 12),
                    _buildToggleCard(
                      icon: Icons.emoji_events_rounded,
                      iconColor: const Color(0xFFD97706),
                      iconBg: const Color(0xFFFEF3C7),
                      title: 'Goal Notifications',
                      description: 'Notify me when weekly goals, milestones, and challenges are achieved',
                      value: _preferences.goalNotifications,
                      enabled: _preferences.enabled,
                      cardBg: cardBg,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      onChanged: (val) {
                        _updatePreferences(_preferences.copyWith(goalNotifications: val));
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildToggleCard(
                      icon: Icons.trending_up_rounded,
                      iconColor: const Color(0xFF7C3AED),
                      iconBg: const Color(0xFFEDE9FE),
                      title: 'Progress Updates',
                      description: 'Insights on workout streaks, consistency, and active minutes',
                      value: _preferences.progressUpdates,
                      enabled: _preferences.enabled,
                      cardBg: cardBg,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      onChanged: (val) {
                        _updatePreferences(_preferences.copyWith(progressUpdates: val));
                      },
                    ),
                    const SizedBox(height: 24),

                    // Adaptive Plan & Motivation
                    _buildSectionHeader('ADAPTIVE COACHING & MOTIVATION'),
                    const SizedBox(height: 12),
                    _buildToggleCard(
                      icon: Icons.auto_awesome_rounded,
                      iconColor: const Color(0xFF059669),
                      iconBg: const Color(0xFFD1FAE5),
                      title: 'Adaptive Plan Updates',
                      description: 'Alert me when my personalized workout plan is adapted or ready for review',
                      value: _preferences.adaptivePlanUpdates,
                      enabled: _preferences.enabled,
                      cardBg: cardBg,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      onChanged: (val) {
                        _updatePreferences(_preferences.copyWith(adaptivePlanUpdates: val));
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildToggleCard(
                      icon: Icons.lightbulb_rounded,
                      iconColor: const Color(0xFFEA580C),
                      iconBg: const Color(0xFFFFEDD5),
                      title: 'Motivational Notifications',
                      description: 'Encouraging motivational messages to support consistent workout habits',
                      value: _preferences.motivationalNotifications,
                      enabled: _preferences.enabled,
                      cardBg: cardBg,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      onChanged: (val) {
                        _updatePreferences(_preferences.copyWith(motivationalNotifications: val));
                      },
                    ),
                    const SizedBox(height: 24),

                    // Schedule Configuration: Time & Days
                    _buildSectionHeader('REMINDER TIMING & DAYS'),
                    const SizedBox(height: 12),
                    _buildReminderTimingCard(cardBg, textPrimary, textSecondary, isDark),
                    const SizedBox(height: 32),

                    // Reset button
                    Center(
                      child: TextButton.icon(
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: Text(
                          'Reset to Default Preferences',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF64748B),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onPressed: _resetToDefaults,
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader(Color textColor, bool isDark) {
    return Row(
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
        const SizedBox(width: 16),
        Text(
          'Notifications',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF94A3B8),
        letterSpacing: 1.1,
      ),
    );
  }

  // ── Master Toggle Card ─────────────────────────────────────────────────────
  Widget _buildMasterToggleCard(
    Color cardBg,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _preferences.enabled
            ? (isDark ? const Color(0xFF0F3B37) : const Color(0xFFF0FDF4))
            : cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _preferences.enabled
              ? AppColors.primaryTeal
              : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _preferences.enabled
                  ? AppColors.primaryTeal
                  : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _preferences.enabled
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_off_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enable Notifications',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _preferences.enabled
                      ? 'Master toggle active. Alerts will be delivered according to preferences below.'
                      : 'All notifications are disabled across the app.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _preferences.enabled,
            activeTrackColor: AppColors.primaryTeal,
            onChanged: (val) {
              _updatePreferences(_preferences.copyWith(enabled: val));
            },
          ),
        ],
      ),
    );
  }

  // ── Toggle Item Card ───────────────────────────────────────────────────────
  Widget _buildToggleCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String description,
    required bool value,
    required bool enabled,
    required Color cardBg,
    required Color textPrimary,
    required Color textSecondary,
    required ValueChanged<bool> onChanged,
  }) {
    final effectiveOpacity = enabled ? 1.0 : 0.45;

    return Opacity(
      opacity: effectiveOpacity,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0).withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: value,
              activeTrackColor: AppColors.primaryTeal,
              onChanged: enabled ? onChanged : null,
            ),
          ],
        ),
      ),
    );
  }

  // ── Timing & Days Card ─────────────────────────────────────────────────────
  Widget _buildReminderTimingCard(
    Color cardBg,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    final enabled = _preferences.enabled;

    return Opacity(
      opacity: enabled ? 1.0 : 0.45,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0).withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time selection row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.access_time_filled_rounded,
                        color: Color(0xFF0284C7),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reminder Time',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                        Text(
                          'Preferred time to receive alerts',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                InkWell(
                  onTap: enabled ? _selectReminderTime : null,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.primaryTeal.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      _formatReminderTime(_preferences.reminderTime),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryTeal,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 32),

            // Reminder Days
            Text(
              'Reminder Days',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Select which days workout reminders should be delivered:',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _weekdays.map((day) {
                final isSelected = _preferences.reminderDays.contains(day);
                return FilterChip(
                  label: Text(
                    day.substring(0, 3), // Mon, Tue, etc.
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.primaryTeal,
                  backgroundColor:
                      isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                  checkmarkColor: Colors.white,
                  showCheckmark: false,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primaryTeal
                          : (isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
                    ),
                  ),
                  onSelected: enabled
                      ? (selected) {
                          final updatedDays =
                              List<String>.from(_preferences.reminderDays);
                          if (selected) {
                            if (!updatedDays.contains(day)) updatedDays.add(day);
                          } else {
                            if (updatedDays.length > 1) {
                              updatedDays.remove(day);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('At least one reminder day must be selected.'),
                                  duration: Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }
                          }
                          _updatePreferences(
                            _preferences.copyWith(reminderDays: updatedDays),
                          );
                        }
                      : null,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectReminderTime() async {
    final parts = _preferences.reminderTime.split(':');
    final initialHour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 18 : 18;
    final initialMinute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: initialMinute),
    );

    if (picked != null) {
      final hourStr = picked.hour.toString().padLeft(2, '0');
      final minStr = picked.minute.toString().padLeft(2, '0');
      final newTime = '$hourStr:$minStr';
      await _updatePreferences(_preferences.copyWith(reminderTime: newTime));
    }
  }

  String _formatReminderTime(String time24) {
    try {
      final parts = time24.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final amPm = hour >= 12 ? 'PM' : 'AM';
      final hour12 = hour % 12 == 0 ? 12 : hour % 12;
      final minuteStr = minute.toString().padLeft(2, '0');
      return '$hour12:$minuteStr $amPm';
    } catch (_) {
      return time24;
    }
  }
}
