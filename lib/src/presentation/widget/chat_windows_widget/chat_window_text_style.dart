
import 'package:flutter/material.dart';

import '../../../../core/constant/resposive_size.dart';
import '../../../../core/theme/app_colors.dart';

class ChatWindowTextFiled extends StatelessWidget {
  const ChatWindowTextFiled({
    super.key,
    required TextEditingController controller,
    required this.sendButton,
    this.icon,
    this.isICon = true,
    this.onTextChanged,
  }) : _controller = controller;

  final TextEditingController _controller;
  final VoidCallback sendButton;
  final bool isICon;
  final IconData? icon;
  final Function(String)? onTextChanged;

  @override
  Widget build(BuildContext context) {
    final focusNode = FocusNode();


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
                    controller: _controller,
                    focusNode: focusNode,
                    onChanged: onTextChanged,
                    onSubmitted: (_) => sendButton(),
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
                GestureDetector(
                  onTap: sendButton,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: AppPalette.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send, color: AppPalette.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
