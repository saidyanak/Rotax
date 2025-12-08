import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class RotaxAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;

  const RotaxAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      child: AppBar(
        backgroundColor: AppColors.backgroundDark,
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: AppColors.textWhite),
                onPressed: () => Navigator.pop(context),
              )
            : Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Image.asset('assets/images/logo_1.png', fit: BoxFit.contain),
              ),
        leadingWidth: 60,
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.textWhite,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: actions,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
