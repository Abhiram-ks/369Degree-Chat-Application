import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constant/app_image.dart';
import '../../../core/constant/resposive_size.dart';
import '../../../core/theme/app_colors.dart';
import '../blocs/bloc/splash_bloc/splash_bloc.dart';
import '../widget/splash_widget/handle_state.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SplashBloc()..add(SplashRequest()),
      child: BlocListener<SplashBloc, SplashState>(
        listener: (context, splashState) {
          splashStateHandle(context, splashState);
        },
        child: Scaffold(
          backgroundColor: AppPalette.green,
          body: ColoredBox(
            color: AppPalette.green,
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                AppImage.logo,
                                fit: BoxFit.contain,
                                height: 70,
                                width: 70,
                              ),
                              Constant.hight10(context),
                              Text(
                                '369Degree : WebChat',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: AppPalette.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 12,
                            width: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              backgroundColor: AppPalette.grey,
                              color: AppPalette.white,
                            ),
                          ),
                          Constant.width20(context),
                          Text(
                            "Loading",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppPalette.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Constant.hight30(context),
                      Text(
                        "Safely protect your valuable assets end-to-end encrypted",
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppPalette.white,
                        ),
                      ), Constant.hight30(context),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}