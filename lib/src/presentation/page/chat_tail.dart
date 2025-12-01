import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocBuilder, ReadContext;
import 'package:webchat/core/common/custom_appbar.dart';
import 'package:webchat/core/constant/app_constants.dart';
import 'package:webchat/core/routers/app_routes.dart' show AppRoutes;
import 'package:webchat/src/presentation/blocs/bloc/get_store_user.dart/get_store_user_bloc.dart';
import 'package:webchat/src/presentation/widget/chat_tail_widget/chat_custom_tail.dart';
import 'package:webchat/src/presentation/widget/chat_tail_widget/user_avatar_widget.dart';

import '../../../core/constant/resposive_size.dart';
import '../../../core/theme/app_colors.dart';
import '../../domain/entity/user_entity.dart';

class ChatTail extends StatefulWidget {
  const ChatTail({super.key});

  @override
  State<ChatTail> createState() => _ChatTailState();
}

class _ChatTailState extends State<ChatTail> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<GetStoreUserBloc>().add(GetStoreUserRequest(selectedUserId: AppConstants.selectedUserId));
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        isTitle: true,
        title: 'Chat Application',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: UserAvatarWidget(
              radius: 18,
              onTap: () {
                // Add any action when avatar is tapped
              },
            ),
          ),
        ],
      ),
      body: ChatTailBuilderWidget(),
    );
  }
}

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
            return const Center(child: CircularProgressIndicator(
              color: AppPalette.white,
              backgroundColor: AppPalette.blue,
              strokeWidth: 2,
            ));
          } else if (state is GetStoreUserFailure) {
            return Center(child: Text(state.message));
          }
          return const SizedBox();
        },
      ),
    );
  }
}