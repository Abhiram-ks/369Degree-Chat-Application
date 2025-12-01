import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webchat/src/domain/repo/websocket_repo.dart';
import 'package:webchat/core/common/custom_imageshow.dart';
import 'package:webchat/core/theme/app_colors.dart';
import 'package:webchat/src/presentation/blocs/bloc/get_single_user_bloc/get_single_user_bloc.dart';
import 'package:webchat/src/presentation/blocs/bloc/websocket_bloc/websocket_bloc.dart';
import '../../../../core/constant/app_image.dart';
import '../../../../core/constant/resposive_size.dart';
import '../../../domain/entity/user_entity.dart';
import 'package:shimmer/shimmer.dart';


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
    // context.read<GetSingleUserBloc>().add(GetSingleUserRequest(userId:userId));

    return BlocBuilder<GetSingleUserBloc, GetSingleUserState>(
      builder: (context, state) {
         if (state is GetSingleUserSuccess) {
          final UserEntity user = state.user;

          return AppBar(
            backgroundColor: AppPalette.white,
            surfaceTintColor: Colors.transparent,
            automaticallyImplyLeading: true,
            elevation:  4,
            shadowColor: AppPalette.black.withValues(alpha: 0.2),
            scrolledUnderElevation: 4,
            titleSpacing: 0,
            iconTheme: const IconThemeData(color: AppPalette.black),
            leading:  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
            title: GestureDetector(
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppPalette.blue.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: SizedBox(
                            width:40,
                            height:  40,
                            child: imageshow(
                              imageUrl: user.avatarUrl,
                              imageAsset: AppImage.defaultImage,
                            ),
                          ),
                        ),
                        // Online/Offline indicator on avatar
                        BlocBuilder<WebSocketBloc, WebSocketState>(
                          builder: (context, wsState) {
                            final connectionStatus = wsState.connectionStatus;
                            final isOnline = connectionStatus == WebSocketConnectionStatus.connected;
                            
                            return Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isOnline 
                                      ? AppPalette.green 
                                      : AppPalette.grey,
                                  border: Border.all(
                                    color: AppPalette.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width:  12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullName,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color(0xFF111B21),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        BlocBuilder<WebSocketBloc, WebSocketState>(
                          builder: (context, wsState) {
                            // Typing indicator works in both online and offline mode
                            final isTyping = wsState.isTypingForUser(userId);
                            
                            if (isTyping) {
                              return Text(
                                'typing...',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.03,
                                  color: AppPalette.green,
                                  fontStyle: FontStyle.italic,
                                ),
                              );
                            }
                            
                            // Show online/offline status based on WebSocket connection
                            final connectionStatus = wsState.connectionStatus;
                            final isOnline = connectionStatus == WebSocketConnectionStatus.connected;
                            log('websocket status: $connectionStatus');
                            
                            return Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
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
            ),
          );
        } return  AppBar(
            backgroundColor: AppPalette.white,
          surfaceTintColor: Colors.transparent,
          automaticallyImplyLeading: true,
          elevation: 4,
          shadowColor: AppPalette.black.withValues(alpha: 0.15),
          scrolledUnderElevation: 4,
          titleSpacing: 0,
          iconTheme: const IconThemeData(color: AppPalette.black),
            title: Shimmer.fromColors(
          baseColor: Colors.grey[300] ?? AppPalette.grey,
          highlightColor: AppPalette.white,
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: imageshow(
                        imageUrl:'',
                        imageAsset: AppImage.defaultImage,
                      ),
                    ),
                  ),
                  Constant.width20(context),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "User Name Loading..." ,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                              fontSize: 16,
                            color: AppPalette.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                         'Loading...',
                          style: TextStyle(
                              fontSize: 16,
                            color:AppPalette.grey ,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
      },
    );
  }
}