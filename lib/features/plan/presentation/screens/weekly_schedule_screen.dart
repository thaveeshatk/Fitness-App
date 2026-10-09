import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fitness_app/features/plan/data/services/plan_service.dart';
import 'package:fitness_app/features/plan/presentation/screens/adaptive_dashboard_screen.dart';
import 'package:fitness_app/features/notifications/data/services/notification_service.dart';
import 'package:fitness_app/features/notifications/presentation/widgets/notification_bell.dart';

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
      hour: _isAm ? int.parse(_time.split(':')[0]) : (int.parse(_time.split(':')[0]) == 12 ? 12 : int.parse(_time.split(':')[0]) + 12),
      minute: int.parse(_time.split(':')[1]),
    );
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
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
    const tealColor = Color(0xFF006257);
    const bgLightColor = Color(0xFFF9F9FC); 

    return Scaffold(
      backgroundColor: bgLightColor,
      appBar: AppBar(
        backgroundColor: bgLightColor,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
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
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          const NotificationBell(),
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
                          color: const Color(0xFF1E293B),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Build a consistent home workout routine',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2F3F0),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.calendar_today, color: Color(0xFF006257), size: 22),
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
                          'Pace Yourself Gently',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2EBF5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_selectedDays.length} days/wk',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF234C7A),
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
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // segmented control
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
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
                                color: isSelected ? tealColor : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? tealColor : const Color(0xFFE2E8F0),
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
                                      color: isSelected ? Colors.white : const Color(0xFF64748B),
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
                      color: const Color(0xFFFDFBF7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, color: Color(0xFFD97706), size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Tuesdays, Thursdays, and Sundays are restorative rest days.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: const Color(0xFF64748B),
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Local time',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
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
                        color: const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: Color(0xFFE2EBF5),
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
                                    color: const Color(0xFF64748B),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  _time,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF1E293B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2EBF5),
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
                                        color: _isAm ? Colors.white : const Color(0xFF64748B),
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
                                        color: !_isAm ? Colors.white : const Color(0xFF64748B),
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
                      color: const Color(0xFF64748B),
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2F3F0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.notifications, color: tealColor, size: 20),
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
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE2F3F0),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _remindersEnabled ? 'Enabled' : 'Disabled',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: tealColor,
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
                                  color: const Color(0xFF64748B),
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
                              inactiveTrackColor: const Color(0xFFCBD5E1),
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
                color: const Color(0xFFEEF2F9),
                borderRadius: BorderRadius.circular(16),
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
                          color: const Color(0xFF64748B),
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
                    
                    if (!context.mounted) return;
                    
                    NotificationService.addNotification(
                      title: 'Adaptive Plan Updated',
                      message: 'Your weekly schedule has been optimized based on your preferences.',
                      category: 'adaptive_plan_update',
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Schedule Saved Successfully!')),
                    );
                    
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const AdaptiveDashboardScreen(),
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
  }

  Widget _buildOption(int index, String text) {
    bool isSelected = _selectedOptionIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onOptionTapped(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
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
                color: isSelected ? const Color(0xFF006257) : const Color(0xFF64748B),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickSuggestion(String title, String timeStr, bool am) {
    bool isSelected = _time == timeStr && _isAm == am;
    return Expanded(
      child: GestureDetector(
        onTap: () => _setQuickSuggestion(timeStr, am),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFD4F7F2) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? const Color(0xFF006257) : const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$timeStr ${am ? "AM" : "PM"}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: isSelected ? const Color(0xFF006257) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecapRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF006257), size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                ),
              ),
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
