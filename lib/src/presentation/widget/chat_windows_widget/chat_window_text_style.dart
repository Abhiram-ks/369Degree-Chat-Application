import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webchat/src/domain/repo/websocket_repo.dart';

import '../../../../core/constant/resposive_size.dart';
import '../../../../core/theme/app_colors.dart';
import '../../blocs/bloc/websocket_bloc/websocket_bloc.dart';

class ChatWindowTextFiled extends StatefulWidget {
  const ChatWindowTextFiled({
    super.key,
    required this.controller,
    required this.sendButton,
    this.icon,
    this.isICon = true,
    this.onTextChanged,
  });

  final TextEditingController controller;
  final VoidCallback sendButton;
  final bool isICon;
  final IconData? icon;
  final Function(String)? onTextChanged;

  @override
  State<ChatWindowTextFiled> createState() => _ChatWindowTextFiledState();
}

class _ChatWindowTextFiledState extends State<ChatWindowTextFiled> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          color: AppPalette.white,
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    onChanged: widget.onTextChanged,
                    onSubmitted: (_) {
                      widget.sendButton();
                      _focusNode.unfocus();
                    },
                    decoration: InputDecoration(
                      hintText: "Type a message",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    textInputAction: TextInputAction.send,
                  ),
                ),
                Constant.width20(context),
                BlocBuilder<WebSocketBloc, WebSocketState>(
                  builder: (context, wsState) {
                    final isDisconnectedOrError = 
                        wsState.connectionStatus == WebSocketConnectionStatus.disconnected ||
                        wsState.connectionStatus == WebSocketConnectionStatus.error;
                    
                    final buttonColor = isDisconnectedOrError 
                        ? Colors.grey 
                        : AppPalette.blue;
                    
                    return GestureDetector(
                      onTap: () {
                        _focusNode.unfocus();
                        widget.sendButton();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: buttonColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.send, color: AppPalette.white),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
