import 'package:flutter/material.dart';

import 'core/routers/app_routes.dart';
import 'core/theme/app_themes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '369Degree : WebChat',
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}