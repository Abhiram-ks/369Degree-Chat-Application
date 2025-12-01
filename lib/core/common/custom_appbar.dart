import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize;
  final String? title;
  final Color? backgroundColor;
  final bool? isTitle;
  final Color? titleColor;
  final Color? iconColor;
  final List<Widget>? actions;
  const CustomAppBar({
    super.key,
    this.title,
    this.backgroundColor,
    this.titleColor,
    this.iconColor,
    this.isTitle = false,
    this.actions,
  }) : preferredSize = const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: isTitle == true
          ? Text(
              title!,
              style: GoogleFonts.poppins(
                color: titleColor ?? Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            )
          : null,
      backgroundColor: Colors.transparent,
      iconTheme: IconThemeData(color: iconColor ?? AppPalette.black),
      elevation: 0,
      scrolledUnderElevation: 0,
      shadowColor: Colors.black,
      actions: actions,
    );
  }
}
