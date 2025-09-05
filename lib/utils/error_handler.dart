import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../config/environment.dart';
import 'logger.dart';

/// 전역 에러 처리 클래스
class ErrorHandler {
  static final _instance = ErrorHandler._internal();
  factory ErrorHandler() => _instance;
  ErrorHandler._internal();

  /// 에러 타입 분류
  static ErrorType classifyError(dynamic error) {
    if (error is DioException) {
      return _classifyDioError(error);
    } else if (error is FormatException) {
      return ErrorType.parsing;
    } else if (error is TypeError) {
      return ErrorType.type;
    } else if (error is RangeError) {
      return ErrorType.range;
    } else if (error is NoSuchMethodError) {
      return ErrorType.methodNotFound;
    } else {
      return ErrorType.unknown;
    }
  }

  /// Dio 에러 분류
  static ErrorType _classifyDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ErrorType.timeout;
      case DioExceptionType.connectionError:
        return ErrorType.network;
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 0;
        if (statusCode >= 400 && statusCode < 500) {
          if (statusCode == 401) return ErrorType.unauthorized;
          if (statusCode == 403) return ErrorType.forbidden;
          if (statusCode == 404) return ErrorType.notFound;
          return ErrorType.badRequest;
        } else if (statusCode >= 500) {
          return ErrorType.server;
        }
        return ErrorType.unknown;
      case DioExceptionType.cancel:
        return ErrorType.cancelled;
      default:
        return ErrorType.unknown;
    }
  }

  /// 사용자 친화적인 에러 메시지 생성
  static String getUserFriendlyMessage(dynamic error) {
    final errorType = classifyError(error);
    
    switch (errorType) {
      case ErrorType.network:
        return '네트워크 연결을 확인해주세요.';
      case ErrorType.timeout:
        return '요청 시간이 초과되었습니다. 다시 시도해주세요.';
      case ErrorType.unauthorized:
        return '로그인이 필요합니다.';
      case ErrorType.forbidden:
        return '접근 권한이 없습니다.';
      case ErrorType.notFound:
        return '요청한 정보를 찾을 수 없습니다.';
      case ErrorType.badRequest:
        return '잘못된 요청입니다. 입력 정보를 확인해주세요.';
      case ErrorType.server:
        return '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
      case ErrorType.parsing:
        return '데이터 처리 중 오류가 발생했습니다.';
      case ErrorType.type:
        return '데이터 형식 오류가 발생했습니다.';
      case ErrorType.cancelled:
        return '요청이 취소되었습니다.';
      default:
        return '오류가 발생했습니다. 다시 시도해주세요.';
    }
  }

  /// 개발자용 상세 에러 정보
  static Map<String, dynamic> getDetailedErrorInfo(dynamic error, [StackTrace? stackTrace]) {
    final info = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'environment': Environment.env,
      'errorType': classifyError(error).toString(),
      'message': error.toString(),
    };

    if (error is DioException) {
      info['dioError'] = {
        'type': error.type.toString(),
        'message': error.message,
        'path': error.requestOptions.path,
        'method': error.requestOptions.method,
        'statusCode': error.response?.statusCode,
        'responseData': error.response?.data,
      };
    }

    if (stackTrace != null && Environment.enableDebugMode) {
      info['stackTrace'] = stackTrace.toString();
    }

    return info;
  }

  /// 에러 리포팅
  static Future<void> reportError(dynamic error, [StackTrace? stackTrace]) async {
    final errorInfo = getDetailedErrorInfo(error, stackTrace);
    
    // 로그 출력
    Logger.error(
      'Error occurred',
      error: error,
      stackTrace: stackTrace,
      tag: 'ErrorHandler',
    );

    // 개발 환경에서는 상세 정보 출력
    if (Environment.enableDebugMode) {
      Logger.debug('Error Details: ${errorInfo.toString()}', tag: 'ErrorHandler');
    }

    // 프로덕션/스테이징에서는 외부 서비스로 전송
    if (Environment.enableErrorReporting) {
      await _sendToErrorReportingService(errorInfo);
    }
  }

  /// 외부 에러 리포팅 서비스로 전송
  static Future<void> _sendToErrorReportingService(Map<String, dynamic> errorInfo) async {
    // TODO: Sentry, Firebase Crashlytics 등 연동
    // 예시:
    // await Sentry.captureException(
    //   errorInfo['error'],
    //   stackTrace: errorInfo['stackTrace'],
    //   withScope: (scope) {
    //     scope.setContexts('error_details', errorInfo);
    //   },
    // );
  }

  /// 전역 에러 핸들러 설정
  static void setupGlobalErrorHandlers() {
    // Flutter 에러 핸들러
    FlutterError.onError = (FlutterErrorDetails details) {
      Logger.error(
        'Flutter Error',
        error: details.exception,
        stackTrace: details.stack,
        tag: 'Flutter',
      );
      
      if (Environment.enableErrorReporting) {
        reportError(details.exception, details.stack);
      }
    };

    // Zone 에러 핸들러
    PlatformDispatcher.instance.onError = (error, stack) {
      Logger.error(
        'Uncaught Error',
        error: error,
        stackTrace: stack,
        tag: 'Platform',
      );
      
      if (Environment.enableErrorReporting) {
        reportError(error, stack);
      }
      
      return true;
    };
  }

  /// 에러 다이얼로그 표시
  static void showErrorDialog(BuildContext context, dynamic error, {VoidCallback? onRetry}) {
    final message = getUserFriendlyMessage(error);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('오류 발생'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            if (Environment.enableDebugMode) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  error.toString(),
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text('다시 시도'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  /// 에러 스낵바 표시
  static void showErrorSnackBar(BuildContext context, dynamic error) {
    final message = getUserFriendlyMessage(error);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: '닫기',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }
}

/// 에러 타입 열거형
enum ErrorType {
  network,
  timeout,
  unauthorized,
  forbidden,
  notFound,
  badRequest,
  server,
  parsing,
  type,
  range,
  methodNotFound,
  cancelled,
  unknown,
}

/// Try-Catch 래퍼 확장
extension ErrorHandlingExtension<T> on Future<T> {
  /// 에러 처리를 포함한 Future 실행
  Future<T?> withErrorHandling({
    required BuildContext context,
    bool showDialog = false,
    bool showSnackBar = true,
    VoidCallback? onRetry,
  }) async {
    try {
      return await this;
    } catch (error, stackTrace) {
      ErrorHandler.reportError(error, stackTrace);
      
      if (context.mounted) {
        if (showDialog) {
          ErrorHandler.showErrorDialog(context, error, onRetry: onRetry);
        } else if (showSnackBar) {
          ErrorHandler.showErrorSnackBar(context, error);
        }
      }
      
      return null;
    }
  }
}