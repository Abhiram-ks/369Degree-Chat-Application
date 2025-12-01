import 'package:flutter/material.dart';
import 'package:webchat/core/common/custom_appbar.dart';

import '../../../core/theme/app_colors.dart';

class ChatTail extends StatelessWidget {
  const ChatTail({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppPalette.blue,
      child: SafeArea(
        child: Scaffold(
          appBar: CustomAppBar(isTitle: true, title: 'Chat Application', actions: [IconButton(onPressed: (){}, icon: Icon(Icons.help_outline_outlined))],),
          body: Column(
            children: [
              Text('Chat Tail'),
            ],
          ),
        ),
      ),
    );
  }
}