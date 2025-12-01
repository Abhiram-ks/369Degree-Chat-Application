import 'package:flutter/material.dart';

import '../../../../core/common/custom_imageshow.dart';
import '../../../../core/constant/app_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../domain/entity/user_entity.dart';

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

    return Padding(
      padding: .symmetric(
        vertical: 3,
        horizontal: screenWidth * 0.04,
      ),
      child: Container(
        color: AppPalette.white,
        width: double.infinity,
        child: Row(
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
                    style: TextStyle(fontWeight: .bold),
                    maxLines: 1,
                    overflow: .ellipsis,
                  ),
                  Text(
                    user.email,
                    style: TextStyle(color: AppPalette.grey, fontSize: 12),
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
                Text('1 Jan 2000', style: TextStyle(color: AppPalette.grey, fontSize: 13)),
                const SizedBox(height: 6),
        
                Container(
                  padding: .symmetric(
                    horizontal: avatarSize * 0.12,
                    vertical: avatarSize * 0.05,
                  ),
                  decoration: const BoxDecoration(
                    color: AppPalette.blue,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '10',
                    style: TextStyle(
                      color: AppPalette.white,
                      fontSize: screenWidth * 0.03,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
