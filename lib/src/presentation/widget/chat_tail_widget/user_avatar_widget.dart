import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
              child: CircleAvatar(
                radius: radius ?? 20,
                backgroundImage: state.user.avatarUrl.isNotEmpty
                    ? NetworkImage(state.user.avatarUrl)
                    : null,
                child: state.user.avatarUrl.isEmpty
                    ? _buildDefaultAvatarContent()
                    : null,
              ),
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

  Widget _buildDefaultAvatarContent() {
    return const Icon(
      Icons.person,
      size: 20,
    );
  }
}

