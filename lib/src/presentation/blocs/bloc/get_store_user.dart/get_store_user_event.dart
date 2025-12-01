part of 'get_store_user_bloc.dart';

@immutable
abstract class GetStoreUserEvent {}

final class GetStoreUserRequest extends GetStoreUserEvent {
  final int? selectedUserId;
  GetStoreUserRequest({this.selectedUserId});
}
