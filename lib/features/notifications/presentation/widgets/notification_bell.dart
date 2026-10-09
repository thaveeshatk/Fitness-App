import 'package:flutter/material.dart';
import '../../data/services/notification_service.dart';
import '../screens/notification_center_screen.dart';

class NotificationBell extends StatelessWidget {
  final Color iconColor;
  final double size;

  const NotificationBell({
    super.key,
    this.iconColor = const Color(0xFF334155),
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NotificationCenterScreen()),
        );
      },
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Icon(Icons.notifications_none_rounded, color: iconColor, size: size),
          ValueListenableBuilder<int>(
            valueListenable: NotificationService.unreadCountNotifier,
            builder: (context, unreadCount, child) {
              if (unreadCount == 0) return const SizedBox.shrink();
              return Positioned(
                right: 2,
                top: 2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    unreadCount > 9 ? '9+' : unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
