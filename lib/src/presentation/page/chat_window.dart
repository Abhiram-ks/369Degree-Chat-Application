import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webchat/core/di/di.dart';
import 'package:webchat/src/presentation/blocs/bloc/get_single_user_bloc/get_single_user_bloc.dart';
import 'package:webchat/src/presentation/blocs/bloc/websocket_bloc/websocket_bloc.dart';
import 'package:webchat/src/presentation/blocs/bloc/message_bloc/message_bloc.dart';
import 'package:webchat/src/presentation/widget/chat_windows_widget/chat_window_initializes.dart';

class ChatWindow extends StatelessWidget {
  final int userId;

  const ChatWindow({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              sl<GetSingleUserBloc>()
                ..add(GetSingleUserRequest(userId: userId)),
        ),
        BlocProvider(create: (context) => sl<WebSocketBloc>()),
        BlocProvider(create: (context) => sl<MessageBloc>()),
      ],
      child: ChatWindowInitializer(userId: userId),
    );
  }
}
