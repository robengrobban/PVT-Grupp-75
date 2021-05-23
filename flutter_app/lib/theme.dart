
import 'package:flutter/material.dart';

final ThemeData walkInProgressThemeData = new ThemeData(
  primarySwatch: MaterialColor(AppColors.brandPink[500].value, AppColors.brandPink),
  primaryColor: AppColors.brandPink[500],
  accentColor: AppColors.brandOrange[500],
);

class AppColors {
  AppColors._(); // this basically makes it so you can instantiate this class

  static const Map<int, Color> brandPink = const <int, Color> {
    50: const Color(0xff803542),
    100: const Color(0xff99404f),
    200: const Color(0xffb34a5c),
    300: const Color(0xffcc5569),
    400: const Color(0xffe65f76),
    500: const Color(0xffff6a83), // PRIMARY DUDE
    600: const Color(0xffff798f),
    700: const Color(0xffff889c),
    800: const Color(0xffff97a8),
    900: const Color(0xffffa6b5)
  };

  static const Map<int, Color> brandOrange = const <int, Color> {
    50: const Color(0xff7a5433),
    100: const Color(0xff92653d),
    200: const Color(0xffaa7647),
    300: const Color(0xffc28652),
    400: const Color(0xffdb975c),
    500: const Color(0xfff3a866), // PRIMARYYYYY
    600: const Color(0xfff4b175),
    700: const Color(0xfff5b985),
    800: const Color(0xfff7c294),
    900: const Color(0xfff8cba3)
  };

}

LinearGradient appGradiant = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [AppColors.brandPink[500], AppColors.brandOrange[500]],
);
