part of 'get_single_user_bloc.dart';

@immutable
abstract class GetSingleUserEvent {}

final class GetSingleUserRequest extends GetSingleUserEvent {
  final int userId;
  GetSingleUserRequest({required this.userId});
}