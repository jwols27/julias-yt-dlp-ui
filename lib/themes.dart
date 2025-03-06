import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

ThemeData get defaultLightTheme {
  final flavor = catppuccin.frappe;
  Color cor1 = Colors.deepPurple[200]!;
  Color cor2 = Colors.deepPurple[100]!;

  return ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    extensions: [
      SkeletonizerConfigData.dark(
          containersColor: cor1,
          effect: ShimmerEffect(
            baseColor: cor1.withValues(alpha: 0.8),
            highlightColor: cor2,
          )),
      StatusColors(positive: flavor.green, negative: flavor.red, info: flavor.blue, warning: flavor.yellow)
    ],
  );
}

ThemeData get catppuccinDarkTheme {
  final flavor = catppuccin.frappe;
  MaterialColor materialColor = Colors.deepPurple;
  Color primaryColor = materialColor[200]!;
  Color secondaryColor = materialColor[300]!;
  Color tertiaryColor = materialColor[100]!;

  return ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    appBarTheme: AppBarTheme(
      elevation: 0,
      titleTextStyle: TextStyle(color: flavor.text, fontSize: 20, fontWeight: FontWeight.bold),
      backgroundColor: flavor.crust,
    ),
    tabBarTheme: TabBarTheme(
      indicatorColor: primaryColor,
      dividerColor: flavor.text.withValues(alpha: 0.4),
      labelStyle: TextStyle(color: primaryColor, fontWeight: FontWeight.w400),
      unselectedLabelStyle: TextStyle(color: flavor.text, fontWeight: FontWeight.w400),
      overlayColor: WidgetStateProperty.resolveWith<Color>(
        (states) {
          if (states.contains(WidgetState.hovered)) return tertiaryColor.withValues(alpha: 0.1);
          if (states.contains(WidgetState.pressed)) return tertiaryColor.withValues(alpha: 0.1);
          return Colors.transparent;
        },
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      disabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: flavor.surface2, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: flavor.overlay2, width: 1.5),
      ),
      labelStyle: TextStyle(color: flavor.text),
      floatingLabelStyle: TextStyle(color: flavor.text),
      hintStyle: TextStyle(color: flavor.text),
    ),
    textSelectionTheme: TextSelectionThemeData(cursorColor: flavor.text, selectionColor: secondaryColor),
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      error: flavor.surface2,
      onError: flavor.red,
      onPrimary: primaryColor,
      onSecondary: secondaryColor,
      onSurface: flavor.text,
      primary: flavor.crust,
      secondary: flavor.mantle,
      surface: flavor.base,
      surfaceContainer: flavor.surface0,
    ),
    cardTheme: CardTheme(
      color: flavor.base,
      shadowColor: flavor.overlay0,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Rounded corners
        side: BorderSide(
          color: flavor.text.withValues(alpha: 0.4), // Outline color
        ),
      ),
    ),
    textTheme: const TextTheme().apply(
      bodyColor: flavor.text,
      displayColor: primaryColor,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color>(
          (states) {
            if (states.contains(WidgetState.disabled)) return flavor.surface2;
            return primaryColor;
          },
        ),
        overlayColor: WidgetStateProperty.resolveWith<Color>(
          (states) {
            if (states.contains(WidgetState.hovered)) return flavor.text.withValues(alpha: 0.2);
            if (states.contains(WidgetState.pressed)) return flavor.text.withValues(alpha: 0.2);
            return Colors.transparent;
          },
        ),
        iconColor: WidgetStatePropertyAll(flavor.crust),
        foregroundColor: WidgetStateProperty.all(flavor.crust),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith<Color>(
          (states) {
            if (states.contains(WidgetState.disabled)) return flavor.overlay1;
            return primaryColor;
          },
        ),
        iconColor: WidgetStateProperty.resolveWith<Color>(
          (states) {
            if (states.contains(WidgetState.disabled)) return flavor.overlay1;
            return primaryColor;
          },
        ),
        overlayColor: WidgetStateProperty.resolveWith<Color>(
          (states) {
            if (states.contains(WidgetState.hovered)) return primaryColor.withValues(alpha: 0.1);
            if (states.contains(WidgetState.pressed)) return primaryColor.withValues(alpha: 0.1);
            return Colors.transparent;
          },
        ),
        side: WidgetStateProperty.resolveWith<BorderSide>(
          (states) {
            if (states.contains(WidgetState.disabled)) return BorderSide(color: flavor.surface1);
            return BorderSide(color: flavor.text);
          },
        ),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      checkColor: WidgetStateProperty.resolveWith<Color>(
        (states) {
          if (states.contains(WidgetState.disabled)) {
            return flavor.surface2;
          }
          return flavor.crust;
        },
      ),
      fillColor: WidgetStateProperty.resolveWith<Color>(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return Colors.transparent;
        },
      ),
      overlayColor: WidgetStateProperty.resolveWith<Color>(
        (states) {
          if (states.contains(WidgetState.hovered)) {
            return primaryColor.withValues(alpha: 0.2);
          }
          return Colors.transparent;
        },
      ),
    ),
    dividerTheme: DividerThemeData(
      color: flavor.text.withValues(alpha: 0.4),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color>(
        (states) {
          if (states.contains(WidgetState.hovered)) return primaryColor;
          if (states.contains(WidgetState.selected)) return primaryColor;

          return flavor.text;
        },
      ),
      overlayColor: WidgetStateProperty.resolveWith<Color>(
        (states) {
          if (states.contains(WidgetState.hovered)) return primaryColor.withValues(alpha: 0.1);
          return Colors.transparent;
        },
      ),
      trackOutlineColor: WidgetStateProperty.resolveWith<Color>(
        (states) {
          if (states.contains(WidgetState.selected)) return flavor.text;

          return flavor.text;
        },
      ),
    ),
    extensions: [
      SkeletonizerConfigData.dark(
          containersColor: primaryColor,
          effect: ShimmerEffect(
            baseColor: primaryColor,
            highlightColor: tertiaryColor,
          )),
      StatusColors(positive: flavor.green, negative: flavor.red, info: flavor.blue, warning: flavor.yellow)
    ],
  );
}

@immutable
class StatusColors extends ThemeExtension<StatusColors> {
  final Color positive;
  final Color negative;
  final Color info;
  final Color warning;

  const StatusColors({
    required this.positive,
    required this.negative,
    required this.info,
    required this.warning,
  });

  @override
  StatusColors copyWith({Color? positive, Color? negative, Color? info, Color? warning}) {
    return StatusColors(
      positive: positive ?? this.positive,
      negative: negative ?? this.negative,
      info: negative ?? this.info,
      warning: warning ?? this.warning,
    );
  }

  @override
  StatusColors lerp(ThemeExtension<StatusColors>? other, double t) {
    if (other is! StatusColors) return this;
    return StatusColors(
      positive: Color.lerp(positive, other.positive, t)!,
      negative: Color.lerp(negative, other.negative, t)!,
      info: Color.lerp(info, other.info, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
    );
  }
}
