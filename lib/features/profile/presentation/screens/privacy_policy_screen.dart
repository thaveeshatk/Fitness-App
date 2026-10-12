import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/theme_controller.dart';

/// Dedicated Privacy Policy Screen under Profile -> Settings -> Support
/// Matches existing app design language and dynamically supports Light and Dark modes.
class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedCategoryIndex = 0;

  final List<String> _categories = [
    'All Topics',
    'Collection',
    'Firebase & Auth',
    'Usage & Storage',
    'Security',
    'Sharing',
    'Your Rights',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeController.instance,
      builder: (context, _) {
        final isDark = ThemeController.instance.isDarkMode;

        final sections = _getPrivacySections();
        final filteredSections = sections.where((section) {
          final matchesCategory = _selectedCategoryIndex == 0 ||
              section.categoryIndex == _selectedCategoryIndex;
          final matchesSearch = _searchQuery.isEmpty ||
              section.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              section.summary.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              section.points.any(
                (p) => p.toLowerCase().contains(_searchQuery.toLowerCase()),
              );
          return matchesCategory && matchesSearch;
        }).toList();

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 20),
                  _buildHeroBanner(isDark),
                  const SizedBox(height: 20),
                  _buildSearchBar(isDark),
                  const SizedBox(height: 16),
                  _buildCategoryChips(isDark),
                  const SizedBox(height: 24),
                  if (filteredSections.isEmpty)
                    _buildEmptyState()
                  else
                    ...filteredSections.map(
                      (section) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildSectionCard(section, isDark),
                      ),
                    ),
                  const SizedBox(height: 12),
                  _buildContactCard(context, isDark),
                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
        );
      },
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
            decoration: BoxDecoration(
              color: AppColors.iconCircleBg,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.chevron_left_rounded,
                color: AppColors.iconCircleColor,
                size: 22,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Privacy Policy',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'FitOn Privacy & Transparency Guide',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.primaryTeal.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primaryTeal.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.verified_outlined,
                size: 13,
                color: AppColors.primaryTeal,
              ),
              const SizedBox(width: 4),
              Text(
                'Oct 2026',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryTeal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroBanner(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF0F3934), const Color(0xFF1E293B)]
              : [const Color(0xFFE6F4F1), const Color(0xFFF0FDF4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryTeal.withValues(alpha: isDark ? 0.4 : 0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryTeal,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryTeal.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.shield_rounded,
                    color: Colors.white,
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
                      'Your Fitness Data is Yours',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Commitment to Privacy & Security',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'We believe health and workout data is deeply personal. FitOn is engineered to safeguard your records with state-of-the-art cloud security, strict Firebase authentication, and zero third-party data selling.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              height: 1.5,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTrustPill('🛡️ No Ad Selling', isDark),
              _buildTrustPill('🔒 TLS & AES-256', isDark),
              _buildTrustPill('⚡ Firebase Secured', isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrustPill(String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AppColors.cardBorder,
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.inputBorder, width: 1),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) {
          setState(() {
            _searchQuery = val.trim();
          });
        },
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Search policy topics (e.g. Firebase, workouts)...',
          hintStyle: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: AppColors.textMuted,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 20,
            color: AppColors.textMuted,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildCategoryChips(bool isDark) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryTeal
                    : (isDark ? const Color(0xFF1E293B) : Colors.white),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryTeal
                      : AppColors.cardBorder,
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  _categories[index],
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionCard(_PrivacySection section, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: true,
            tilePadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            childrenPadding:
                const EdgeInsets.only(left: 16, right: 16, bottom: 18),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: section.badgeBgColor(isDark),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  section.icon,
                  color: section.badgeIconColor(isDark),
                  size: 22,
                ),
              ),
            ),
            title: Text(
              section.title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                section.summary,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            children: [
              const SizedBox(height: 6),
              Container(
                height: 1,
                color: AppColors.divider,
                margin: const EdgeInsets.only(bottom: 14),
              ),
              Text(
                section.detailedExplanation,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  height: 1.55,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 14),
              ...section.points.map(
                (point) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 4, right: 10),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: section.badgeIconColor(isDark),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          point,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            height: 1.45,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (section.highlightNote != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF243046)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: section.badgeIconColor(isDark).withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 18,
                        color: section.badgeIconColor(isDark),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          section.highlightNote!,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.badgeBgBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(
                    Icons.contact_support_rounded,
                    color: AppColors.badgeTextBlue,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Questions & Data Protection Office',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'If you have any questions, concerns, or requests regarding this Privacy Policy or your personal information, reach out to our privacy compliance team:',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(
                Icons.email_outlined,
                size: 16,
                color: AppColors.primaryTeal,
              ),
              const SizedBox(width: 8),
              SelectableText(
                'privacy@fitonapp.com',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryTeal,
                ),
              ),
              const Spacer(),
              Text(
                'Response within 48h',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 40,
            color: AppColors.primaryTeal,
          ),
          const SizedBox(height: 12),
          Text(
            'No matching privacy topics found',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try adjusting your search terms or selecting another category.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  List<_PrivacySection> _getPrivacySections() {
    return [
      _PrivacySection(
        categoryIndex: 1,
        title: '1. User Data Collection',
        summary: 'What types of data we gather to empower your workouts',
        icon: Icons.inventory_2_outlined,
        badgeBgColor: (dark) =>
            dark ? const Color(0xFF1E3A5F) : const Color(0xFFE0F2FE),
        badgeIconColor: (dark) =>
            dark ? const Color(0xFF93C5FD) : const Color(0xFF0284C7),
        detailedExplanation:
            'FitOn gathers only the necessary personal and fitness records essential for tracking workouts, calibrating personal achievements, and calculating health indicators.',
        points: [
          'Direct Information: Details provided by you when registering and setting up your fitness profile.',
          'Fitness Activity: Exercises performed, duration, sets, reps, weight logs, and calories burned.',
          'Application Diagnostics: Anonymous device type, crash logs, and OS version to maintain high stability.',
        ],
        highlightNote:
            'We strictly collect data on an opt-in basis through your explicit app actions.',
      ),
      _PrivacySection(
        categoryIndex: 2,
        title: '2. Firebase Authentication',
        summary: 'Industry-standard secure account credentials & sessions',
        icon: Icons.fingerprint_rounded,
        badgeBgColor: (dark) =>
            dark ? const Color(0xFF382A24) : const Color(0xFFFFEDD5),
        badgeIconColor: (dark) =>
            dark ? const Color(0xFFFDBA74) : const Color(0xFFEA580C),
        detailedExplanation:
            'Authentication is powered by Google Firebase Auth. We never see or store your raw account passwords in cleartext on our application servers.',
        points: [
          'User Identifiers (UID): Each user is assigned an anonymous, unique Firebase UID to safeguard database relations.',
          'Credential Encryption: Passwords and tokens are hashed and encrypted following Google Cloud security benchmarks.',
          'OAuth Integrations: When signing in via Google, only verified profile names and email addresses are securely transferred.',
          'Automatic Token Refresh: Session tokens rotate automatically to prevent replay and unauthorized hijacking attacks.',
        ],
        highlightNote:
            'Your password never touches our backend code and remains secured within Firebase Auth.',
      ),
      _PrivacySection(
        categoryIndex: 1,
        title: '3. Personal Profile Information',
        summary: 'Name, physical attributes, fitness goals & avatar',
        icon: Icons.person_pin_rounded,
        badgeBgColor: (dark) =>
            dark ? const Color(0xFF0F3934) : const Color(0xFFC8F3EA),
        badgeIconColor: (dark) =>
            dark ? const Color(0xFF5EEAD4) : const Color(0xFF006257),
        detailedExplanation:
            'Your profile details are utilized strictly to customize your app experience, compute accurate metabolic estimations, and suggest workout intensity.',
        points: [
          'Identity Attributes: Full name, profile avatar photo, and email address for identification.',
          'Biometrics & Body Metrics: Age, gender, height, and body weight for calculating BMI and calories burned.',
          'Fitness Preferences: Target goals (e.g. Strength, Weight Loss, Stamina), activity level, and preferred schedule.',
        ],
        highlightNote:
            'You can view or update all profile attributes anytime in Profile → Edit Profile.',
      ),
      _PrivacySection(
        categoryIndex: 3,
        title: '4. Workout & Fitness Progress Data',
        summary: 'Exercise history, personal records, calories & streaks',
        icon: Icons.fitness_center_rounded,
        badgeBgColor: (dark) =>
            dark ? const Color(0xFF0E3827) : const Color(0xFFDCFCE7),
        badgeIconColor: (dark) =>
            dark ? const Color(0xFF6EE7B7) : const Color(0xFF16A34A),
        detailedExplanation:
            'FitOn monitors your workout milestones, routine logs, set-by-set progression, and overall exercise consistency to keep you motivated.',
        points: [
          'Workout Logs: Routine names, exercises completed, rest intervals, sets, and rep counts.',
          'Performance Statistics: Total active minutes, completion streaks, and estimated calories burned per session.',
          'Custom Plans: Personalized workout routines and saved workout splits created by you.',
        ],
        highlightNote:
            'Workout history remains linked exclusively to your account and is never displayed publicly.',
      ),
      _PrivacySection(
        categoryIndex: 3,
        title: '5. How Data is Stored and Used',
        summary: 'Cloud Firestore database synchronization & feature delivery',
        icon: Icons.cloud_done_rounded,
        badgeBgColor: (dark) =>
            dark ? const Color(0xFF2E2640) : const Color(0xFFF3E8FF),
        badgeIconColor: (dark) =>
            dark ? const Color(0xFFC084FC) : const Color(0xFF9333EA),
        detailedExplanation:
            'Your data is stored in Google Cloud Firestore with real-time multi-device synchronization and offline-first cache architecture.',
        points: [
          'Cross-Device Synchronization: Access your workouts and profile across any supported device seamlessly.',
          'Streak & Progress Analytics: Compute real-time analytics, goal progress bars, and historical milestones.',
          'Notification Scheduling: Power personalized workout reminder alerts based on your configured notification settings.',
          'Local Offline Caching: Workout progress is preserved offline and automatically synced when reconnected.',
        ],
        highlightNote:
            'We strictly use your data for core app functionality and feature improvement.',
      ),
      _PrivacySection(
        categoryIndex: 4,
        title: '6. Data Security & Architecture',
        summary: 'Encryption in transit, at rest, and Firestore security rules',
        icon: Icons.lock_outline_rounded,
        badgeBgColor: (dark) =>
            dark ? const Color(0xFF3B2F2F) : const Color(0xFFFEE2E2),
        badgeIconColor: (dark) =>
            dark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626),
        detailedExplanation:
            'We implement multi-layered enterprise defense strategies to safeguard your records against unauthorized access or breaches.',
        points: [
          'TLS 1.3 Transport Security: All network communication between the app and cloud endpoints is encrypted using modern SSL/TLS.',
          'AES-256 Encryption at Rest: Google Cloud infrastructure encrypts all Firestore documents and media storage at rest.',
          'Granular Firestore Rules: Strict access control policies guarantee that each user can only read and write their own data.',
          'Zero Cleartext Secrets: API keys, certificates, and auth tokens are protected using secure environment variables.',
        ],
        highlightNote:
            'No other user or external party has permission to read or modify your private database records.',
      ),
      _PrivacySection(
        categoryIndex: 5,
        title: '7. Data Sharing & Third-Party Disclosure',
        summary: 'Zero data selling policy & minimal trusted infrastructure',
        icon: Icons.share_location_rounded,
        badgeBgColor: (dark) =>
            dark ? const Color(0xFF382A24) : const Color(0xFFFEF3C7),
        badgeIconColor: (dark) =>
            dark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
        detailedExplanation:
            'We maintain a transparent, strict zero-ad-broker policy. Your workout and biometric data will never be commercialized.',
        points: [
          'No Ad Monetization: We never sell, rent, license, or trade your personal data to ad networks, advertisers, or data brokers.',
          'Infrastructure Providers: Firebase and Google Cloud act strictly as data processors under enterprise privacy obligations.',
          'No Third-Party Trackers: FitOn does not bundle external behavioral trackers, ad beacons, or cross-app tracking SDKs.',
          'Legal Compulsion: Records are shared only when strictly demanded by binding court orders or statutory government requests.',
        ],
        highlightNote:
            'Your fitness data will NEVER be shared with third parties for commercial or promotional purposes.',
      ),
      _PrivacySection(
        categoryIndex: 6,
        title: '8. Users\' Privacy Rights & Controls',
        summary: 'Access, update, export, and complete account erasure',
        icon: Icons.gavel_rounded,
        badgeBgColor: (dark) =>
            dark ? const Color(0xFF1E3A5F) : const Color(0xFFE0E7FF),
        badgeIconColor: (dark) =>
            dark ? const Color(0xFF818CF8) : const Color(0xFF4F46E5),
        detailedExplanation:
            'In alignment with global privacy regulations (including GDPR & CCPA), FitOn provides full autonomy over your data.',
        points: [
          'Right to Rectify: Edit and correct your profile information anytime through the Edit Profile page.',
          'Right to Notification Control: Configure custom workout alert times, toggle categories, or mute all alerts in Settings.',
          'Right to Erasure (Forget Me): Request permanent deletion of your profile, authentication UID, and Firestore records.',
          'Right to Data Portability: Request an export of your fitness history and profile data in an accessible format.',
        ],
        highlightNote:
            'To exercise your rights or request full account erasure, email privacy@fitonapp.com.',
      ),
    ];
  }
}

class _PrivacySection {
  final int categoryIndex;
  final String title;
  final String summary;
  final IconData icon;
  final Color Function(bool isDark) badgeBgColor;
  final Color Function(bool isDark) badgeIconColor;
  final String detailedExplanation;
  final List<String> points;
  final String? highlightNote;

  const _PrivacySection({
    required this.categoryIndex,
    required this.title,
    required this.summary,
    required this.icon,
    required this.badgeBgColor,
    required this.badgeIconColor,
    required this.detailedExplanation,
    required this.points,
    this.highlightNote,
  });
}
