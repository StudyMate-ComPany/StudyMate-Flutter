# Flutter Development Agents

Flutter 개발을 위한 전문 AI 에이전트 시스템입니다.

## 설치된 에이전트 목록

1. **flutter-developer** - Flutter 앱 개발 및 위젯 생성
2. **flutter-analyzer** - Dart 코드 분석 및 최적화
3. **flutter-tester** - 단위/위젯/통합 테스트 실행
4. **flutter-builder** - iOS/Android 빌드 및 배포
5. **flutter-debugger** - 디버깅 및 성능 프로파일링
6. **flutter-state-manager** - Provider/Riverpod/Bloc 상태 관리
7. **flutter-ui-designer** - UI/UX 디자인 및 애니메이션
8. **flutter-package-manager** - pub.dev 패키지 관리
9. **flutter-performance-optimizer** - 성능 최적화 및 메모리 관리
10. **flutter-migration-assistant** - Flutter 버전 업그레이드 지원

## 사용 방법

### 에이전트 목록 확인
```bash
./agents list
```

### 특정 에이전트 정보 확인
```bash
./agents show flutter-developer
```

### 에이전트 사용 가이드
```bash
./agents use flutter-tester
```

### 키워드로 에이전트 검색
```bash
./agents search state
```

## 에이전트 활용 예시

### Flutter 개발
```
"flutter-developer 에이전트를 사용하여 커스텀 애니메이션 위젯을 만들어주세요"
```

### 코드 분석
```
"flutter-analyzer로 이 위젯의 성능 문제를 분석해주세요"
```

### 테스트 작성
```
"flutter-tester를 사용하여 이 Provider의 단위 테스트를 작성해주세요"
```

### 빌드 및 배포
```
"flutter-builder로 Android 릴리즈 APK를 빌드하는 방법을 알려주세요"
```

### 디버깅
```
"flutter-debugger로 setState가 UI를 업데이트하지 않는 문제를 디버깅해주세요"
```

### 상태 관리
```
"flutter-state-manager를 사용하여 Provider에서 Riverpod로 마이그레이션하는 방법을 보여주세요"
```

### UI 디자인
```
"flutter-ui-designer로 커스텀 네비게이션 드로어를 만들어주세요"
```

### 패키지 관리
```
"flutter-package-manager로 이미지 캐싱을 위한 최적의 패키지를 추천해주세요"
```

### 성능 최적화
```
"flutter-performance-optimizer로 ListView의 성능을 개선해주세요"
```

### 버전 업그레이드
```
"flutter-migration-assistant로 Flutter 3.x로 업그레이드하는 방법을 안내해주세요"
```

## 에이전트 구조

각 에이전트는 다음 정보를 포함합니다:

- **identifier**: 고유 식별자
- **name**: 에이전트 이름
- **version**: 버전 정보
- **description**: 설명
- **whenToUse**: 사용 시점 가이드
- **examples**: 사용 예시
- **systemPrompt**: 시스템 프롬프트
- **capabilities**: 제공 기능
- **tags**: 관련 태그

## 추가 정보

- 각 에이전트는 Flutter 개발의 특정 영역에 특화되어 있습니다
- 여러 에이전트를 조합하여 복잡한 작업을 수행할 수 있습니다
- 에이전트는 지속적으로 업데이트되고 개선됩니다

## 문제 해결

에이전트가 제대로 작동하지 않는 경우:

1. Dart SDK가 설치되어 있는지 확인
2. `./agents` 파일에 실행 권한이 있는지 확인
3. `.agents` 디렉토리에 JSON 파일들이 있는지 확인

```bash
chmod +x ./agents
dart run .agents/agents_cli.dart list
```