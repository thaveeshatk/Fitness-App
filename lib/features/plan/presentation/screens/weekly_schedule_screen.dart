import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fitness_app/core/constants/app_colors.dart';
import 'package:fitness_app/core/theme/theme_controller.dart';
import 'package:fitness_app/features/plan/data/services/plan_service.dart';
import 'package:fitness_app/features/plan/presentation/screens/adaptive_dashboard_screen.dart';
import 'package:fitness_app/features/notifications/presentation/widgets/notification_bell.dart';
import 'package:fitness_app/features/notifications/presentation/screens/notification_center_screen.dart';
import 'package:fitness_app/features/workouts/data/services/workout_audio_service.dart';

class WeeklyScheduleScreen extends StatefulWidget {
  const WeeklyScheduleScreen({super.key});

  @override
  State<WeeklyScheduleScreen> createState() => _WeeklyScheduleScreenState();
}

class _WeeklyScheduleScreenState extends State<WeeklyScheduleScreen> {
  int _selectedOptionIndex = 2; // custom by default when loading
  final List<String> _daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  Set<String> _selectedDays = {'Mon', 'Wed', 'Fri', 'Sat'};
  String _time = '07:00';
  bool _isAm = false; // false for PM
  bool _remindersEnabled = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final savedData = PlanService.getSavedSchedule();
    if (savedData['days'] != null) {
      _selectedDays = Set<String>.from(savedData['days']);
    }
    if (savedData['time'] != null) {
      _time = savedData['time'];
    }
    if (savedData['isAm'] != null) {
      _isAm = savedData['isAm'];
    }
    
    // Auto-select option index based on days
    if (_selectedDays.length == 3 && _selectedDays.containsAll({'Mon', 'Wed', 'Fri'})) {
      _selectedOptionIndex = 0;
    } else if (_selectedDays.length == 4 && _selectedDays.containsAll({'Mon', 'Wed', 'Fri', 'Sat'})) {
      _selectedOptionIndex = 1;
    } else {
      _selectedOptionIndex = 2; // Custom
    }
  }

  void _onDayTapped(String day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        _selectedDays.remove(day);
      } else {
        _selectedDays.add(day);
      }
      _selectedOptionIndex = 2; // custom
    });
  }

  void _onOptionTapped(int index) {
    setState(() {
      _selectedOptionIndex = index;
      if (index == 0) {
        _selectedDays = {'Mon', 'Wed', 'Fri'};
      } else if (index == 1) {
        _selectedDays = {'Mon', 'Wed', 'Fri', 'Sat'};
      }
    });
  }

  void _showTimePicker() async {
    final initialTime = TimeOfDay(
      hour: int.tryParse(_time.split(':')[0]) ?? 7,
      minute: int.tryParse(_time.split(':')[1]) ?? 0,
    );
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryTeal,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        int hour = pickedTime.hourOfPeriod;
        if (hour == 0) hour = 12;
        _time = '${hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
        _isAm = pickedTime.period == DayPeriod.am;
      });
    }
  }
  
  void _setQuickSuggestion(String time, bool isAm) {
    setState(() {
      _time = time;
      _isAm = isAm;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeController.instance,
      builder: (context, _) {
        final isDark = ThemeController.instance.isDarkMode;
        final tealColor = isDark ? const Color(0xFF14B8A6) : const Color(0xFF006257);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            centerTitle: false,
            titleSpacing: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: tealColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.show_chart, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 8),
                Text(
                  'Schedule',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            actions: [
              const NotificationBell(),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: tealColor,
                  child: const Icon(Icons.person, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reminders & Schedule',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Build a consistent home workout routine',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.featureTealBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.calendar_today, color: AppColors.featureTealIcon, size: 22),
                    )
                  ],
                ),
                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: tealColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.spa, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Consistency beats intensity',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Short, predictable sessions turn movement into an effortless daily ritual.',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Card 1
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowColor,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.calendar_today, color: tealColor, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Choose your workout days',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.badgeBgBlue,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_selectedDays.length} days/wk',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.badgeTextBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'We recommend 3-4 days per week for beginners.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // segmented control
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            _buildOption(0, '3 Days'),
                            _buildOption(1, '4 Days (Best)'),
                            _buildOption(2, 'Custom'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // days circles
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: _daysOfWeek.map((day) {
                          bool isSelected = _selectedDays.contains(day);
                          return GestureDetector(
                            onTap: () => _onDayTapped(day),
                            child: Column(
                              children: [
                                Container(
                                  width: 38,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: isSelected ? tealColor : AppColors.surfaceMuted,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected ? tealColor : AppColors.cardBorder,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        day,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                          color: isSelected ? Colors.white : AppColors.textSecondary,
                                        ),
                                      ),
                                      if (isSelected)
                                        Container(
                                          margin: const EdgeInsets.only(top: 2),
                                          width: 4,
                                          height: 4,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Info box
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2E2419) : const Color(0xFFFDFBF7),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isDark ? const Color(0xFF78350F) : const Color(0xFFFDE68A)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline, color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706), size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Tuesdays, Thursdays, and Sundays are restorative rest days.',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: isDark ? const Color(0xFFFDE68A) : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Card 2
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowColor,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.access_alarm, color: tealColor, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Daily reminder time',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Local time',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Time Selector Box
                      GestureDetector(
                        onTap: _showTimePicker,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.badgeBgBlue,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.nightlight_round, color: tealColor, size: 20),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'SCHEDULED AT',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textSecondary,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    Text(
                                      _time,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2EBF5),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => setState(() => _isAm = true),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: _isAm ? tealColor : Colors.transparent,
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        child: Text(
                                          'AM',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: _isAm ? Colors.white : AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => setState(() => _isAm = false),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: !_isAm ? tealColor : Colors.transparent,
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        child: Text(
                                          'PM',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: !_isAm ? Colors.white : AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Quick Suggestions',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildQuickSuggestion('Morning', '7:30', true),
                          const SizedBox(width: 8),
                          _buildQuickSuggestion('Afternoon', '12:30', false),
                          const SizedBox(width: 8),
                          _buildQuickSuggestion('Evening', '07:00', false),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Card 3
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowColor,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.featureTealBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.notifications, color: AppColors.featureTealIcon, size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Workout Reminders',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.featureTealBg,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    _remindersEnabled ? 'Enabled' : 'Disabled',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.featureTealIcon,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Receive an encouraging nudge 15 minutes before your scheduled workout time.',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Switch(
                                  value: _remindersEnabled,
                                  onChanged: (val) => setState(() => _remindersEnabled = val),
                                  activeThumbColor: Colors.white,
                                  activeTrackColor: tealColor,
                                  inactiveThumbColor: Colors.white,
                                  inactiveTrackColor: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Card 4 - Routine Recap
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceMuted : const Color(0xFFEEF2F9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.checklist, color: tealColor, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                'ROUTINE RECAP',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: tealColor,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Ready to start',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildRecapRow(
                        Icons.calendar_month,
                        'Selected frequency',
                        '${_selectedDays.length} workouts/week (${_selectedDays.join(", ")})',
                      ),
                      const SizedBox(height: 12),
                      _buildRecapRow(
                        Icons.access_time,
                        'Scheduled trigger',
                        '$_time ${_isAm ? "AM" : "PM"} with 15-min prep reminder',
                      ),
                      const SizedBox(height: 12),
                      _buildRecapRow(
                        Icons.pie_chart_outline,
                        'Estimated weekly commitment',
                        '1h 20m (~20 min / session)',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tealColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _isLoading ? null : () async {
                      setState(() => _isLoading = true);
                      
                      try {
                        await PlanService.saveSchedule(_selectedDays, _time, _isAm);
                        
                        // Play notification chime sound
                        WorkoutAudioService.playFinishChime();

                        if (!context.mounted) return;

                        // Show interactive in-app notification dialog
                        await showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (dialogCtx) => Dialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 26.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF0F766E).withValues(alpha: 0.25)
                                          : const Color(0xFFE6F4F1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.notifications_active_rounded,
                                      color: tealColor,
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF064E3B) : const Color(0xFFDCFCE7),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 14),
                                        const SizedBox(width: 5),
                                        Text(
                                          'Notification Sent',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF16A34A),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    'Schedule Saved & Notification Sent! 🔔',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 17.5,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Your workouts are scheduled for ${_selectedDays.join(", ")} at $_time ${_isAm ? "AM" : "PM"}.\n\nA new reminder has been dispatched to your Notification Center.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 22),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 48,
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: tealColor,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                        elevation: 0,
                                      ),
                                      onPressed: () {
                                        Navigator.of(dialogCtx).pop();
                                        Navigator.of(context).push(
                                          MaterialPageRoute(builder: (_) => const NotificationCenterScreen()),
                                        );
                                      },
                                      icon: const Icon(Icons.notifications_rounded, color: Colors.white, size: 18),
                                      label: Text(
                                        'View in Notification Center 🔔',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13.5,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(dialogCtx).pop();
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(builder: (_) => const AdaptiveDashboardScreen()),
                                      );
                                    },
                                    child: Text(
                                      'Back to Dashboard',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      } finally {
                        if (mounted) setState(() => _isLoading = false);
                      }
                    },
                    child: _isLoading 
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Save Schedule',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Sync Button
                Center(
                  child: TextButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.sync, color: tealColor, size: 18),
                    label: Text(
                      'Sync with Apple Health / Google Calendar',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: tealColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOption(int index, String text) {
    bool isSelected = _selectedOptionIndex == index;
    final isDark = ThemeController.instance.isDarkMode;
    final tealColor = isDark ? const Color(0xFF14B8A6) : const Color(0xFF006257);

    return Expanded(
      child: GestureDetector(
        onTap: () => _onOptionTapped(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? AppColors.darkCardBackground : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.shadowColor,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? tealColor : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickSuggestion(String title, String timeStr, bool am) {
    bool isSelected = _time == timeStr && _isAm == am;
    final isDark = ThemeController.instance.isDarkMode;
    final tealColor = isDark ? const Color(0xFF14B8A6) : const Color(0xFF006257);

    return Expanded(
      child: GestureDetector(
        onTap: () => _setQuickSuggestion(timeStr, am),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF0F3934) : const Color(0xFFD4F7F2))
                : AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? tealColor : Colors.transparent,
            ),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? tealColor : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$timeStr ${am ? "AM" : "PM"}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: isSelected ? tealColor : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecapRow(IconData icon, String title, String value) {
    final isDark = ThemeController.instance.isDarkMode;
    final tealColor = isDark ? const Color(0xFF14B8A6) : const Color(0xFF006257);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: tealColor, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
