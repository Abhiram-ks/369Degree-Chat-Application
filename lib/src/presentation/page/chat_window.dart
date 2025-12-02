import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webchat/core/di/di.dart';
import 'package:webchat/core/theme/app_colors.dart';
import 'package:webchat/src/domain/repo/websocket_repo.dart';
import 'package:webchat/src/presentation/blocs/bloc/get_single_user_bloc/get_single_user_bloc.dart';
import 'package:webchat/src/presentation/blocs/bloc/websocket_bloc/websocket_bloc.dart';
import 'package:webchat/src/presentation/blocs/bloc/message_bloc/message_bloc.dart';
import 'package:webchat/src/presentation/widget/chat_windows_widget/chat_bubles.dart';
import 'package:webchat/src/presentation/widget/chat_windows_widget/chat_window_text_style.dart';
import 'package:webchat/src/presentation/widget/chat_windows_widget/date_separator_widget.dart';
import '../../../core/common/custom_snckbar.dart';
import '../widget/chat_windows_widget/chat_appbar.dart';
import 'package:webchat/src/presentation/model/chat_message.dart';
import 'chat_window_logic.dart';

class ChatWindow extends StatelessWidget {
  final int userId;
  
  const ChatWindow({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<GetSingleUserBloc>()
            ..add(GetSingleUserRequest(userId: userId)),
        ),
        BlocProvider(
          create: (context) => sl<WebSocketBloc>(),
        ),
        BlocProvider(
          create: (context) => sl<MessageBloc>(),
        ),
      ],
      child: Builder(
        builder: (context) {
          return ChatWindowInitializer(userId: userId);
        },
      ),
    );
  }
}


class ChatWindowInitializer extends StatefulWidget {
  final int userId;
  const ChatWindowInitializer({super.key, required this.userId});

  @override
  State<ChatWindowInitializer> createState() => _ChatWindowInitializerState();
}

class _ChatWindowInitializerState extends State<ChatWindowInitializer> {
  final TextEditingController controller = TextEditingController();
  late final ChatWindowLogic _logic;

  @override
  void initState() {
    super.initState();
    _logic = ChatWindowLogic(
      context: context,
      userId: widget.userId,
      controller: controller,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _logic.initializeChat();
    });
  }

  @override
  void dispose() {
    _logic.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        return BlocConsumer<WebSocketBloc, WebSocketState>(
          listener: (context, wsState) {
            if (!mounted) return;
            
            if (wsState.connectionStatus == WebSocketConnectionStatus.disconnected) {
             CustomSnackBar.show(context, message: 'WebSocket disconnected');
            } else if (wsState.connectionStatus == WebSocketConnectionStatus.error) {
              debugPrint('❌ WebSocket error - UI should show error state');
            }
          },
          builder: (context, wsState) {
            return Scaffold(
              appBar: ChatAppBar(userId: widget.userId, screenWidth: screenWidth),
              body: ChatWindowBody(
                controller: controller,
                userId: widget.userId,
                onTextChanged: _logic.onTextChanged,
                onSendMessage: _logic.onSendMessage,
              ),
            );
          },
        );
      },
    );
  }
}

class ChatWindowBody extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onTextChanged;
  final Function() onSendMessage;
  final int userId;
  
  const ChatWindowBody({
    super.key,
    required this.controller,
    required this.userId,
    required this.onTextChanged,
    required this.onSendMessage,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessageBloc, MessageState>(
      builder: (context, msgState) {
        if (msgState is MessageLoading || msgState is MessageInitial) {
          return  Center(child: SizedBox(
            height: 15,
            width: 15,
            child: CircularProgressIndicator(
              color: AppPalette.hint,
              backgroundColor: AppPalette.blue,
              strokeWidth: 2, 
            ),
          ));
        } 
        
        if (msgState is MessageError) {
          return Center(child: Text('Error loading messages: ${msgState.message}'));
        }
        
        if (msgState is! MessageLoaded) {
            return  Center(child: SizedBox(
            height: 15,
            width: 15,
            child: CircularProgressIndicator(
              color: AppPalette.hint,
              backgroundColor: AppPalette.blue,
              strokeWidth: 2, 
            ),
          ));
        }
        
        return Column(
          children: [
            Expanded(
              child: MessageList(messages: msgState.messages, userId: userId),
            ),
            ChatWindowTextFiled(
              controller: controller,
              onTextChanged: onTextChanged,
              sendButton: onSendMessage,
            ),
          ],
        );
      },
    );
  }
}

class MessageList extends StatelessWidget {
  final List<ChatMessage> messages;
  final int userId;
  
  const MessageList({super.key, required this.messages, required this.userId});

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<Widget> items = [];
    String? lastDate;

    for (final chatMessage in messages) {
      try {
        final date = DateTime.parse(chatMessage.timestamp);
        final dateKey = '${date.year}-${date.month}-${date.day}';

        if (lastDate != dateKey) {
          items.add(DateSeparatorWidget(date: date));
          lastDate = dateKey;
        }
      } catch (_) {}

      items.add(
        MessageBubleWidget(
          message: chatMessage.message,
          time: chatMessage.formattedTime,
          docId: chatMessage.id,
          isCurrentUser: chatMessage.isCurrentUser,
          status: chatMessage.status,
        ),
      );
    }

    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: items.length,
      itemBuilder: (context, index) => items[items.length - 1 - index],
    );
  }
}
