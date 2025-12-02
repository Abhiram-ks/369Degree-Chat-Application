import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../blocs/bloc/splash_bloc/splash_bloc.dart';
import '../widget/splash_widget/handle_state.dart';
import '../widget/splash_widget/splash_screen_body_widget.dart';

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
        child: ColoredBox(
          color: AppPalette.blue,
          child: SafeArea(
            child: Scaffold(
              body: const SplashScreenBodyWIdget(),
            ),
          ),
        ),
      ),
    );
  }
}
