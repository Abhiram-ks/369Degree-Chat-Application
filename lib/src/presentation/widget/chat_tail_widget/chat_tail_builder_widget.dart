

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webchat/core/constant/app_constants.dart';
import 'package:webchat/src/presentation/widget/chat_tail_widget/chat_custom_tail.dart';

import '../../../../core/common/custom_state_handle_widgets.dart';
import '../../../../core/constant/resposive_size.dart';
import '../../../../core/routers/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../domain/entity/user_entity.dart';
import '../../blocs/bloc/get_store_user.dart/get_store_user_bloc.dart';

class ChatTailBuilderWidget extends StatelessWidget {
  const ChatTailBuilderWidget({
    super.key,
  });


  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: const Key('chat_tail_refresh_indicator'),
      color: AppPalette.blue,
      backgroundColor: AppPalette.white,
      onRefresh: () async {
        context.read<GetStoreUserBloc>().add(GetStoreUserRequest(selectedUserId: AppConstants.selectedUserId));
      },
      child: BlocBuilder<GetStoreUserBloc, GetStoreUserState>(
        builder: (context, state) {
          if (state is GetStoreUserSuccess) {
            if (state.users.isEmpty) {
              return Container(
                key: const Key('no_users_found_widget'),
                child: CustomStateHandleWidgets.informationWidget(
                  message: 'No users found',
                  onTap: () {
                    context.read<GetStoreUserBloc>().add(GetStoreUserRequest(selectedUserId: AppConstants.selectedUserId));
                  },
                ),
              );
            }
            return ListView.separated(
              key: const Key('users_list_view'),
              itemCount: state.users.length,
              itemBuilder: (context, index) {
                final UserEntity user = state.users[index];
                return GestureDetector(
                  key: Key('user_tile_gesture_${user.id}'),
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.chatWindow, arguments: user.id);
                  },
                  child: ChatTile(
                    key: Key('chat_tile_${user.id}'),
                    user: user,
                ));
              },
              separatorBuilder: (context, index) {
                return Constant.hight10(context);
              },
            );
          } else if (state is GetStoreUserLoading) {
            return Container(
              key: const Key('loading_widget'),
              child: CustomStateHandleWidgets.loadingWidget(),
            );
          } else if (state is GetStoreUserFailure) {
            return Container(
              key: const Key('error_widget'),
              child: CustomStateHandleWidgets.informationWidget(
                message: state.message,
                onTap: () {
                  context.read<GetStoreUserBloc>().add(GetStoreUserRequest(selectedUserId: AppConstants.selectedUserId));
                },
              ),
            );
          }
          return const SizedBox(key: Key('initial_empty_widget'));
        },
      ),
    );
  }
}