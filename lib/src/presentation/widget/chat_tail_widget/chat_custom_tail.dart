import 'package:flutter/material.dart';
import 'package:webchat/core/di/di.dart';
import 'package:webchat/src/domain/entity/message_entity.dart';
import 'package:webchat/src/domain/repo/message_repo.dart';
import '../../../../core/common/custom_imageshow.dart';
import '../../../../core/constant/app_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../domain/entity/user_entity.dart';
import 'chat_data_convert_logic.dart';

class ChatTile extends StatelessWidget {
  final UserEntity user;
  const ChatTile({
    super.key,
    required this.user,
  });


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final avatarSize = 50.00;
    final horizontalSpacing = screenWidth * 0.04;
    final messageRepo = sl<MessageRepo>();

    return Padding(
      padding: .symmetric(
        vertical: 3,
        horizontal: screenWidth * 0.04,
      ),
      child: Container(
        color: AppPalette.white,
        width: double.infinity,
        child: FutureBuilder<List<MessageEntity>>(
          future: messageRepo.getMessagesByUserId(user.id),
          builder: (context, futureSnapshot) {
            return StreamBuilder<List<MessageEntity>>(
              stream: messageRepo.watchMessagesByUserId(user.id),
              builder: (context, streamSnapshot) {
                List<MessageEntity> messages = [];
                if (streamSnapshot.hasData && streamSnapshot.data!.isNotEmpty) {
                  messages = streamSnapshot.data!;
                } else if (futureSnapshot.hasData && futureSnapshot.data!.isNotEmpty) {
                  messages = futureSnapshot.data!;
                }

                MessageEntity? lastMessage;
                String lastMessageText = '';
                String formattedDate = '';

                if (messages.isNotEmpty) {
                  lastMessage = messages.last;
                  lastMessageText = lastMessage.message;
                  formattedDate = formatDate(lastMessage.date);
                } else {
                  lastMessageText = 'No messages yet';
                  formattedDate = '';
                }

            return Row(
              children: [
                ClipRRect(
                  borderRadius: .circular(avatarSize / 2),
                  child: SizedBox(
                    width: avatarSize,
                    height: avatarSize,
                    child: imageshow(
                      imageUrl: user.avatarUrl,
                      imageAsset: AppImage.defaultImage,
                    ),
                  ),
                ),
                SizedBox(width: horizontalSpacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Text(
                        user.fullName,
                        style: const TextStyle(fontWeight: .bold),
                        maxLines: 1,
                        overflow: .ellipsis,
                      ),
                      Text(
                        lastMessageText,
                        style: TextStyle(
                          color: AppPalette.grey,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: .ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: horizontalSpacing),
                Column(
                  crossAxisAlignment: .end,
                  children: [
                    if (formattedDate.isNotEmpty)
                      Text(
                        formattedDate,
                        style: TextStyle(color: AppPalette.grey, fontSize: 13),
                      ),
                  ],
                ),
              ],
            );
              },
            );
          },
        ),
      ),
    );
  }
}
