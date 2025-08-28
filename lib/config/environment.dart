import 'package:flutter/foundation.dart';

/// 환경 설정 관리 클래스
/// 개발, 스테이징, 프로덕션 환경별 설정을 관리합니다.
class Environment {
  static const String env = String.fromEnvironment(
    'ENV',
    defaultValue: 'development',
  );

  static bool get isDevelopment => env == 'development';
  static bool get isStaging => env == 'staging';
  static bool get isProduction => env == 'production';

  /// API 기본 URL
  static String get apiBaseUrl {
    switch (env) {
      case 'production':
        return 'https://api.studymate.app';
      case 'staging':
        return 'https://staging-api.studymate.app';
      case 'development':
      default:
        return 'https://54.161.77.144';
    }
  }

  /// API 타임아웃 설정 (밀리초)
  static Duration get apiTimeout {
    if (isProduction) {
      return const Duration(seconds: 15);
    }
    return const Duration(seconds: 30);
  }

  /// 로그 레벨 설정
  static LogLevel get logLevel {
    if (isProduction) {
      return LogLevel.error;
    } else if (isStaging) {
      return LogLevel.warning;
    }
    return LogLevel.debug;
  }

  /// SSL 인증서 검증 여부
  static bool get validateSSL {
    // 프로덕션에서는 항상 SSL 검증
    // 개발 환경에서만 선택적으로 우회 가능
    return !isDevelopment;
  }

  /// 디버그 모드 여부
  static bool get enableDebugMode {
    return isDevelopment;
  }

  /// 에러 리포팅 활성화 여부
  static bool get enableErrorReporting {
    return isProduction || isStaging;
  }

  /// 애널리틱스 활성화 여부
  static bool get enableAnalytics {
    return isProduction;
  }

  /// API 키 (예시)
  static String get apiKey {
    if (isProduction) {
      return const String.fromEnvironment('API_KEY', defaultValue: '');
    }
    return 'dev_api_key_for_testing';
  }

  /// 암호화 키 (예시)
  static String get encryptionKey {
    return const String.fromEnvironment(
      'ENCRYPTION_KEY',
      defaultValue: 'default_encryption_key_32_chars_!',
    );
  }
}

/// 로그 레벨 열거형
enum LogLevel {
  debug,
  info,
  warning,
  error,
  none,
}

/// 환경 설정 유효성 검증
class EnvironmentValidator {
  static bool validate() {
    final errors = <String>[];

    // 프로덕션 환경에서 필수 설정 검증
    if (Environment.isProduction) {
      if (Environment.apiKey.isEmpty) {
        errors.add('API_KEY is required in production');
      }
      
      if (!Environment.apiBaseUrl.startsWith('https://')) {
        errors.add('API URL must use HTTPS in production');
      }

      if (!Environment.validateSSL) {
        errors.add('SSL validation must be enabled in production');
      }
    }

    if (errors.isNotEmpty) {
      debugPrint('[Environment Validation Failed]');
      for (final error in errors) {
        debugPrint('  - $error');
      }
      return false;
    }

    return true;
  }

  /// 현재 환경 정보 출력
  static void printEnvironmentInfo() {
    debugPrint('═══════════════════════════════════════════');
    debugPrint('           ENVIRONMENT SETTINGS            ');
    debugPrint('═══════════════════════════════════════════');
    debugPrint('  Environment: ${Environment.env}');
    debugPrint('  API URL: ${Environment.apiBaseUrl}');
    debugPrint('  SSL Validation: ${Environment.validateSSL}');
    debugPrint('  Debug Mode: ${Environment.enableDebugMode}');
    debugPrint('  Log Level: ${Environment.logLevel}');
    debugPrint('  Analytics: ${Environment.enableAnalytics}');
    debugPrint('  Error Reporting: ${Environment.enableErrorReporting}');
    debugPrint('═══════════════════════════════════════════');
  }
}