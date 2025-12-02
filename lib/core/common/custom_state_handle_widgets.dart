import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webchat/core/theme/app_colors.dart';

class CustomStateHandleWidgets {
  static Widget loadingWidget({double? height, double? width, double? strokeWidth}) {
    return Center(
      child: SizedBox(
        height: height ?? 15,
        width: width ?? 15,
        child: CircularProgressIndicator(
          color: AppPalette.blue,
          backgroundColor: AppPalette.hint,
          strokeWidth: strokeWidth ?? 2,
        ),
      ),
    );
  }
  static Widget informationWidget({required String message,required VoidCallback onTap}) {
    return Center(
      child: Column(
        mainAxisAlignment: .center,
        crossAxisAlignment: .center,
        children: [
          Text(message, textAlign: .center, style: TextStyle(fontSize: 12, fontWeight: .w200),),
          IconButton(onPressed: onTap, icon: Icon(CupertinoIcons.refresh)),
        ],
      ),
    );
  }
}