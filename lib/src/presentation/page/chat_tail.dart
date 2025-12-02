import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webchat/core/common/custom_appbar.dart';
import 'package:webchat/core/constant/app_constants.dart';
import 'package:webchat/src/presentation/blocs/bloc/get_store_user.dart/get_store_user_bloc.dart';
import 'package:webchat/src/presentation/widget/chat_tail_widget/user_avatar_widget.dart';

import '../../../core/common/custom_dialog_box.dart';
import '../../../core/theme/app_colors.dart';
import '../widget/chat_tail_widget/chat_tail_builder_widget.dart';

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
      key: const Key('chat_tail_scaffold'),
      appBar: CustomAppBar(
        key: const Key('chat_tail_appbar'),
        isTitle: true,
        title: 'Chat Application',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: UserAvatarWidget(
              key: const Key('user_avatar_widget'), //! For testing
              radius: 18,
              onTap: () {
                CustomCupertinoDialog.show(context: context, title: 'Current User', message:"This is your current user Profile. You can change or switch to a different user by selecting the user from the list.", text: 'Got It', color: AppPalette.blue);
              },
            ),
          ),
        ],
      ),
      body: const ChatTailBuilderWidget(key: Key('chat_tail_builder')),
    );
  }
}