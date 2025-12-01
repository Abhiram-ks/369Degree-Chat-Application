part of 'get_single_user_bloc.dart';

@immutable
abstract class GetSingleUserState {}

final class GetSingleUserInitial extends GetSingleUserState {}

final class GetSingleUserLoading extends GetSingleUserState {}

final class GetSingleUserSuccess extends GetSingleUserState {
  final UserEntity user;
  GetSingleUserSuccess({required this.user});
}

final class GetSingleUserFailure extends GetSingleUserState {
  final String message;
  GetSingleUserFailure({required this.message});
}