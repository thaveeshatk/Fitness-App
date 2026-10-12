import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../data/services/notification_service.dart';
import '../screens/notification_center_screen.dart';

/// Reusable Notification Bell widget that reactively listens to [NotificationService.unreadCountNotifier]
/// and shows a dynamic unread badge. Tapping opens the [NotificationCenterScreen].
class NotificationBell extends StatelessWidget {
  final Color? iconColor;
  final Color? badgeColor;
  final double size;
  final double iconSize;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool isDark;
  final bool showBadgeNumber;

  const NotificationBell({
    super.key,
    this.iconColor,
    this.badgeColor,
    this.size = 38.0,
    this.iconSize = 22.0,
    this.padding = EdgeInsets.zero,
    this.onTap,
    this.isDark = false,
    this.showBadgeNumber = true,
  });

  @override
  Widget build(BuildContext context) {
    final darkModeActive = isDark || ThemeController.instance.isDarkMode;
    final effectiveIconColor = iconColor ??
        (darkModeActive ? Colors.white : const Color(0xFF334155));
    final effectiveBadgeColor = badgeColor ?? const Color(0xFFFF3B30);

    return ValueListenableBuilder<int>(
      valueListenable: NotificationService.unreadCountNotifier,
      builder: (context, unreadCount, _) {
        return InkWell(
          borderRadius: BorderRadius.circular(size / 2),
          onTap: onTap ??
              () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const NotificationCenterScreen(),
                  ),
                );
              },
          child: Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            padding: padding,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Icon(
                  unreadCount > 0
                      ? Icons.notifications_rounded
                      : Icons.notifications_none_rounded,
                  color: effectiveIconColor,
                  size: iconSize,
                ),
                if (unreadCount > 0)
                  Positioned(
                    top: showBadgeNumber ? 1 : 4,
                    right: showBadgeNumber ? -2 : 4,
                    child: Container(
                      padding: showBadgeNumber
                          ? const EdgeInsets.symmetric(horizontal: 4, vertical: 1)
                          : EdgeInsets.zero,
                      constraints: BoxConstraints(
                        minWidth: showBadgeNumber ? 16 : 8,
                        minHeight: showBadgeNumber ? 16 : 8,
                      ),
                      decoration: BoxDecoration(
                        color: effectiveBadgeColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: darkModeActive ? const Color(0xFF0F172A) : Colors.white,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: effectiveBadgeColor.withValues(alpha: 0.4),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: showBadgeNumber
                          ? Center(
                              child: Text(
                                unreadCount > 9 ? '9+' : '$unreadCount',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  height: 1.1,
                                ),
                              ),
                            )
                          : null,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
