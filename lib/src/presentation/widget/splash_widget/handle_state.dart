import 'package:flutter/material.dart';

import '../../../../core/routers/app_routes.dart';
import '../../blocs/bloc/splash_bloc/splash_bloc.dart';

void splashStateHandle(BuildContext context, SplashState state) {
  switch (state) {
    case SplashSuccess():
     Navigator.pushReplacementNamed(context, AppRoutes.selectUsers);
    case SplashFailure():
     Center(child: Text(state.message));
  }
}