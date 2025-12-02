

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webchat/core/common/custom_appbar.dart';
import 'package:webchat/src/domain/repo/websocket_repo.dart';
import 'package:webchat/core/common/custom_imageshow.dart';
import 'package:webchat/core/theme/app_colors.dart';
import 'package:webchat/src/presentation/blocs/bloc/get_single_user_bloc/get_single_user_bloc.dart';
import 'package:webchat/src/presentation/blocs/bloc/websocket_bloc/websocket_bloc.dart';
import '../../../../core/constant/app_image.dart';
import '../../../../core/constant/resposive_size.dart';
import '../../../domain/entity/user_entity.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int userId;
  final double screenWidth;

  const ChatAppBar({
    super.key,
    required this.userId,
    required this.screenWidth,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {

    return BlocBuilder<GetSingleUserBloc, GetSingleUserState>(
      builder: (context, state) {
        if (state is GetSingleUserSuccess) {
          final UserEntity user = state.user;

          return AppBar(
            backgroundColor: AppPalette.white,
            surfaceTintColor: Colors.transparent,
            automaticallyImplyLeading: true,
            elevation: 4,
            shadowColor: AppPalette.black.withValues(alpha: 0.2),
            scrolledUnderElevation: 4,
            titleSpacing: 0,
            iconTheme: const IconThemeData(color: AppPalette.black),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            title: BlocBuilder<WebSocketBloc, WebSocketState>(
              builder: (context, wsState) {
                final connectionStatus = wsState.connectionStatus;
                final isOnline =  connectionStatus == WebSocketConnectionStatus.connected;
                return GestureDetector(
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:isOnline ? AppPalette.green : AppPalette.hint.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: SizedBox(
                                width: 40,
                                height: 40,
                                child: imageshow(
                                  imageUrl: user.avatarUrl,
                                  imageAsset: AppImage.defaultImage,
                                ),
                              ),
                            ),
                           Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      shape: .circle,
                                      color: isOnline
                                          ? AppPalette.green
                                          : AppPalette.grey,
                                      border: .all(
                                        color: AppPalette.white,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                )
                          ],
                        ),
                      ),
                      Constant.width20(context),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: .start,
                          children: [
                            Text(
                              user.fullName,
                              style: TextStyle(
                                fontWeight: .w600,
                                fontSize: 16,
                                color: Color(0xFF111B21),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            BlocBuilder<WebSocketBloc, WebSocketState>(
                              builder: (context, wsState) {
                                final isTyping = wsState.isTypingForUser(
                                  userId,
                                );

                                if (isTyping) {
                                  return Text(
                                    'typing...',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.03,
                                      color: AppPalette.green,
                                      fontStyle: .italic,
                                    ),
                                  );
                                }

                                final connectionStatus =  wsState.connectionStatus;
                                final isOnline = connectionStatus ==  WebSocketConnectionStatus.connected;

                                return Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        shape: .circle,
                                        color: isOnline
                                            ? AppPalette.green
                                            : AppPalette.grey,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      isOnline ? 'Online' : 'Offline',
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.03,
                                        color: isOnline
                                            ? AppPalette.green
                                            : Color(0xFF667781),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      Constant.width40(context),
                    ],
                  ),
                );
              },
            ),
          );
        }
        return CustomAppBar(title: 'Current User', isTitle: true);
      },
    );
  }
}
