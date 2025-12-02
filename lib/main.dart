
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webchat/src/data/datasource/local/database_helper.dart';
import 'package:webchat/src/presentation/blocs/bloc/get_store_user.dart/get_store_user_bloc.dart';

import 'core/di/di.dart';
import 'core/routers/app_routes.dart';
import 'core/theme/app_themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database;
  await init();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<GetStoreUserBloc>()..add(GetStoreUserRequest()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: '369Degree : WebChat',
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
