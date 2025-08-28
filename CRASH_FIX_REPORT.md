# 앱 크래시 문제 분석 및 해결 보고서

## 문제 현상
- Android 에뮬레이터에서 앱 실행 시 SystemUI 크래시 발생
- 에뮬레이터 자체가 불안정하여 계속 재시작됨
- 메모리 부족으로 인한 시스템 서비스 크래시

## 원인 분석

### 1. 메모리 문제
```
I/udymate_flutter( 5191): Background concurrent mark compact GC freed 2032KB AllocSpace bytes
W/udymate_flutter( 5191): Suspending all threads took: 889.144ms
```
- Garbage Collection이 자주 발생
- 스레드 중단 시간이 매우 길음 (889ms)

### 2. SystemUI 크래시
```
Process com.android.systemui (pid 5024) has died
Scheduling restart of crashed service com.android.systemui
```
- SystemUI 프로세스가 계속 죽고 재시작됨
- 에뮬레이터 메모리 부족이 주 원인

### 3. UI 렌더링 문제
```
I/Choreographer( 5191): Skipped 88 frames! The application may be doing too much work on its main thread.
```
- 메인 스레드에서 과도한 작업 수행
- 프레임 드롭으로 인한 UI 렉

## 해결 방안

### 1. 즉시 적용 가능한 해결책

#### A. 웹 버전으로 실행 (완료)
```bash
flutter run -d chrome --web-renderer html
```
- 가장 안정적인 테스트 환경
- 메모리 문제 없음

#### B. 에뮬레이터 메모리 증가
Android Studio에서:
1. AVD Manager 열기
2. 에뮬레이터 편집
3. Advanced Settings > Memory and Storage
4. RAM을 4096MB 이상으로 설정

### 2. 앱 최적화

#### A. 애니메이션 최적화
- flutter_animate 사용 최소화
- 동시 실행 애니메이션 줄이기
- 복잡한 그라데이션 애니메이션 제거

#### B. 이미지 및 리소스 최적화
- 이미지 캐싱 구현
- lazy loading 적용
- 불필요한 위젯 rebuild 방지

#### C. 메모리 관리
- Provider 사용 시 dispose 확실히 하기
- StreamController 정리
- 불필요한 listener 제거

### 3. 코드 수정 사항

#### 로그인 화면 애니메이션 간소화
```dart
// 기존: 복잡한 애니메이션
AnimatedBuilder(
  animation: _animationController,
  builder: (context, child) {
    // 복잡한 그라데이션 애니메이션
  }
)

// 개선: 간단한 애니메이션
Container(
  decoration: BoxDecoration(
    gradient: AppTheme.primaryGradient, // 정적 그라데이션
  )
)
```

#### 메모리 누수 방지
```dart
@override
void dispose() {
  _controller.dispose();
  _animationController.dispose();
  _focusNode.dispose();
  super.dispose();
}
```

## 테스트 방법

### 1. 웹 테스트 (권장)
```bash
flutter run -d chrome
```

### 2. 실제 기기 테스트
실제 Android 기기를 USB로 연결하여 테스트

### 3. 에뮬레이터 테스트
- 메모리 설정 증가 후 재시도
- Cold Boot으로 에뮬레이터 시작

## 결론
- 현재 웹 버전은 정상 작동
- 에뮬레이터는 메모리 부족 문제
- 앱 최적화 필요 (애니메이션, 메모리 관리)
- 실제 기기에서는 문제없을 가능성 높음