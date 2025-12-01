part of 'select_user_cubit.dart';

@immutable
abstract class SelectUserState {}

final class SelectUserInitial extends SelectUserState {}

final class SelectUserSelected extends SelectUserState {
  final UserEntity user;
  SelectUserSelected({required this.user});
}
