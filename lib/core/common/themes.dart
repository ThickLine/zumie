import 'package:flutter/material.dart';
import 'package:zumie/core/common/app_colors.dart';

final _lightThemeData = ThemeData.light();
final _darkThemeData = ThemeData.dark();

final primaryMaterialTheme = _lightThemeData.copyWith(
    colorScheme: const ColorScheme(
  brightness: Brightness.light,
  primary: kcDarkPrimaryColor,
  onPrimary: kcLightPrimaryColor,
  primaryContainer: kcMediumGreyColor,
  secondary: kcDarkPrimaryColor,
  secondaryContainer: kcLightPrimaryColor,
  onSecondary: kcLightPrimaryColor,
  background: kcLightPrimaryColor,
  onBackground: kcLightPrimaryColor,
  surface: kcLightPrimaryColor,
  onSurface: kcLightPrimaryColor,
  error: kcErrorColor,
  onError: kcLightPrimaryColor,
));

final darkMaterialTheme = _darkThemeData.copyWith(
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    surface: Colors.yellow,
    onSurface: Colors.black,
    // Colors that are not relevant to AppBar in DARK mode:
    primary: Colors.grey,
    onPrimary: Colors.grey,
    primaryContainer: Colors.grey,
    secondary: Colors.grey,
    secondaryContainer: Colors.grey,
    onSecondary: Colors.grey,
    background: Colors.grey,
    onBackground: Colors.grey,
    error: Colors.grey,
    onError: Colors.grey,
  ),
);
