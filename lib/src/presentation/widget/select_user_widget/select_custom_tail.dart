
import 'package:flutter/material.dart';

import '../../../../core/common/custom_imageshow.dart';
import '../../../../core/constant/app_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../domain/entity/user_entity.dart';

class SelectableUserTile extends StatelessWidget {
  final UserEntity user;
  final bool isSelected;
  final VoidCallback onTap;

  const SelectableUserTile({
    super.key,
    required this.user,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final avatarSize = 50.0;
    final horizontalSpacing = screenWidth * 0.04;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppPalette.white,
          borderRadius: .circular(8),
          border: .all(
            color: isSelected ? AppPalette.blue : AppPalette.white,
            width: 1,
          ),
        ),
        padding: .symmetric(
          vertical: 12,
          horizontal: horizontalSpacing,
        ),
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
                    style:  TextStyle(
                      color:isSelected ? AppPalette.blue : AppPalette.black,
                      fontWeight: .bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: .ellipsis,
                  ),
                  Text(
                    user.email,
                    style: const TextStyle(
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
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: .circle,
                border: .all(
                  color: isSelected ? AppPalette.blue : AppPalette.grey,
                  width: 1,
                ),
                color: isSelected ? AppPalette.blue : AppPalette.white,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: AppPalette.white,
                      size: 14,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}