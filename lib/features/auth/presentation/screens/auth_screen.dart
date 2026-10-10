import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/fiton_logo.dart';
import '../../data/services/auth_service.dart';

/// Screen for User Authentication: Supports both "Log In" and "Create Account"
/// - When user creates an account -> navigates to "Set Up Your Profile" (profileSetup)
/// - When user logs in -> navigates to "Home" screen (mainNav with index 0)
class AuthScreen extends StatefulWidget {
  final bool initialIsSignUp;

  const AuthScreen({
    super.key,
    this.initialIsSignUp = false,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late bool _isSignUp;

  // Controllers
  final _nameController = TextEditingController(text: 'Alex');
  final _emailController = TextEditingController(text: 'alex@fiton.com');
  final _passwordController = TextEditingController(text: 'Password123!');
  final _confirmPasswordController = TextEditingController(text: 'Password123!');

  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _rememberMe = true;
  bool _agreeTerms = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isSignUp = widget.initialIsSignUp;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ── Handlers ──────────────────────────────────────────────────────────────

  Future<void> _handleAuthSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_isSignUp && !_agreeTerms) {
      _showErrorSnackBar('Please agree to the Terms of Service & Privacy Policy.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isSignUp) {
        // Create Account Flow
        final user = await AuthService.signUpWithEmail(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (!mounted) return;
        _showSuccessSnackBar('Account created successfully! Welcome, ${user.name} 👋');

        // Navigates to "Set Up Your Profile" page (Create My Plan)
        await Future.delayed(const Duration(milliseconds: 350));
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, AppRoutes.profileSetup);
      } else {
        // Log In Flow
        final user = await AuthService.signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (!mounted) return;
        _showSuccessSnackBar('Welcome back, ${user.name}! 🏋️');

        // Navigates directly to Home Page
        await Future.delayed(const Duration(milliseconds: 350));
        if (!mounted) return;
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.mainNav,
          arguments: 0, // Tab 0 is Home
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        _showErrorSnackBar(e.message ?? e.code);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Authentication error: ${e.toString().replaceAll("Exception: ", "")}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleSocialAuth(bool isGoogle) async {
    setState(() => _isLoading = true);
    try {
      if (isGoogle) {
        await AuthService.signInWithGoogle();
      } else {
        await AuthService.signInWithApple();
      }

      if (!mounted) return;
      _showSuccessSnackBar('Signed in successfully!');

      if (_isSignUp) {
        Navigator.pushReplacementNamed(context, AppRoutes.profileSetup);
      } else {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.mainNav,
          arguments: 0,
        );
      }
    } catch (e) {
      if (mounted) _showErrorSnackBar('Sign in failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: Colors.redAccent.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: AppColors.primaryTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background ambient soft glow
          Positioned(
            top: -60,
            right: -60,
            width: 240,
            height: 240,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFC8F3EA).withValues(alpha: 0.6),
                    AppColors.background.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 12.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Top App Bar / Navigation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (Navigator.canPop(context))
                          IconButton(
                            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                            onPressed: () => Navigator.pop(context),
                          )
                        else
                          const SizedBox(width: 48),
                        Text(
                          'WELCOME TO FITON',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Centered Brand Badge
                    const FitOnLogoBadge(
                      size: 64,
                      borderRadius: 18,
                      showAccentMark: false,
                    ),

                    const SizedBox(height: 14),

                    // Title
                    Text(
                      _isSignUp ? 'Create Your Account' : 'Welcome Back',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.6,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Subtitle
                    Text(
                      _isSignUp
                          ? 'Join the community and build your personalized plan.'
                          : 'Sign in to access your workouts, streaks, and progress.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 22),

                    // Segmented Tab Toggle: [ Log In ]  [ Create Account ]
                    _buildTabToggle(),

                    const SizedBox(height: 22),

                    // Form Inputs
                    if (_isSignUp) ...[
                      // Full Name
                      _buildTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        hint: 'e.g. Alex Morgan',
                        icon: Icons.person_outline_rounded,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Please enter your name';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Email Address
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      hint: 'alex@fiton.com',
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Please enter your email';
                        if (!val.contains('@') || !val.contains('.')) return 'Please enter a valid email';
                        return null;
                      },
                    ),

                    const SizedBox(height: 14),

                    // Password
                    _buildTextField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: '••••••••',
                      icon: Icons.lock_outline_rounded,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Please enter a password';
                        if (val.length < 6) return 'Password must be at least 6 characters';
                        return null;
                      },
                    ),

                    if (_isSignUp) ...[
                      const SizedBox(height: 14),
                      // Confirm Password
                      _buildTextField(
                        controller: _confirmPasswordController,
                        label: 'Confirm Password',
                        hint: '••••••••',
                        icon: Icons.lock_clock_outlined,
                        obscureText: _obscureConfirmPassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                            color: AppColors.textMuted,
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Please confirm your password';
                          if (val != _passwordController.text) return 'Passwords do not match';
                          return null;
                        },
                      ),
                    ],

                    const SizedBox(height: 10),

                    // Checkbox / Secondary Options Row
                    if (!_isSignUp)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: _rememberMe,
                                  activeColor: AppColors.primaryTeal,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  onChanged: (val) => setState(() => _rememberMe = val ?? true),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Remember me',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () {
                              _showSuccessSnackBar('Password reset link sent to ${_emailController.text}');
                            },
                            child: Text(
                              'Forgot Password?',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: AppColors.primaryTeal,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _agreeTerms,
                                activeColor: AppColors.primaryTeal,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                onChanged: (val) => setState(() => _agreeTerms = val ?? true),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'I agree to the FitOn Terms of Service and Privacy Policy.',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 20),

                    // Primary Action Button (Pill Button)
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryTeal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(27),
                          ),
                          elevation: 2,
                          shadowColor: AppColors.primaryTeal.withValues(alpha: 0.35),
                        ),
                        onPressed: _isLoading ? null : _handleAuthSubmit,
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.4,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _isSignUp ? 'Create Account & Continue' : 'Log In',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward_rounded, size: 18),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Divider: OR
                    Row(
                      children: [
                        const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14.0),
                          child: Text(
                            'OR CONTINUE WITH',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMuted,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Social Buttons Row
                    Row(
                      children: [
                        // Google
                        Expanded(
                          child: _buildSocialButton(
                            label: 'Google',
                            icon: Icons.g_mobiledata_rounded,
                            iconColor: const Color(0xFFEA4335),
                            onTap: () => _handleSocialAuth(true),
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Apple
                        Expanded(
                          child: _buildSocialButton(
                            label: 'Apple',
                            icon: Icons.apple_rounded,
                            iconColor: AppColors.textPrimary,
                            onTap: () => _handleSocialAuth(false),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Footer Switch Link
                    GestureDetector(
                      onTap: () => setState(() => _isSignUp = !_isSignUp),
                      child: RichText(
                        text: TextSpan(
                          text: _isSignUp
                              ? 'Already have an account? '
                              : 'Don\'t have an account? ',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            TextSpan(
                              text: _isSignUp ? 'Log In' : 'Create Account',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                color: AppColors.primaryTeal,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Sub-widgets ───────────────────────────────────────────────────────────

  Widget _buildTabToggle() {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF2F7),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          // Log In Tab
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isSignUp = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                decoration: BoxDecoration(
                  color: !_isSignUp ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: !_isSignUp
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Log In',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: !_isSignUp ? FontWeight.w700 : FontWeight.w600,
                    color: !_isSignUp ? AppColors.textPrimary : AppColors.textMuted,
                  ),
                ),
              ),
            ),
          ),
          // Create Account Tab
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isSignUp = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                decoration: BoxDecoration(
                  color: _isSignUp ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: _isSignUp
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Create Account',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: _isSignUp ? FontWeight.w700 : FontWeight.w600,
                    color: _isSignUp ? AppColors.textPrimary : AppColors.textMuted,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 6.0),
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14.5,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: AppColors.textMuted,
            ),
            prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primaryTeal, width: 1.8),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required String label,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
