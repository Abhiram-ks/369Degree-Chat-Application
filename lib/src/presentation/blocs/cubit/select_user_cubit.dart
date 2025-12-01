import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entity/user_entity.dart';
part 'select_user_state.dart';

class SelectUserCubit extends Cubit<SelectUserState> {
  SelectUserCubit() : super(SelectUserInitial());

  void selectUser(UserEntity user) {
    emit(SelectUserSelected(user: user));
  }

  void deselectUser() {
    emit(SelectUserInitial());
  }

  void toggleUser(UserEntity user) {
    if (state is SelectUserSelected) {
      final currentState = state as SelectUserSelected;
      if (currentState.user.id == user.id) {
        deselectUser();
      } else {
        selectUser(user);
      }
    } else {
      selectUser(user);
    }
  }
}
