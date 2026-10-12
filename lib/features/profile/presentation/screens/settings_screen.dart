import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fitness_app/core/constants/app_colors.dart';
import 'package:fitness_app/core/services/theme_service.dart';
import 'edit_profile_screen.dart';
import 'package:fitness_app/features/notifications/presentation/screens/notification_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeModeNotifier,
      builder: (context, themeMode, _) {
        final isDark = themeMode == ThemeMode.dark;
        final bgColor = isDark ? AppColors.darkBackground : const Color(0xFFFAFBFD);
        final cardBg = isDark ? AppColors.darkCardBackground : Colors.white;
        final textPrimary = isDark ? AppColors.darkTextPrimary : const Color(0xFF0F172A);
        final textSecondary = isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);
        final textMuted = isDark ? AppColors.darkTextMuted : const Color(0xFF94A3B8);

        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, textPrimary, isDark),
                  const SizedBox(height: 32),
                  _buildSectionHeader('ACCOUNT', textMuted),
                  const SizedBox(height: 12),
                  _buildSettingsCard(
                    iconWidget: const Icon(Icons.person, color: Color(0xFF0284C7), size: 26),
                    title: 'Edit Profile',
                    subtitle: 'Name, email, photo',
                    cardBg: cardBg,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    isDark: isDark,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader('PREFERENCES', textMuted),
                  const SizedBox(height: 12),
                  _buildSettingsCard(
                    iconWidget: Text(
                      isDark ? '🌙' : '☀️',
                      style: const TextStyle(fontSize: 22),
                    ),
                    title: 'Appearance',
                    subtitle: isDark ? 'Theme · Dark' : 'Theme · Light',
                    isSelected: true,
                    cardBg: cardBg,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    isDark: isDark,
                    onTap: () => _showAppearanceModal(context, isDark),
                  ),
                  const SizedBox(height: 12),
                  _buildSettingsCard(
                    iconWidget: const Text('🏋️', style: TextStyle(fontSize: 22)),
                    title: 'My Equipment',
                    subtitle: '3 items',
                    cardBg: cardBg,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    isDark: isDark,
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _buildSettingsCard(
                    iconWidget: const Text('🔔', style: TextStyle(fontSize: 22)),
                    title: 'Notifications',
                    subtitle: 'Reminders and alerts',
                    cardBg: cardBg,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    isDark: isDark,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationSettingsScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildSettingsCard(
                    iconWidget: const Text('📏', style: TextStyle(fontSize: 22)),
                    title: 'Units',
                    subtitle: 'kg / km',
                    cardBg: cardBg,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    isDark: isDark,
                    onTap: () {},
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader('SUPPORT', textMuted),
                  const SizedBox(height: 12),
                  _buildSettingsCard(
                    iconWidget: const Text('🔒', style: TextStyle(fontSize: 22)),
                    title: 'Privacy & Security',
                    cardBg: cardBg,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    isDark: isDark,
                    onTap: () {},
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, Color textPrimary, bool isDark) {
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
                size: 22,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          'Settings',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, Color textColor) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: textColor,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildSettingsCard({
    required Widget iconWidget,
    required String title,
    String? subtitle,
    bool isSelected = false,
    required Color cardBg,
    required Color textPrimary,
    required Color textSecondary,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final selectedBg = isDark
        ? const Color(0xFF0F2E28)
        : const Color(0xFFF0FDF4);
    final selectedBorder = isDark
        ? const Color(0xFF10B981)
        : const Color(0xFF00635A);
    final unselectedBorder = isDark
        ? const Color(0xFF334155)
        : Colors.transparent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? selectedBg : cardBg,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: selectedBorder, width: 1.5)
              : Border.all(color: unselectedBorder, width: 1.5),
          boxShadow: [
            if (!isSelected && !isDark)
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            iconWidget,
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? const Color(0xFF64748B) : const Color(0xFFCBD5E1),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  /// Theme Selection Bottom Sheet Modal
  void _showAppearanceModal(BuildContext context, bool isCurrentDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isDark = ThemeService.isDarkMode;
            final sheetBg = isDark ? const Color(0xFF1E293B) : Colors.white;
            final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
            final descColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
            final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFEDF2F7);

            return Container(
              decoration: BoxDecoration(
                color: sheetBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Appearance',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: titleColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Choose your preferred app theme',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: descColor,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(Icons.close_rounded, color: descColor),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Light Theme Option
                    _buildThemeOptionTile(
                      ctx: ctx,
                      title: 'Light Theme',
                      subtitle: 'Clean and bright look for daylight',
                      iconText: '☀️',
                      isSelected: !isDark,
                      isDark: isDark,
                      borderColor: borderColor,
                      titleColor: titleColor,
                      descColor: descColor,
                      onTap: () async {
                        await ThemeService.setThemeMode(ThemeMode.light);
                        setModalState(() {});
                      },
                    ),

                    const SizedBox(height: 12),

                    // Dark Theme Option
                    _buildThemeOptionTile(
                      ctx: ctx,
                      title: 'Dark Theme',
                      subtitle: 'Sleek slate interface, easier on the eyes',
                      iconText: '🌙',
                      isSelected: isDark,
                      isDark: isDark,
                      borderColor: borderColor,
                      titleColor: titleColor,
                      descColor: descColor,
                      onTap: () async {
                        await ThemeService.setThemeMode(ThemeMode.dark);
                        setModalState(() {});
                      },
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildThemeOptionTile({
    required BuildContext ctx,
    required String title,
    required String subtitle,
    required String iconText,
    required bool isSelected,
    required bool isDark,
    required Color borderColor,
    required Color titleColor,
    required Color descColor,
    required VoidCallback onTap,
  }) {
    final activeBorder = const Color(0xFF00635A);
    final activeBg = isDark
        ? const Color(0xFF0F2E28)
        : const Color(0xFFF0FDF4);
    final idleBg = isDark
        ? const Color(0xFF141E2E)
        : const Color(0xFFF8FAFC);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : idleBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? activeBorder : borderColor,
            width: isSelected ? 1.8 : 1.2,
          ),
        ),
        child: Row(
          children: [
            Text(iconText, style: const TextStyle(fontSize: 24)),
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
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: descColor,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? activeBorder : descColor,
                  width: 2,
                ),
                color: isSelected ? activeBorder : Colors.transparent,
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(Icons.check, size: 14, color: Colors.white),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
