
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constant/app_image.dart';
import '../../../../core/constant/resposive_size.dart';
import '../../../../core/theme/app_colors.dart';

class SplashScreenBodyWIdget extends StatelessWidget {
  const SplashScreenBodyWIdget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          mainAxisAlignment: .spaceBetween,
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: .min,
                  children: [
                    Image.asset(
                      AppImage.logo,
                      fit: .contain,
                      height: 80,
                      width: 80,
                    ),
                    Constant.hight10(context),
                    Text(
                      '369Degree : WebChat',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppPalette.blue,
                        fontWeight: .bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: .center,
              children: [
                SizedBox(
                  height: 12,
                  width: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    backgroundColor: AppPalette.blue,
                    color: AppPalette.hint,
                  ),
                ),
                Constant.width20(context),
                Text(
                  "Loading",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppPalette.blue,
                    fontWeight: .bold,
                  ),
                ),
              ],
            ),
            Constant.hight30(context),
            Text(
              "Safely protect your valuable assets end-to-end encrypted",
              style: GoogleFonts.poppins(
                fontSize: 8,
                color: AppPalette.blue,
              ),
            ), Constant.hight30(context),
          ],
        );
      },
    );
  }
}