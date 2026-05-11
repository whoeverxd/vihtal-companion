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
  });

  final Widget? leading;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final bool showDonateAction;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final effectiveActions = <Widget>[
      if (actions != null) ...actions!,
      if (showDonateAction)
        IconButton(
          onPressed: () => context.push(AppRoutes.donate),
          icon: const Icon(Icons.favorite_border_rounded, color: AppColors.primary),
          tooltip: 'Donar',
        ),
    ];

    return AppBar(
      backgroundColor: backgroundColor ?? AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: leading,
      title: Image.asset(
        'assets/isotipo.png',
        height: 28,
        fit: BoxFit.contain,
      ),
      actions: effectiveActions.isEmpty ? null : effectiveActions,
    );
  }
}
