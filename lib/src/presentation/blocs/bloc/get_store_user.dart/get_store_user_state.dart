part of 'get_store_user_bloc.dart';

@immutable
abstract class GetStoreUserState {}

final class GetStoreUserInitial extends GetStoreUserState {}
final class GetStoreUserLoading extends GetStoreUserState {}
final class GetStoreUserSuccess extends GetStoreUserState {
  final List<UserEntity> users;
  GetStoreUserSuccess({required this.users});
}
final class GetStoreUserFailure extends GetStoreUserState {
  final String message;
  GetStoreUserFailure({required this.message});
}

