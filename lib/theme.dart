import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);

  static const EdgeInsets horizontalXs = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets horizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets horizontalXl = EdgeInsets.symmetric(horizontal: xl);

  static const EdgeInsets verticalXs = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets verticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets verticalXl = EdgeInsets.symmetric(vertical: xl);
}

class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
}

extension TextStyleContext on BuildContext {
  TextTheme get textStyles => Theme.of(this).textTheme;
}

extension TextStyleExtensions on TextStyle {
  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);
  TextStyle get normal => copyWith(fontWeight: FontWeight.w400);
  TextStyle get light => copyWith(fontWeight: FontWeight.w300);
  TextStyle withColor(Color color) => copyWith(color: color);
  TextStyle withSize(double size) => copyWith(fontSize: size);
}

class AppColors {
  // Paleta Premium: Dark & Neon
  static const neonGreen = Color(0xFFCCFF00); // El verde neon que le gusta
  static const darkBackground =
      Color(0xFF000720); // El color exacto que pidió el usuario
  static const darkSurface = Color(0xFF000720); // Mismo fondo para uniformidad
  static const darkSurfaceHighlight =
      Color(0xFF0D1B3E); // Un poco más claro para contraste sutil

  static const white = Color(0xFFFFFFFF);
  static const greyLabel = Color(0xFFB3B3B3); // Gris para textos secundarios

  // Colores principales
  static const primary = neonGreen;
  static const secondary = white;

  // Mapeo a los nombres usados en la app
  static const padelBlue =
      neonGreen; // Reemplazamos el azul por el verde neon como principal
  static const padelBlueDark =
      Color(0xFF99CC00); // Versión más oscura del verde
  static const padelBlueLight = Color(0xFFE6FF80); // Versión clara del verde

  static const ballYellow = neonGreen;
  static const ballYellowBright = Color(0xFFE0FF66);
  static const ballGreen = neonGreen;

  // Fondos
  static const deepBlueBackground = darkBackground;
  static const deepBlueSurface = darkSurface;

  static const backgroundColor = darkBackground;
  static const surfaceColor = darkSurface;
  static const cardBackground = darkSurface;

  // Textos
  static const textPrimary = white; // Texto blanco sobre fondo oscuro
  static const textSecondary = greyLabel;
  static const textLight = white;
  static const textGrey = greyLabel;

  // Oscuros (para dark mode o acentos)
  // static const darkBackground ya está definido arriba
  // static const darkSurface ya está definido arriba
  static const darkCard = darkSurfaceHighlight;

  // Claros (para situaciones específicas donde se necesite fondo claro)
  static const lightBackground = Color(0xFFF5F5F5);
  static const lightSurface = Color(0xFFFFFFFF);

  // Alias para compatibilidad
  static const electricBlue =
      neonGreen; // Usamos el verde como color eléctrico principal
  static const textDark = darkBackground; // Para texto sobre botones neon
  static const cardGrey = darkSurface;
  static const navy = darkBackground;

  // Otros
  static const royalBlue = neonGreen; // Reemplazo para compatibilidad
  static const skyBlue = white; // Reemplazo para compatibilidad
  static const charcoalGrey = darkSurface;
  static const lightGrey = darkSurfaceHighlight;
}

class LightModeColors {
  static const lightPrimary = AppColors.ballYellow;
  static const lightOnPrimary = AppColors.textPrimary;
  static const lightPrimaryContainer =
      Color(0xFF003820); // Ajustado para contraste
  static const lightOnPrimaryContainer = Color(0xFFE6FFF2);

  static const lightSecondary = AppColors.ballYellow;
  static const lightOnSecondary = AppColors.textLight;

  static const lightTertiary = AppColors.padelBlue;
  static const lightOnTertiary = AppColors.textLight;

  static const lightError = Color(0xFFFF3B30);
  static const lightOnError = AppColors.textLight;

  static const lightSurface = AppColors.deepBlueSurface;
  static const lightOnSurface =
      AppColors.textLight; // Texto blanco en superficie oscura
  static const lightBackground = AppColors.deepBlueBackground;
  static const lightOutline =
      Color(0xFF334155); // Outline más sutil para fondo oscuro
}

class DarkModeColors {
  static const darkPrimary = Color(0xFF000000);
  static const darkOnPrimary = AppColors.textPrimary;
  static const darkPrimaryContainer = Color(0xFF00572F);
  static const darkOnPrimaryContainer = Color(0xFFB3FFD9);

  static const darkSecondary = Color(0xFF201F1F);
  static const darkOnSecondary = AppColors.textPrimary;

  static const darkTertiary = AppColors.padelBlue;
  static const darkOnTertiary = AppColors.textPrimary;

  static const darkError = Color(0xFFFF453A);
  static const darkOnError = AppColors.textLight;

  static const darkSurface = AppColors.deepBlueSurface;
  static const darkOnSurface = AppColors.textLight;
  static const darkBackground = AppColors.deepBlueBackground;
  static const darkOutline = Color(0xFF3A3F4E);
}

ThemeData get lightTheme => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        // Cambiado a dark para base correcta
        primary: LightModeColors.lightPrimary,
        onPrimary: LightModeColors.lightOnPrimary,
        primaryContainer: LightModeColors.lightPrimaryContainer,
        onPrimaryContainer: LightModeColors.lightOnPrimaryContainer,
        secondary: LightModeColors.lightSecondary,
        onSecondary: LightModeColors.lightOnSecondary,
        tertiary: LightModeColors.lightTertiary,
        onTertiary: LightModeColors.lightOnTertiary,
        error: LightModeColors.lightError,
        onError: LightModeColors.lightOnError,
        surface: LightModeColors.lightSurface,
        onSurface: LightModeColors.lightOnSurface,
        outline: LightModeColors.lightOutline,
      ),
      brightness:
          Brightness.dark, // Importante: Brightness dark para texto blanco
      scaffoldBackgroundColor: LightModeColors.lightBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: LightModeColors.lightOnSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: LightModeColors.lightOnSurface,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: LightModeColors.lightPrimary,
          foregroundColor: LightModeColors.lightOnPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: LightModeColors.lightPrimary,
          side: BorderSide(color: LightModeColors.lightPrimary, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: LightModeColors.lightSurface, // Usar superficie oscura
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: LightModeColors.lightOutline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: LightModeColors.lightOutline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: LightModeColors.lightPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: LightModeColors.lightError, width: 2),
        ),
        labelStyle:
            GoogleFonts.poppins(fontSize: 14, color: AppColors.textGrey),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: LightModeColors.lightSurface, // Usar superficie oscura
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: LightModeColors.lightOutline, width: 1),
        ),
      ),
      textTheme: _buildTextTheme(
          Brightness.dark), // Usar tema de texto oscuro (letras blancas)
    );

ThemeData get darkTheme => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: DarkModeColors.darkPrimary,
        onPrimary: DarkModeColors.darkOnPrimary,
        primaryContainer: DarkModeColors.darkPrimaryContainer,
        onPrimaryContainer: DarkModeColors.darkOnPrimaryContainer,
        secondary: DarkModeColors.darkSecondary,
        onSecondary: DarkModeColors.darkOnSecondary,
        tertiary: DarkModeColors.darkTertiary,
        onTertiary: DarkModeColors.darkOnTertiary,
        error: DarkModeColors.darkError,
        onError: DarkModeColors.darkOnError,
        surface: DarkModeColors.darkSurface,
        onSurface: DarkModeColors.darkOnSurface,
        outline: DarkModeColors.darkOutline,
      ),
      brightness: Brightness.dark,
      scaffoldBackgroundColor: DarkModeColors.darkBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: DarkModeColors.darkOnSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: DarkModeColors.darkOnSurface,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DarkModeColors.darkPrimary,
          foregroundColor: DarkModeColors.darkOnPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: DarkModeColors.darkPrimary,
          side: BorderSide(color: DarkModeColors.darkPrimary, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCard,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: DarkModeColors.darkOutline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: DarkModeColors.darkOutline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: DarkModeColors.darkPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: DarkModeColors.darkError, width: 2),
        ),
        labelStyle:
            GoogleFonts.poppins(fontSize: 14, color: AppColors.textGrey),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: DarkModeColors.darkOutline, width: 1),
        ),
      ),
      textTheme: _buildTextTheme(Brightness.dark),
    );

TextTheme _buildTextTheme(Brightness brightness) {
  final baseColor = brightness == Brightness.light
      ? AppColors.textPrimary
      : AppColors.textLight;

  return TextTheme(
    displayLarge: GoogleFonts.orbitron(
      fontSize: 48,
      fontWeight: FontWeight.bold,
      color: baseColor,
      letterSpacing: -1,
    ),
    displayMedium: GoogleFonts.orbitron(
      fontSize: 36,
      fontWeight: FontWeight.bold,
      color: baseColor,
      letterSpacing: -0.5,
    ),
    displaySmall: GoogleFonts.orbitron(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      color: baseColor,
    ),
    headlineLarge: GoogleFonts.poppins(
      fontSize: 32,
      fontWeight: FontWeight.w600,
      color: baseColor,
    ),
    headlineMedium: GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: baseColor,
    ),
    headlineSmall: GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: baseColor,
    ),
    titleLarge: GoogleFonts.poppins(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: baseColor,
    ),
    titleMedium: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: baseColor,
    ),
    titleSmall: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: baseColor,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: baseColor,
      letterSpacing: 0.15,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: baseColor,
      letterSpacing: 0.25,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: baseColor,
      letterSpacing: 0.4,
    ),
    labelLarge: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: baseColor,
      letterSpacing: 0.1,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: baseColor,
      letterSpacing: 0.5,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: baseColor,
      letterSpacing: 0.5,
    ),
  );
}
