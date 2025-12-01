

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webchat/core/di/di.dart';
import 'package:webchat/src/presentation/blocs/cubit/select_user_cubit.dart';
import '../widget/select_user_widget/select_user_body.dart';

class SelectUsers extends StatelessWidget {
  const SelectUsers({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<SelectUserCubit>(),
        ),
      ],
      child: const SelectUsersView(),
    );
  }
}

