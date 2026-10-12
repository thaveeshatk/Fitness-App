import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../features/auth/data/models/auth_user.dart';
import '../../features/auth/data/services/auth_service.dart';

/// Reusable user avatar widget that reactively listens to [AuthService.userNotifier]
/// to update instantly across all app screens when the user changes their photo.
class UserAvatar extends StatelessWidget {
  final double radius;
  final VoidCallback? onTap;
  final bool showEditBadge;
  final Border? border;

  const UserAvatar({
    super.key,
    this.radius = 18,
    this.onTap,
    this.showEditBadge = false,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ValueListenableBuilder<AuthUser?>(
      valueListenable: AuthService.userNotifier,
      builder: (context, user, _) {
        final photoUrl = user?.photoUrl ??
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=250&auto=format&fit=crop';

        final avatar = Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: border ?? Border.all(color: isDark ? const Color(0xFF334155) : Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.network(
              photoUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFF005953),
                child: Center(
                  child: Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: radius * 1.1,
                  ),
                ),
              ),
            ),
          ),
        );

        if (!showEditBadge && onTap == null) {
          return avatar;
        }

        return GestureDetector(
          onTap: onTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              avatar,
              if (showEditBadge)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: radius * 0.72,
                    height: radius * 0.72,
                    decoration: BoxDecoration(
                      color: AppColors.primaryTeal,
                      shape: BoxShape.circle,
                      border: Border.all(color: isDark ? const Color(0xFF1E293B) : Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryTeal.withValues(alpha: 0.35),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      size: radius * 0.42,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
