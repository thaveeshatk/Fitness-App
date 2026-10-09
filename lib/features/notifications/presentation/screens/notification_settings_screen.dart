import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/notification_preference_model.dart';
import '../../data/services/notification_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  late NotificationPreferenceModel _prefs;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _prefs = NotificationService.preferences;
  }

  Future<void> _updatePrefs(NotificationPreferenceModel newPrefs) async {
    setState(() {
      _prefs = newPrefs;
      _isLoading = true;
    });
    
    await NotificationService.updatePreferences(newPrefs);
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

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
      ),
      body: SafeArea(
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('NOTIFICATION PREFERENCES'),
                  const SizedBox(height: 12),
                  _buildToggleCard(
                    title: 'Workout Reminders',
                    value: _prefs.workoutRemindersEnabled,
                    onChanged: (val) => _updatePrefs(_prefs.copyWith(workoutRemindersEnabled: val)),
                  ),
                  const SizedBox(height: 12),
                  _buildToggleCard(
                    title: 'Scheduled Workout Reminders',
                    value: _prefs.scheduledWorkoutRemindersEnabled,
                    onChanged: (val) => _updatePrefs(_prefs.copyWith(scheduledWorkoutRemindersEnabled: val)),
                  ),
                  const SizedBox(height: 12),
                  _buildToggleCard(
                    title: 'Weekly Progress Reports',
                    value: _prefs.weeklyReportsEnabled,
                    onChanged: (val) => _updatePrefs(_prefs.copyWith(weeklyReportsEnabled: val)),
                  ),
                  const SizedBox(height: 12),
                  _buildToggleCard(
                    title: 'Goal Achievements',
                    value: _prefs.goalAchievementsEnabled,
                    onChanged: (val) => _updatePrefs(_prefs.copyWith(goalAchievementsEnabled: val)),
                  ),
                  const SizedBox(height: 12),
                  _buildToggleCard(
                    title: 'Adaptive Plan Updates',
                    value: _prefs.adaptivePlanUpdatesEnabled,
                    onChanged: (val) => _updatePrefs(_prefs.copyWith(adaptivePlanUpdatesEnabled: val)),
                  ),
                  const SizedBox(height: 12),
                  _buildToggleCard(
                    title: 'Inactivity Reminders',
                    value: _prefs.inactivityRemindersEnabled,
                    onChanged: (val) => _updatePrefs(_prefs.copyWith(inactivityRemindersEnabled: val)),
                  ),
                  
                  const SizedBox(height: 32),
                  _buildSectionHeader('REMINDER SCHEDULING'),
                  const SizedBox(height: 12),
                  _buildTimePickerCard(
                    title: 'Preferred Reminder Time',
                    time: _prefs.preferredReminderTime,
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _prefs.preferredReminderTime,
                      );
                      if (time != null) {
                        _updatePrefs(_prefs.copyWith(preferredReminderTime: time));
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildDaysSelectorCard(),
                  
                  const SizedBox(height: 32),
                  _buildSectionHeader('QUIET HOURS'),
                  const SizedBox(height: 12),
                  _buildTimePickerCard(
                    title: 'Start Time',
                    time: _prefs.quietHoursStart,
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _prefs.quietHoursStart,
                      );
                      if (time != null) {
                        _updatePrefs(_prefs.copyWith(quietHoursStart: time));
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildTimePickerCard(
                    title: 'End Time',
                    time: _prefs.quietHoursEnd,
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _prefs.quietHoursEnd,
                      );
                      if (time != null) {
                        _updatePrefs(_prefs.copyWith(quietHoursEnd: time));
                      }
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  _buildSectionHeader('DELIVERY PREFERENCES'),
                  const SizedBox(height: 12),
                  _buildToggleCard(
                    title: 'In-App Notifications',
                    value: _prefs.inAppNotificationsEnabled,
                    onChanged: (val) => _updatePrefs(_prefs.copyWith(inAppNotificationsEnabled: val)),
                  ),
                  const SizedBox(height: 12),
                  _buildToggleCard(
                    title: 'Push Notifications',
                    subtitle: 'Requires browser/device permissions',
                    value: _prefs.pushNotificationsEnabled,
                    onChanged: (val) {
                      // Note: In a real app, this is where you'd request permission first
                      _updatePrefs(_prefs.copyWith(pushNotificationsEnabled: val));
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF94A3B8),
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildToggleCard({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF00635A),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePickerCard({
    required String title,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F172A),
              ),
            ),
            Row(
              children: [
                Text(
                  time.format(context),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0284C7),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1), size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaysSelectorCard() {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Active Days',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final dayIndex = index + 1; // 1 to 7
              final isSelected = _prefs.selectedReminderDays.contains(dayIndex);
              return GestureDetector(
                onTap: () {
                  final newDays = List<int>.from(_prefs.selectedReminderDays);
                  if (isSelected) {
                    newDays.remove(dayIndex);
                  } else {
                    newDays.add(dayIndex);
                  }
                  _updatePrefs(_prefs.copyWith(selectedReminderDays: newDays));
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF00635A) : const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      days[index],
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
