
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webchat/src/presentation/widget/select_user_widget/select_user_builder.dart';

import '../../../../core/common/custom_appbar.dart';
import '../../../../core/constant/app_constants.dart';
import '../../../../core/routers/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../blocs/bloc/get_store_user.dart/get_store_user_bloc.dart';
import '../../blocs/cubit/select_user_cubit.dart';

class SelectUsersView extends StatefulWidget {
  const SelectUsersView({super.key});

  @override
  State<SelectUsersView> createState() => SelectUsersViewState();
}

class SelectUsersViewState extends State<SelectUsersView> {
  @override
  void initState() {
    super.initState();
    context.read<GetStoreUserBloc>().add(GetStoreUserRequest());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        isTitle: true,
        title: 'Select Users',
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.help_outline_outlined, color: AppPalette.black),
          )
        ],
      ),
      body: SelectUserBuilderWidget(),
      floatingActionButton: BlocBuilder<SelectUserCubit, SelectUserState>(
        builder: (context, selectState) {
          return selectState is SelectUserSelected
              ? FloatingActionButton.extended(
                  onPressed: () {
                    AppConstants.selectedUserId = selectState.user.id;
                    Navigator.pushReplacementNamed(context, AppRoutes.chatTail, );
                  },
                  backgroundColor: AppPalette.blue,
                  icon: const Icon(Icons.arrow_forward, color: AppPalette.white),
                  label: const Text(
                    'Next',
                    style: TextStyle(color: AppPalette.white),
                  ),
                )
              : const SizedBox.shrink();
        },
      ),
    );
  }
}
