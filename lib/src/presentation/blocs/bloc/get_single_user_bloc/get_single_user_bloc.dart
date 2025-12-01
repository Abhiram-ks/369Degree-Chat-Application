import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import '../../../../domain/entity/user_entity.dart';
import '../../../../domain/usecase/get_single_user_usecase.dart';

part 'get_single_user_event.dart';
part 'get_single_user_state.dart';

class GetSingleUserBloc extends Bloc<GetSingleUserEvent, GetSingleUserState> {
  final GetSingleUserUsecase _getSingleUserUsecase;
  GetSingleUserBloc({required GetSingleUserUsecase getSingleUserUsecase}) : _getSingleUserUsecase = getSingleUserUsecase, super(GetSingleUserInitial()) {
    on<GetSingleUserRequest>((event, emit) async {
      emit(GetSingleUserLoading());
      try {
        final user = await _getSingleUserUsecase.call(event.userId);
        emit(GetSingleUserSuccess(user: user));
      } catch (e) {
        emit(GetSingleUserFailure(message: e.toString()));
      }
    });
  }
}
