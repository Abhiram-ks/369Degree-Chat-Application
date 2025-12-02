import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webchat/core/common/custom_dialog_box.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<GetStoreUserBloc>().add(GetStoreUserRequest());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        isTitle: true,
        title: 'Select Users',
        actions: [
          IconButton(
            onPressed: () {
              CustomCupertinoDialog.show(context: context, title: 'Select user purpose', message:"Select your purpose.\nThis choice is used only for your profile management and will not be shown in the chat. Pick your preferred option using the choice chips. After selecting one, the Next button will appear to proceed to the chat.", text: 'Got It', color: AppPalette.blue);
            },
            icon: const Icon(
              Icons.help_outline_outlined,
              color: AppPalette.black,
            ),
          ),
        ],
      ),
      body: const SelectUserBuilderWidget(),
      floatingActionButton: BlocBuilder<SelectUserCubit, SelectUserState>(
        builder: (context, selectState) {
          return selectState is SelectUserSelected
              ? FloatingActionButton.extended(
                  onPressed: () {
                    AppConstants.selectedUserId = selectState.user.id;
                    Navigator.pushReplacementNamed(context, AppRoutes.chatTail);
                  },
                  backgroundColor: AppPalette.blue,
                  icon: const Icon(
                    Icons.arrow_forward_rounded,
                    color: AppPalette.white,
                  ),
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
