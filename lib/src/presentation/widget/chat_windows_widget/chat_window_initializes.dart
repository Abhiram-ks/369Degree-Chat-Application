
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webchat/core/common/custom_snckbar.dart';
import 'package:webchat/src/presentation/blocs/bloc/websocket_bloc/websocket_bloc.dart';
import 'package:webchat/src/presentation/widget/chat_windows_widget/chat_appbar.dart';
import '../../../domain/repo/websocket_repo.dart';
import 'chat_window_body_widget.dart';
import 'chat_window_logic.dart';


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
            }
          },
          builder: (context, wsState) {
            return PopScope(
              canPop: true,
              onPopInvokedWithResult: (didPop, _) {
                if (didPop) {
                  FocusScope.of(context).unfocus();
                  controller.clear();
                }
              },
              child: Scaffold(
                appBar: ChatAppBar(
                  userId: widget.userId,
                  screenWidth: screenWidth,
                ),
                body: ChatWindowBody(
                  controller: controller,
                  userId: widget.userId,
                  onTextChanged: _logic.onTextChanged,
                  onSendMessage: _logic.onSendMessage,
                ),
              ),
            );
          },
        );
      },
    );
  }
}