import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:webchat/core/constant/app_constants.dart';
import 'package:webchat/core/constant/app_image.dart';
import 'package:webchat/core/di/di.dart';
import 'package:webchat/src/presentation/blocs/bloc/get_single_user_bloc/get_single_user_bloc.dart';

class UserAvatarWidget extends StatelessWidget {
  final double? radius;
  final VoidCallback? onTap;

  const UserAvatarWidget({
    super.key,
    this.radius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (AppConstants.selectedUserId == null) {
      return _buildDefaultAvatar();
    }

    return BlocProvider(
      create: (context) => sl<GetSingleUserBloc>()
        ..add(GetSingleUserRequest(userId: AppConstants.selectedUserId!)),
      child: BlocBuilder<GetSingleUserBloc, GetSingleUserState>(
        builder: (context, state) {
          if (state is GetSingleUserSuccess) {
            return GestureDetector(
              onTap: onTap,
              child: state.user.avatarUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: state.user.avatarUrl,
                      imageBuilder: (context, imageProvider) => CircleAvatar(
                        radius: radius ?? 20,
                        backgroundImage: imageProvider,
                      ),
                      placeholder: (context, url) => CircleAvatar(
                        radius: radius ?? 20,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (context, url, error) => _buildDefaultAvatar(),
                    )
                  : _buildDefaultAvatar(),
            );
          } else if (state is GetSingleUserLoading) {
            return CircleAvatar(
              radius: radius ?? 20,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
              ),
            );
          } else {
            return _buildDefaultAvatar();
          }
        },
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: radius ?? 20,
        backgroundImage: const AssetImage(AppImage.defaultImage),
      ),
    );
  }

}

