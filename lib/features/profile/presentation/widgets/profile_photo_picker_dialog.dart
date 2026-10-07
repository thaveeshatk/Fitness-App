import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/data/services/auth_service.dart';

/// Modal bottom sheet for choosing or entering a new profile picture.
class ProfilePhotoPickerDialog extends StatefulWidget {
  const ProfilePhotoPickerDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ProfilePhotoPickerDialog(),
    );
  }

  @override
  State<ProfilePhotoPickerDialog> createState() => _ProfilePhotoPickerDialogState();
}

class _ProfilePhotoPickerDialogState extends State<ProfilePhotoPickerDialog> {
  late String _selectedUrl;
  final TextEditingController _urlController = TextEditingController();
  bool _isCustomUrl = false;

  @override
  void initState() {
    super.initState();
    _selectedUrl = AuthService.currentUser.photoUrl ?? AuthService.presetAvatars.first;
    _urlController.text = _selectedUrl;
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _savePhoto() async {
    final finalUrl = _isCustomUrl ? _urlController.text.trim() : _selectedUrl;
    if (finalUrl.isEmpty) return;

    await AuthService.updateProfilePhoto(finalUrl);

    if (!mounted) return;
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Profile picture updated successfully! ✨',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 24 + bottomInset,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
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
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Title & Subtitle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Update Profile Picture',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          Text(
            'Choose from our preset fitness avatars or enter your custom image URL.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF64748B),
            ),
          ),

          const SizedBox(height: 20),

          // Selected Avatar Preview
          Center(
            child: Stack(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryTeal, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryTeal.withValues(alpha: 0.25),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.network(
                      _isCustomUrl ? _urlController.text.trim() : _selectedUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFF005953),
                        child: const Center(
                          child: Icon(Icons.person, color: Colors.white, size: 44),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryTeal,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Presets Grid
          Text(
            'Choose an Avatar',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 64,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: AuthService.presetAvatars.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final url = AuthService.presetAvatars[index];
                final isSelected = !_isCustomUrl && _selectedUrl == url;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _isCustomUrl = false;
                      _selectedUrl = url;
                      _urlController.text = url;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.primaryTeal : const Color(0xFFE2E8F0),
                        width: isSelected ? 3 : 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primaryTeal.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : [],
                    ),
                    child: ClipOval(
                      child: Image.network(
                        url,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.person),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 18),

          // Custom URL Input
          Text(
            'Or Enter Image URL',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _urlController,
                  onChanged: (val) {
                    setState(() {
                      _isCustomUrl = true;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'https://...',
                    prefixIcon: const Icon(Icons.link_rounded, size: 20, color: Color(0xFF64748B)),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.primaryTeal, width: 1.5),
                    ),
                  ),
                  style: GoogleFonts.plusJakartaSans(fontSize: 13),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isCustomUrl = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEEF5FF),
                  foregroundColor: const Color(0xFF0F172A),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Preview'),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // Apply / Save Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _savePhoto,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                elevation: 2,
                shadowColor: AppColors.primaryTeal.withValues(alpha: 0.3),
              ),
              child: Text(
                'Save Profile Picture',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
