import 'package:flutter/material.dart';
import 'package:codeshield/core/app_assets.dart';

class MenuAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MenuAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.maybePop(context),
        icon: Image.asset(AppIcons.back, filterQuality: FilterQuality.none),
      ),
      title: Image.asset(AppImages.logo, height: 40),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
