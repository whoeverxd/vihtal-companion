import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';
import '../theme.dart';

class VihtalAppBar extends StatelessWidget implements PreferredSizeWidget {
  const VihtalAppBar({
    super.key,
    this.leading,
    this.actions,
    this.backgroundColor,
    this.showDonateAction = true,
    this.showNotificationAction = true,
    this.notificationCount = 0,
  });

  final Widget? leading;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final bool showDonateAction;
  final bool showNotificationAction;
  final int notificationCount;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final effectiveLeading =
        leading ??
        (showDonateAction
            ? IconButton(
                onPressed: () => context.push(AppRoutes.donate),
                icon: const Icon(
                  Icons.favorite_border_rounded,
                  color: AppColors.primary,
                ),
                tooltip: 'Donar',
              )
            : null);

    final effectiveActions = <Widget>[
      if (showNotificationAction)
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.textSecondary,
                ),
                tooltip: 'Notificaciones',
              ),
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$notificationCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      if (actions != null) ...actions!,
    ];

    return AppBar(
      backgroundColor: backgroundColor ?? AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: effectiveLeading,
      title: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => context.go(AppRoutes.home),
        child: Image.asset(
          'assets/isotipo.png',
          height: 28,
          fit: BoxFit.contain,
        ),
      ),
      actions: effectiveActions.isEmpty ? null : effectiveActions,
    );
  }
}
