import 'dart:async';
import 'package:flutter/foundation.dart';
import 'api_service.dart';
import '../utils/logger.dart';

/// API 연결 상태를 모니터링하는 서비스
class ApiMonitor extends ChangeNotifier {
  static final ApiMonitor _instance = ApiMonitor._internal();
  factory ApiMonitor() => _instance;
  ApiMonitor._internal();

  final ApiService _apiService = ApiService();
  
  ConnectionStatus _status = ConnectionStatus.unknown;
  String? _lastError;
  DateTime? _lastCheckTime;
  Timer? _monitorTimer;
  
  // 모니터링 통계
  int _totalChecks = 0;
  int _successfulChecks = 0;
  int _failedChecks = 0;
  double _averageResponseTime = 0;
  
  ConnectionStatus get status => _status;
  String? get lastError => _lastError;
  DateTime? get lastCheckTime => _lastCheckTime;
  bool get isConnected => _status == ConnectionStatus.connected;
  
  // 통계 getter
  int get totalChecks => _totalChecks;
  int get successfulChecks => _successfulChecks;
  int get failedChecks => _failedChecks;
  double get averageResponseTime => _averageResponseTime;
  double get successRate => _totalChecks > 0 ? (_successfulChecks / _totalChecks * 100) : 0;

  /// 모니터링 시작
  void startMonitoring({Duration interval = const Duration(seconds: 30)}) {
    Logger.info('API 모니터링 시작 (간격: ${interval.inSeconds}초)');
    
    // 즉시 한 번 체크
    checkConnection();
    
    // 주기적 체크
    _monitorTimer?.cancel();
    _monitorTimer = Timer.periodic(interval, (_) {
      checkConnection();
    });
  }

  /// 모니터링 중지
  void stopMonitoring() {
    Logger.info('API 모니터링 중지');
    _monitorTimer?.cancel();
    _monitorTimer = null;
  }

  /// 연결 상태 체크
  Future<void> checkConnection() async {
    final stopwatch = Stopwatch()..start();
    
    try {
      _status = ConnectionStatus.checking;
      notifyListeners();
      
      // API 헬스 체크 시도
      await _apiService.testHealth();
      
      stopwatch.stop();
      _updateStatistics(true, stopwatch.elapsedMilliseconds);
      
      _status = ConnectionStatus.connected;
      _lastError = null;
      _lastCheckTime = DateTime.now();
      
      Logger.debug('API 연결 성공 (응답시간: ${stopwatch.elapsedMilliseconds}ms)');
    } catch (e) {
      stopwatch.stop();
      _updateStatistics(false, stopwatch.elapsedMilliseconds);
      
      _status = ConnectionStatus.disconnected;
      _lastError = e.toString();
      _lastCheckTime = DateTime.now();
      
      Logger.warning('API 연결 실패: $e');
      
      // 재시도 로직
      if (_failedChecks > 3) {
        _status = ConnectionStatus.error;
        Logger.error('API 연결 지속적 실패 (${_failedChecks}회)');
      }
    } finally {
      notifyListeners();
    }
  }

  /// 통계 업데이트
  void _updateStatistics(bool success, int responseTime) {
    _totalChecks++;
    
    if (success) {
      _successfulChecks++;
    } else {
      _failedChecks++;
    }
    
    // 평균 응답 시간 계산 (성공한 요청만)
    if (success) {
      if (_averageResponseTime == 0) {
        _averageResponseTime = responseTime.toDouble();
      } else {
        _averageResponseTime = 
          ((_averageResponseTime * (_successfulChecks - 1)) + responseTime) / _successfulChecks;
      }
    }
  }

  /// 통계 초기화
  void resetStatistics() {
    _totalChecks = 0;
    _successfulChecks = 0;
    _failedChecks = 0;
    _averageResponseTime = 0;
    notifyListeners();
  }

  /// 상태에 따른 메시지 반환
  String getStatusMessage() {
    switch (_status) {
      case ConnectionStatus.connected:
        return 'API 서버와 정상 연결됨';
      case ConnectionStatus.disconnected:
        return 'API 서버와 연결할 수 없음';
      case ConnectionStatus.checking:
        return '연결 상태 확인 중...';
      case ConnectionStatus.error:
        return 'API 연결 오류 발생';
      case ConnectionStatus.unknown:
        return '연결 상태 알 수 없음';
    }
  }

  /// 상태에 따른 색상 반환
  @override
  void dispose() {
    stopMonitoring();
    super.dispose();
  }
}

/// 연결 상태 열거형
enum ConnectionStatus {
  connected,    // 연결됨
  disconnected, // 연결 끊김
  checking,     // 확인 중
  error,        // 오류
  unknown,      // 알 수 없음
}