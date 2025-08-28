import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../config/environment.dart';

/// 로깅 유틸리티 클래스
/// 환경별로 적절한 로그 레벨을 관리합니다.
class Logger {
  static final _instance = Logger._internal();
  factory Logger() => _instance;
  Logger._internal();

  static const String _reset = '\x1B[0m';
  static const String _red = '\x1B[31m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String _blue = '\x1B[34m';
  static const String _magenta = '\x1B[35m';
  static const String _cyan = '\x1B[36m';
  static const String _white = '\x1B[37m';

  static void _log(String message, LogLevel level, {String? tag}) {
    if (_shouldLog(level)) {
      final timestamp = DateTime.now().toIso8601String();
      final prefix = tag != null ? '[$tag] ' : '';
      final color = _getColor(level);
      final emoji = _getEmoji(level);
      
      if (kDebugMode) {
        debugPrint('$color$emoji ${level.name.toUpperCase()} $timestamp $prefix$message$_reset');
      }
      
      // 프로덕션에서는 외부 로깅 서비스로 전송
      if (Environment.isProduction && level == LogLevel.error) {
        _sendToLoggingService(message, level, tag);
      }
    }
  }

  static bool _shouldLog(LogLevel level) {
    final envLevel = Environment.logLevel;
    return level.index >= envLevel.index;
  }

  static String _getColor(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return _cyan;
      case LogLevel.info:
        return _blue;
      case LogLevel.warning:
        return _yellow;
      case LogLevel.error:
        return _red;
      case LogLevel.none:
        return _white;
    }
  }

  static String _getEmoji(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '🔍';
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
      case LogLevel.none:
        return '';
    }
  }

  static void _sendToLoggingService(String message, LogLevel level, String? tag) {
    // TODO: 외부 로깅 서비스 연동 (예: Sentry, Firebase Crashlytics)
  }

  /// 디버그 로그
  static void debug(String message, {String? tag}) {
    _log(message, LogLevel.debug, tag: tag);
  }

  /// 정보 로그
  static void info(String message, {String? tag}) {
    _log(message, LogLevel.info, tag: tag);
  }

  /// 경고 로그
  static void warning(String message, {String? tag}) {
    _log(message, LogLevel.warning, tag: tag);
  }

  /// 에러 로그
  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(message, LogLevel.error, tag: tag);
    
    if (error != null) {
      _log('Error Object: $error', LogLevel.error, tag: tag);
    }
    
    if (stackTrace != null && Environment.enableDebugMode) {
      _log('Stack Trace:\n$stackTrace', LogLevel.error, tag: tag);
    }
  }

  /// 네트워크 요청 로그
  static void network(String message, {Map<String, dynamic>? data}) {
    if (Environment.enableDebugMode) {
      debug('[NETWORK] $message', tag: 'API');
      if (data != null) {
        debug('Data: ${_formatJson(data)}', tag: 'API');
      }
    }
  }

  /// 성능 측정 로그
  static void performance(String operation, Duration duration) {
    if (Environment.enableDebugMode) {
      info('[PERFORMANCE] $operation took ${duration.inMilliseconds}ms', tag: 'PERF');
    }
  }

  /// JSON 포맷팅
  static String _formatJson(Map<String, dynamic> json) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(json);
    } catch (e) {
      return json.toString();
    }
  }

  /// 구분선 출력
  static void divider({String? title}) {
    if (Environment.enableDebugMode) {
      if (title != null) {
        debug('═══════════════════ $title ═══════════════════');
      } else {
        debug('═══════════════════════════════════════════════');
      }
    }
  }
}

/// 성능 측정 헬퍼 클래스
class PerformanceLogger {
  final String operation;
  final Stopwatch _stopwatch;

  PerformanceLogger(this.operation) : _stopwatch = Stopwatch()..start();

  void stop() {
    _stopwatch.stop();
    Logger.performance(operation, _stopwatch.elapsed);
  }
}