import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../data/models/workout_model.dart';
import '../../data/repositories/workout_repository.dart';

import 'workout_detail_screen.dart';

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Filters State
  String _selectedCategory = 'Cardio';
  String _selectedDuration = '15-30m';
  String _selectedDifficulty = 'Intermediate';
  final Set<String> _selectedEquipment = {'None / Bodyweight'};

  late List<WorkoutModel> _allWorkouts;

  @override
  void initState() {
    super.initState();
    _allWorkouts = WorkoutRepository.getMockWorkouts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<WorkoutModel> get _filteredWorkouts {
    final query = _searchController.text.trim().toLowerCase();

    return _allWorkouts.where((workout) {
      // Search text match
      if (query.isNotEmpty) {
        final matchesQuery = workout.title.toLowerCase().contains(query) ||
            workout.coach.toLowerCase().contains(query) ||
            workout.subCategory.toLowerCase().contains(query) ||
            workout.category.toLowerCase().contains(query) ||
            workout.tags.any((t) => t.toLowerCase().contains(query));
        if (!matchesQuery) return false;
      }

      // Category match
      if (_selectedCategory.isNotEmpty && _selectedCategory != 'All') {
        if (!workout.category.toLowerCase().contains(_selectedCategory.toLowerCase())) {
          return false;
        }
      }

      // Difficulty match
      if (_selectedDifficulty.isNotEmpty && _selectedDifficulty != 'All') {
        if (workout.difficulty.toLowerCase() != _selectedDifficulty.toLowerCase()) {
          return false;
        }
      }

      // Duration match
      if (_selectedDuration.isNotEmpty) {
        if (_selectedDuration == '<15m' && workout.durationMinutes >= 15) return false;
        if (_selectedDuration == '15-30m' && (workout.durationMinutes < 15 || workout.durationMinutes > 30)) return false;
        if (_selectedDuration == '30-45m' && (workout.durationMinutes < 30 || workout.durationMinutes > 45)) return false;
        if (_selectedDuration == '45m+' && workout.durationMinutes < 45) return false;
      }

      // Equipment match: if user selected specific equipment filters, workout should match at least one
      if (_selectedEquipment.isNotEmpty) {
        final hasCommon = workout.equipment.any((e) => _selectedEquipment.contains(e));
        if (!hasCommon) return false;
      }

      return true;
    }).toList();
  }

  void _resetFilters() {
    setState(() {
      _selectedCategory = 'All';
      _selectedDuration = '';
      _selectedDifficulty = 'All';
      _selectedEquipment.clear();
      _searchController.clear();
    });
  }

  void _onPreviewTapped(WorkoutModel workout) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WorkoutDetailScreen(workout: workout),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final matches = _filteredWorkouts;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary, size: 24),
          onPressed: () {},
        ),
        title: Text(
          'SEARCH',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: 2.0,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: UserAvatar(radius: 17),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search workouts, routines...',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: const Icon(Icons.search, color: AppColors.primaryTeal),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, color: AppColors.textMuted, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 1. Category Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '1. CATEGORY',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '[Horizontal Pan: 5 Nodes]',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Category Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildCategoryChip('Cardio (14)', 'Cardio'),
                    _buildCategoryChip('Strength', 'Strength'),
                    _buildCategoryChip('HIIT', 'HIIT'),
                    _buildCategoryChip('Yoga', 'Yoga'),
                    _buildCategoryChip('Mobility', 'Mobility'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Large Filter Card matching Wireframe Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Duration Window
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '2. DURATION WINDOW',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2F1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.timer_outlined, size: 12, color: AppColors.primaryTeal),
                              const SizedBox(width: 4),
                              Text(
                                'ACTIVE: ${_selectedDuration.isEmpty ? "ANY" : _selectedDuration}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryTeal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildDurationChip('<15m')),
                        const SizedBox(width: 8),
                        Expanded(child: _buildDurationChip('15-30m')),
                        const SizedBox(width: 8),
                        Expanded(child: _buildDurationChip('30-45m')),
                        const SizedBox(width: 8),
                        Expanded(child: _buildDurationChip('45m+')),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Difficulty Level
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '3. DIFFICULTY LEVEL',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '[TRI-STATE]',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Expanded(child: _buildDifficultyOption('Beginner')),
                          Expanded(child: _buildDifficultyOption('Intermediate')),
                          Expanded(child: _buildDifficultyOption('Advanced')),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Equipment Required
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '4. EQUIPMENT REQUIRED',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '[${_selectedEquipment.length} OF 5 CHECKED]',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildEquipmentCheck('None / Bodyweight')),
                        const SizedBox(width: 12),
                        Expanded(child: _buildEquipmentCheck('Dumbbells')),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _buildEquipmentCheck('Resistance Bands')),
                        const SizedBox(width: 12),
                        Expanded(child: _buildEquipmentCheck('Kettlebell')),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _buildEquipmentCheck('Exercise Mat')),
                        const SizedBox(width: 12),
                        const Expanded(child: SizedBox()),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Matches Header
              Row(
                children: [
                  Text(
                    'Matches',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryTeal,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${matches.length} RESULTS',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _resetFilters,
                    child: Row(
                      children: [
                        const Icon(Icons.refresh_rounded, size: 14, color: AppColors.primaryTeal),
                        const SizedBox(width: 4),
                        Text(
                          'RESET',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryTeal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Match Cards List
              if (matches.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.search_off_rounded, size: 48, color: AppColors.textMuted),
                      const SizedBox(height: 12),
                      Text(
                        'No matching workouts found',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Try relaxing your filter criteria or clearing search keyword.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryTeal,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _resetFilters,
                        child: Text(
                          'Show All Workouts',
                          style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...matches.map((workout) => Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _buildWorkoutCard(workout),
                    )),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, String categoryKey) {
    final isSelected = _selectedCategory.toLowerCase() == categoryKey.toLowerCase();
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = isSelected ? 'All' : categoryKey;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryTeal : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildDurationChip(String label) {
    final isSelected = _selectedDuration == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDuration = isSelected ? '' : label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryTeal : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyOption(String label) {
    final isSelected = _selectedDifficulty == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDifficulty = label;
        });
      },
      child: Container(
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 14,
              color: isSelected ? AppColors.primaryTeal : AppColors.textMuted,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: isSelected ? AppColors.primaryTeal : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipmentCheck(String label) {
    final isChecked = _selectedEquipment.contains(label);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isChecked) {
            _selectedEquipment.remove(label);
          } else {
            _selectedEquipment.add(label);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: isChecked ? AppColors.primaryTeal : Colors.white,
                border: Border.all(color: isChecked ? AppColors.primaryTeal : Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
              ),
              child: isChecked ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: 11.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutCard(WorkoutModel workout) {
    return GestureDetector(
      onTap: () => _onPreviewTapped(workout),
      child: Container(
        padding: const EdgeInsets.all(14),
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
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    workout.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.fitness_center_rounded, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            workout.subCategory,
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.primaryTeal,
                              fontWeight: FontWeight.w800,
                              fontSize: 9,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F2F1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              workout.difficulty.toUpperCase(),
                              style: GoogleFonts.plusJakartaSans(
                                color: AppColors.primaryTeal,
                                fontWeight: FontWeight.w700,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        workout.title,
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${workout.coach} • ${workout.rating}★',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined, size: 14, color: AppColors.primaryTeal),
                          const SizedBox(width: 4),
                          Text(
                            '${workout.durationMinutes} min',
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.local_fire_department_outlined, size: 14, color: AppColors.primaryTeal),
                          const SizedBox(width: 4),
                          Text(
                            '~${workout.calories} kcal',
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                ...workout.tags.take(2).map((tag) => Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        tag,
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 9,
                        ),
                      ),
                    )),
                const Spacer(),
                GestureDetector(
                  onTap: () => _onPreviewTapped(workout),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryTeal,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Preview',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right, color: Colors.white, size: 14),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
