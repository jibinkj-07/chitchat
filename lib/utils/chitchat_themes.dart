import 'package:chitchat/utils/custom_route_transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyThemes {
  static ThemeData themeData(bool isDarkTheme, BuildContext context) {
    return ThemeData(
      fontFamily: 'Poppins',
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor:
          isDarkTheme ? const Color(0xff121212) : Colors.white,
      primaryColor: isDarkTheme
          ? const Color(0xff121212)
          : const Color.fromARGB(255, 0, 122, 255),
      backgroundColor: isDarkTheme ? Colors.black : const Color(0xffF1F5FB),
      indicatorColor:
          isDarkTheme ? const Color(0xff0E1D36) : const Color(0xffCBDCF8),
      hintColor:
          isDarkTheme ? const Color(0xffffffff) : const Color(0xff000000),
      highlightColor:
          isDarkTheme ? const Color(0xff372901) : const Color(0xffFCE192),
      hoverColor:
          isDarkTheme ? const Color(0xff3A3A3B) : const Color(0xff4285F4),
      focusColor:
          isDarkTheme ? const Color(0xff0B2512) : const Color(0xffA8DAB5),
      errorColor: const Color(0xffDB4437),
      disabledColor: Colors.grey,
      cardColor: isDarkTheme ? const Color(0xFF151515) : Colors.white,
      canvasColor: isDarkTheme ? Colors.black : Colors.grey[50],
      brightness: isDarkTheme ? Brightness.dark : Brightness.light,
      buttonTheme: Theme.of(context).buttonTheme.copyWith(
          colorScheme: isDarkTheme
              ? const ColorScheme.dark()
              : const ColorScheme.light()),
      appBarTheme: AppBarTheme(
        elevation: 0.0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              isDarkTheme ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDarkTheme ? Brightness.light : Brightness.dark,
        ),
      ),
      pageTransitionsTheme: PageTransitionsTheme(builders: {
        TargetPlatform.android: CustomPageTransitionBuilder(),
        TargetPlatform.iOS: CustomPageTransitionBuilder(),
      }),
      textSelectionTheme: TextSelectionThemeData(
          selectionColor: isDarkTheme ? Colors.white : Colors.black),
    );
  }
}
