import 'package:flutter/material.dart';

import '../constant/CustomColors.dart';

ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
        background: Colors.black,
        primary: Colors.grey[850]!,
        secondary: CustomColors.messengerColor,
        tertiary: Colors.white));
