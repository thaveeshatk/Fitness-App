import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../auth/data/services/auth_service.dart';

/// Confirmation dialog for permanently deleting user account and all personal data.
class DeleteAccountDialog extends StatefulWidget {
  const DeleteAccountDialog({super.key});

  /// Displays the Delete Account dialog
  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const DeleteAccountDialog(),
    );
  }

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  final TextEditingController _inputController = TextEditingController();
  bool _obscurePassword = true;
  bool _isDeleting = false;
  String? _errorMessage;
  bool _requiresPassword = false;

  @override
  void initState() {
    super.initState();
    _requiresPassword = AuthService.isPasswordAuthUser;
    _inputController.addListener(_onInputChanged);
  }

  void _onInputChanged() {
    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    } else {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _inputController.removeListener(_onInputChanged);
    _inputController.dispose();
    super.dispose();
  }

  bool get _isConfirmEnabled {
    if (_isDeleting) return false;
    final text = _inputController.text.trim();
    if (_requiresPassword) {
      return text.isNotEmpty;
    } else {
      return text.toUpperCase() == 'DELETE';
    }
  }

  Future<void> _handleDelete() async {
    if (!_isConfirmEnabled) return;

    setState(() {
      _isDeleting = true;
      _errorMessage = null;
    });

    final enteredInput = _inputController.text.trim();

    try {
      await AuthService.deleteAccount(
        password: _requiresPassword ? enteredInput : null,
      );

      if (!mounted) return;

      // Close the confirmation dialog
      Navigator.of(context).pop();

      // Show floating notification confirming deletion
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Your account and all associated data have been permanently deleted.',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4),
        ),
      );

      // Navigate to Welcome / Auth Screen and clear navigation stack
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.auth,
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _isDeleting = false;
        if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
          _errorMessage = 'Incorrect password. Please verify and try again.';
        } else if (e.code == 'requires-recent-login') {
          _requiresPassword = true;
          _errorMessage =
              'Recent sign-in required for security. Please enter your password to confirm.';
        } else {
          _errorMessage = e.message ?? 'Authentication error (${e.code}).';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isDeleting = false;
        _errorMessage = 'Failed to delete account: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeController.instance.isDarkMode;

    return Dialog(
      backgroundColor: AppColors.cardBackground,
      elevation: 16,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Warning Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF3B1212) : const Color(0xFFFEE2E2),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.delete_forever_rounded,
                        color: Color(0xFFDC2626),
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delete Account',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Permanent & Irreversible',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFDC2626),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Warning Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF281010) : const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? const Color(0xFF5C1B1B) : const Color(0xFFFECDD3),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFE11D48),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'This action cannot be undone. Once deleted, your account cannot be recovered.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFFFDA4AF) : const Color(0xFFBE123C),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Description of affected data
              Text(
                'The following user-specific data will be permanently erased:',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),

              // Data deletion breakdown card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF131B2A) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? const Color(0xFF243046) : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    _buildDataItem(
                      icon: Icons.person_outline_rounded,
                      label: 'Profile information, photo, and fitness preferences',
                    ),
                    const SizedBox(height: 8),
                    _buildDataItem(
                      icon: Icons.history_rounded,
                      label: 'Workout activity history and completed sessions',
                    ),
                    const SizedBox(height: 8),
                    _buildDataItem(
                      icon: Icons.show_chart_rounded,
                      label: 'Fitness progress metrics, streaks, and statistics',
                    ),
                    const SizedBox(height: 8),
                    _buildDataItem(
                      icon: Icons.calendar_month_outlined,
                      label: 'Weekly routines and scheduled plan completion data',
                    ),
                    const SizedBox(height: 8),
                    _buildDataItem(
                      icon: Icons.fitness_center_rounded,
                      label: 'Custom workouts and personalized circuits',
                    ),
                    const SizedBox(height: 8),
                    _buildDataItem(
                      icon: Icons.notifications_none_rounded,
                      label: 'Notification preferences and system alerts',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Explicit confirmation input section
              Text(
                _requiresPassword
                    ? 'Enter your account password to confirm:'
                    : 'Type DELETE to confirm permanent deletion:',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),

              TextField(
                controller: _inputController,
                obscureText: _requiresPassword && _obscurePassword,
                enabled: !_isDeleting,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: _requiresPassword ? 'Your current password' : 'Type DELETE',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    color: AppColors.textMuted,
                  ),
                  filled: true,
                  fillColor: AppColors.inputFill,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppColors.inputBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppColors.inputBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
                  ),
                  suffixIcon: _requiresPassword
                      ? IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        )
                      : null,
                ),
              ),

              // Error banner if any
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF351212) : const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFDC2626),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Action buttons: Cancel and Delete
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isDeleting ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        side: BorderSide(color: AppColors.border),
                        foregroundColor: AppColors.textSecondary,
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isConfirmEnabled ? _handleDelete : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        disabledBackgroundColor: isDark
                            ? const Color(0xFF451A1A)
                            : const Color(0xFFFCA5A5).withValues(alpha: 0.5),
                        foregroundColor: Colors.white,
                        disabledForegroundColor: Colors.white.withValues(alpha: 0.5),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isDeleting
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Deleting...',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              'Delete Account',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                              ),
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

  Widget _buildDataItem({required IconData icon, required String label}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFFEF4444)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
