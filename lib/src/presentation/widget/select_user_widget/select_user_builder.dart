
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webchat/src/presentation/blocs/bloc/get_store_user.dart/get_store_user_bloc.dart';
import 'package:webchat/src/presentation/blocs/cubit/select_user_cubit.dart';
import '../../../../core/constant/resposive_size.dart';
import '../../../../core/theme/app_colors.dart';
import 'select_custom_tail.dart';

class SelectUserBuilderWidget extends StatelessWidget {
  const SelectUserBuilderWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppPalette.blue,
      backgroundColor: AppPalette.white,
      onRefresh: () async {
        context.read<GetStoreUserBloc>().add(GetStoreUserRequest());
      },
      child: BlocBuilder<GetStoreUserBloc, GetStoreUserState>(
        builder: (context, state) {
          if (state is GetStoreUserLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppPalette.blue,
                backgroundColor: AppPalette.white,
                strokeWidth: 2,
              ),
            );
          } else if (state is GetStoreUserSuccess) {
            if (state.users.isEmpty) {
              return const Center(
                child: Text('No users available'),
              );
            }
            return ListView.separated(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.04,
                vertical: 16,
              ),
              itemCount: state.users.length,
              itemBuilder: (context, index) {
                final user = state.users[index];
                return BlocBuilder<SelectUserCubit, SelectUserState>(
                  builder: (context, selectState) {
                    final isSelected = selectState is SelectUserSelected &&
                        selectState.user.id == user.id;
                    return SelectableUserTile(
                      user: user,
                      isSelected: isSelected,
                      onTap: () {
                        context.read<SelectUserCubit>().toggleUser(user);
                      },
                    );
                  },
                );
              },
              separatorBuilder: (context, index) {
                return Constant.hight10(context);
              },
            );
          } else if (state is GetStoreUserSuccess) {
            if (state.users.isEmpty) {
              return const Center(
                child: Text('No users available'),
              );
            }
            return ListView.separated(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.04,
                vertical: 16,
              ),
              itemCount: state.users.length,
              itemBuilder: (context, index) {
                final user = state.users[index];
                return BlocBuilder<SelectUserCubit, SelectUserState>(
                  builder: (context, selectState) {
                    final isSelected = selectState is SelectUserSelected &&
                        selectState.user.id == user.id;
                    return SelectableUserTile(
                      user: user,
                      isSelected: isSelected,
                      onTap: () {
                        context.read<SelectUserCubit>().toggleUser(user);
                      },
                    );
                  },
                );
              },
              separatorBuilder: (context, index) {
                return Constant.hight10(context);
              },
            );
          } else if (state is GetStoreUserFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.message,
                    style: const TextStyle(color: AppPalette.red),
                  ),
                  Constant.width20(context),
                  ElevatedButton(
                    onPressed: () {
                      context.read<GetStoreUserBloc>().add(GetStoreUserRequest());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}