import 'package:flutter/material.dart';
import 'package:message_app/constant/CustomColors.dart';

ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      background: Colors.white,
      primary: Colors.black.withOpacity(0.1),
      secondary: CustomColors.messengerColor,
      tertiary: Colors.black,
    ));
