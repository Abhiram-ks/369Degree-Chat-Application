
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webchat/src/presentation/page/chat_window.dart';
import 'package:webchat/src/presentation/page/select_users.dart';
import '../../src/presentation/page/chat_tail.dart';
import '../../src/presentation/page/splash_screen.dart';
import '../constant/resposive_size.dart';

class AppRoutes {
  static const String splash = '/';
  static const String selectUsers = '/select_users';
  static const String chatTail = '/chat_tail';
  static const String chatWindow = '/chat_window';
  

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case selectUsers:
        return MaterialPageRoute(builder: (_) => const SelectUsers());
      case chatTail:
        return MaterialPageRoute(builder: (_) => ChatTail());
      case chatWindow:
       int userId = settings.arguments as int;
        return CupertinoPageRoute(builder: (_) =>  ChatWindow(
          userId: userId,
        ));
      default:
        return MaterialPageRoute(
          builder:
              (_) => LayoutBuilder(
                builder: (context, constraints) {
                  double screenWidth = constraints.maxWidth;

                  return Scaffold(
                    body: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * .04,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Page Not Found',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                           Constant.hight20(context),
                            Text(
                              'The page you were looking for could not be found. '
                              'It might have been removed, renamed, or does not exist.',
                              textAlign: TextAlign.center,
                              softWrap: true,
                              style: TextStyle(fontSize: 16, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
        );
    }
  }
}