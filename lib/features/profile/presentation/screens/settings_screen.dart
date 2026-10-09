import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFD),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 32),
              _buildSectionHeader('ACCOUNT'),
              const SizedBox(height: 12),
              _buildSettingsCard(
                iconWidget: const Icon(Icons.person, color: Color(0xFF0284C7), size: 26),
                title: 'Edit Profile',
                subtitle: 'Name, email, photo',
                onTap: () {},
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('PREFERENCES'),
              const SizedBox(height: 12),
              _buildSettingsCard(
                iconWidget: const Text('🌙', style: TextStyle(fontSize: 22)),
                title: 'Appearance',
                subtitle: 'Theme · Light',
                isSelected: true,
                onTap: () {},
              ),
              const SizedBox(height: 12),
              _buildSettingsCard(
                iconWidget: const Text('🏋️', style: TextStyle(fontSize: 22)),
                title: 'My Equipment',
                subtitle: '3 items',
                onTap: () {},
              ),
              const SizedBox(height: 12),
              _buildSettingsCard(
                iconWidget: const Text('🔔', style: TextStyle(fontSize: 22)),
                title: 'Notifications',
                subtitle: 'Reminders and alerts',
                onTap: () {},
              ),
              const SizedBox(height: 12),
              _buildSettingsCard(
                iconWidget: const Text('📏', style: TextStyle(fontSize: 22)),
                title: 'Units',
                subtitle: 'kg / km',
                onTap: () {},
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('SUPPORT'),
              const SizedBox(height: 12),
              _buildSettingsCard(
                iconWidget: const Text('🔒', style: TextStyle(fontSize: 22)),
                title: 'Privacy & Security',
                onTap: () {},
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: Color(0xFFEEF2F7),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.chevron_left_rounded, color: Color(0xFF334155), size: 22),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          'Settings',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
      ],
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

  Widget _buildSettingsCard({
    required Widget iconWidget,
    required String title,
    String? subtitle,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0FDF4) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: const Color(0xFF00635A), width: 1.5)
              : Border.all(color: Colors.transparent, width: 1.5),
          boxShadow: [
            if (!isSelected)
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
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1), size: 20),
          ],
        ),
      ),
    );
  }
}
