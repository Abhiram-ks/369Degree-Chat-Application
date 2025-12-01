
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
          border: Border.all(
            color: isSelected ? AppPalette.blue : AppPalette.hint,
            width: isSelected ? 2 : 1,
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
                    style: const TextStyle(
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
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppPalette.blue : AppPalette.grey,
                  width: 2,
                ),
                color: isSelected ? AppPalette.blue : AppPalette.white,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: AppPalette.white,
                      size: 16,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}