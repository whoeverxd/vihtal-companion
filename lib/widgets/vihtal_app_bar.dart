import 'package:flutter/material.dart';

import '../theme.dart';

class VihtalAppBar extends StatelessWidget implements PreferredSizeWidget {
  const VihtalAppBar({
    super.key,
    this.leading,
    this.actions,
    this.backgroundColor,
  });

  final Widget? leading;
  final List<Widget>? actions;
  final Color? backgroundColor;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
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
      actions: actions,
    );
  }
}

