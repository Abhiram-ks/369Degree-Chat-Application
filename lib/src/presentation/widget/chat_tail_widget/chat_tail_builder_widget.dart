

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
      color: AppPalette.blue,
      backgroundColor: AppPalette.white,
      onRefresh: () async {
        context.read<GetStoreUserBloc>().add(GetStoreUserRequest(selectedUserId: AppConstants.selectedUserId));
      },
      child: BlocBuilder<GetStoreUserBloc, GetStoreUserState>(
        builder: (context, state) {
          if (state is GetStoreUserSuccess) {
            if (state.users.isEmpty) {
              return CustomStateHandleWidgets.informationWidget(
                message: 'No users found',
                onTap: () {
                  context.read<GetStoreUserBloc>().add(GetStoreUserRequest(selectedUserId: AppConstants.selectedUserId));
                },
              );
            }
            return ListView.separated(
              itemCount: state.users.length,
              itemBuilder: (context, index) {
                final UserEntity user = state.users[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.chatWindow, arguments: user.id);
                  },
                  child: ChatTile(
                  user: user,
                ));
              },
              separatorBuilder: (context, index) {
                return Constant.hight10(context);
              },
            );
          } else if (state is GetStoreUserLoading) {
            return CustomStateHandleWidgets.loadingWidget();
          } else if (state is GetStoreUserFailure) {
            return CustomStateHandleWidgets.informationWidget(
              message: state.message,
              onTap: () {
                context.read<GetStoreUserBloc>().add(GetStoreUserRequest(selectedUserId: AppConstants.selectedUserId));
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}