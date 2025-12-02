
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import '../../../../domain/entity/user_entity.dart';
import '../../../../domain/usecase/user_usecase/get_usercase.dart';
import '../../../../data/datasource/local/store_user_local_datasource.dart';
import '../../../../data/model/user_model.dart';
part 'get_store_user_event.dart';
part 'get_store_user_state.dart';

class GetStoreUserBloc extends Bloc<GetStoreUserEvent, GetStoreUserState> {
  final GetUserUsecase _getUserUsecase;
  final StoreUserLocalDataSource _localDataSource;
  int? selectedUserId;

  GetStoreUserBloc({
    required GetUserUsecase getUserUsecase,
    required StoreUserLocalDataSource localDataSource,
  }) : _getUserUsecase = getUserUsecase,
       _localDataSource = localDataSource,
       super(GetStoreUserInitial()) {
    on<GetStoreUserRequest>((event, emit) async {
      selectedUserId = event.selectedUserId;
      emit(GetStoreUserLoading());

      try {
        final localUsers = await _localDataSource.getAllUsers();

        if (localUsers.isNotEmpty) {
          if (event.selectedUserId != null) {
            final filteredUsers = localUsers
                .where((user) => user.id != event.selectedUserId)
                .toList();
            emit(GetStoreUserSuccess(users: filteredUsers));
          } else {
            emit(GetStoreUserSuccess(users: localUsers));
          }
        } else {
          final remoteUsers = await _getUserUsecase.call();

          if (remoteUsers.isNotEmpty) {
            final userModels = remoteUsers.map((user) {
              return UserModel(
                id: user.id,
                fullName: user.fullName,
                email: user.email,
                avatarUrl: user.avatarUrl,
              );
            }).toList();

            await _localDataSource.storeUsers(userModels);
            if (event.selectedUserId != null) {
              final filteredUsers = remoteUsers
                  .where((user) => user.id != event.selectedUserId)
                  .toList();
              emit(GetStoreUserSuccess(users: filteredUsers));
            } else {
              emit(GetStoreUserSuccess(users: remoteUsers));
            }
          } else {
            emit(GetStoreUserFailure(message: 'No users found'));
          }
        }
      } catch (e, _) {
        emit(GetStoreUserFailure(message: e.toString()));
      }
    });
  }
}
