import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(SplashInitial()) {
    on<SplashRequest>((event, emit) async {
      try {
        emit(SplashLoading());
        await Future.delayed(const Duration(seconds: 2));
        emit(SplashSuccess());
      } catch (e, _) {
        emit(SplashFailure(message: e.toString()));
      }
    });
  }
}
