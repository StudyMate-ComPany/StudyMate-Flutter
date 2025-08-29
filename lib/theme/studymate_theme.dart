import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StudyMateTheme {
  // 와이어프레임 기반 색상 정의
  static const Color primaryBlue = Color(0xFF7CC4E8); // 메인 하늘색
  static const Color lightBlue = Color(0xFFE8F6FB); // 배경 연한 하늘색
  static const Color accentPink = Color(0xFFFFB6D9); // 포인트 핑크
  static const Color beige = Color(0xFFF5E6D3); // 캐릭터 얼굴색
  static const Color darkNavy = Color(0xFF2C3E50); // 진한 글자색
  static const Color grayText = Color(0xFF6B7280); // 회색 텍스트
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFF3F4F6);
  
  // 소셜 로그인 버튼 색상
  static const Color kakaoYellow = Color(0xFFFEE500);
  static const Color naverGreen = Color(0xFF03C75A);
  static const Color googleWhite = Color(0xFFFFFFFF);
  static const Color appleBlack = Color(0xFF000000);

  // 그라데이션
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFE8F6FB),
      Color(0xFFFFFFFF),
    ],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF7CC4E8),
      Color(0xFF9AD5ED),
    ],
  );

  // 텍스트 스타일 - 와이어프레임 기반
  static TextStyle get headingLarge => GoogleFonts.notoSans(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: primaryBlue,
    letterSpacing: -0.5,
  );

  static TextStyle get headingMedium => GoogleFonts.notoSans(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: darkNavy,
    letterSpacing: -0.3,
  );

  static TextStyle get headingSmall => GoogleFonts.notoSans(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: darkNavy,
  );

  static TextStyle get bodyLarge => GoogleFonts.notoSans(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: darkNavy,
    height: 1.6,
  );

  static TextStyle get bodyMedium => GoogleFonts.notoSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: grayText,
    height: 1.5,
  );

  static TextStyle get bodySmall => GoogleFonts.notoSans(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: grayText,
    height: 1.4,
  );

  static TextStyle get buttonText => GoogleFonts.notoSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: white,
    letterSpacing: 0.5,
  );

  static TextStyle get labelText => GoogleFonts.notoSans(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: darkNavy,
  );

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: lightBlue,
      
      // ColorScheme
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: accentPink,
        surface: white,
        surfaceContainer: lightGray,
        onPrimary: white,
        onSecondary: darkNavy,
        onSurface: darkNavy,
        error: Color(0xFFFF6B6B),
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: darkNavy),
        titleTextStyle: headingMedium,
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: headingLarge,
        displayMedium: headingMedium,
        displaySmall: headingSmall,
        headlineLarge: headingLarge,
        headlineMedium: headingMedium,
        headlineSmall: headingSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: buttonText,
        labelMedium: labelText,
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 1),
        ),
        hintStyle: bodyMedium.copyWith(color: grayText.withOpacity(0.6)),
        labelStyle: labelText,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: buttonText,
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        color: white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: lightGray,
        selectedColor: primaryBlue.withOpacity(0.2),
        labelStyle: bodyMedium,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: white,
        selectedItemColor: primaryBlue,
        unselectedItemColor: grayText,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Dialog Theme
      dialogTheme: DialogTheme(
        backgroundColor: white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: headingSmall,
        contentTextStyle: bodyMedium,
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: grayText.withOpacity(0.1),
        thickness: 1,
        space: 24,
      ),
    );
  }

  // 커스텀 위젯 스타일
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: primaryBlue.withOpacity(0.08),
        blurRadius: 20,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration get primaryButtonDecoration => BoxDecoration(
    gradient: buttonGradient,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: primaryBlue.withOpacity(0.3),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration get socialButtonDecoration => BoxDecoration(
    color: white,
    borderRadius: BorderRadius.circular(50),
    border: Border.all(color: lightGray, width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 2),
      ),
    ],
  );

  // 페이지 인디케이터 스타일
  static BoxDecoration activeIndicatorDecoration = BoxDecoration(
    color: primaryBlue,
    borderRadius: BorderRadius.circular(4),
  );

  static BoxDecoration inactiveIndicatorDecoration = BoxDecoration(
    color: primaryBlue.withOpacity(0.3),
    borderRadius: BorderRadius.circular(4),
  );
}