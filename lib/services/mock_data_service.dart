import 'dart:math';
import '../models/user.dart';
import '../models/study_goal.dart';
import '../models/study_session.dart';
import '../models/ai_response.dart';

/// 개발 및 테스트용 모의 데이터 서비스
class MockDataService {
  static final _random = Random();
  
  // 모의 사용자 데이터
  static User getMockUser() {
    return User(
      id: 'user_${_random.nextInt(1000)}',
      email: 'test@studymate.com',
      name: '테스트 사용자',
      avatarUrl: null,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      lastLoginAt: DateTime.now(),
    );
  }
  
  // 모의 학습 목표 데이터
  static List<StudyGoal> getMockGoals() {
    return [
      StudyGoal(
        id: 'goal_1',
        title: '수학 마스터하기',
        description: '미적분학 완벽 정복',
        goalType: 'weekly',
        status: 'active',
        targetStudyTime: '10:00:00',
        currentStudyTime: '4:30:00',
        targetSummaries: 5,
        currentSummaries: 2,
        targetQuizzes: 3,
        currentQuizzes: 1,
        startDate: DateTime.now().subtract(const Duration(days: 7)),
        endDate: DateTime.now().add(const Duration(days: 7)),
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        updatedAt: DateTime.now(),
      ),
      StudyGoal(
        id: 'goal_2',
        title: '영어 단어 1000개',
        description: '토익 필수 단어 암기',
        goalType: 'monthly',
        status: 'active',
        targetStudyTime: '30:00:00',
        currentStudyTime: '12:00:00',
        targetSummaries: 10,
        currentSummaries: 4,
        targetQuizzes: 8,
        currentQuizzes: 3,
        startDate: DateTime.now().subtract(const Duration(days: 15)),
        endDate: DateTime.now().add(const Duration(days: 15)),
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now(),
      ),
      StudyGoal(
        id: 'goal_3',
        title: '물리학 기초',
        description: '뉴턴 역학 이해하기',
        goalType: 'daily',
        status: 'completed',
        targetStudyTime: '2:00:00',
        currentStudyTime: '2:00:00',
        targetSummaries: 1,
        currentSummaries: 1,
        targetQuizzes: 1,
        currentQuizzes: 1,
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now().subtract(const Duration(days: 1)),
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now(),
      ),
    ];
  }
  
  // 모의 학습 세션 데이터
  static List<StudySession> getMockSessions() {
    return [
      StudySession(
        id: 'session_1',
        userId: 'user_1',
        goalId: 'goal_1',
        subject: '수학',
        topic: '미분',
        type: SessionType.focused,
        plannedDuration: 60,
        actualDuration: 55,
        status: SessionStatus.completed,
        startTime: DateTime.now().subtract(const Duration(hours: 2)),
        endTime: DateTime.now().subtract(const Duration(hours: 1)),
        notes: '체인 룰과 곱의 미분법 학습 완료',
      ),
      StudySession(
        id: 'session_2',
        userId: 'user_1',
        goalId: 'goal_2',
        subject: '영어',
        topic: '필수 단어',
        type: SessionType.review,
        plannedDuration: 30,
        actualDuration: 25,
        status: SessionStatus.completed,
        startTime: DateTime.now().subtract(const Duration(hours: 5)),
        endTime: DateTime.now().subtract(const Duration(hours: 4, minutes: 30)),
        notes: 'Part 5 빈출 단어 50개 복습',
      ),
      StudySession(
        id: 'session_3',
        userId: 'user_1',
        goalId: null,
        subject: '화학',
        topic: '주기율표',
        type: SessionType.practice,
        plannedDuration: 45,
        actualDuration: 40,
        status: SessionStatus.completed,
        startTime: DateTime.now().subtract(const Duration(days: 1)),
        endTime: DateTime.now().subtract(const Duration(days: 1)).add(const Duration(minutes: 40)),
        notes: '원소 기호와 원자량 암기',
      ),
    ];
  }
  
  // 모의 AI 응답 생성
  static AIResponse getMockAIResponse(String query, AIResponseType type) {
    String response = '';
    Map<String, dynamic> metadata = {};
    
    switch (type) {
      case AIResponseType.studyPlan:
        response = '''
📚 맞춤형 학습 계획

1. **기초 다지기 (1-2주)**
   - 기본 개념 이해
   - 핵심 용어 정리
   - 예제 문제 풀이

2. **심화 학습 (3-4주)**
   - 응용 문제 해결
   - 실전 문제 연습
   - 오답 노트 작성

3. **마무리 정리 (5주)**
   - 전체 내용 복습
   - 모의고사 실시
   - 약점 보완
        ''';
        metadata = {
          'estimated_time': '5주',
          'difficulty': '중급',
          'resources': ['교재', '온라인 강의', '문제집'],
        };
        break;
        
      case AIResponseType.quiz:
        response = '''
🎯 퀴즈 문제

**문제 1**: 미분의 기본 정의는 무엇인가요?
a) 함수의 순간 변화율
b) 함수의 평균 변화율
c) 함수의 적분값
d) 함수의 극값

**문제 2**: f(x) = x²의 도함수는?
a) 2x
b) x²/2
c) x³/3
d) 2

**문제 3**: 연쇄 법칙(Chain Rule)은 언제 사용하나요?
a) 합성함수를 미분할 때
b) 곱셈을 미분할 때
c) 나눗셈을 미분할 때
d) 상수를 미분할 때

**정답**: 1-a, 2-a, 3-a
        ''';
        metadata = {
          'question_count': 3,
          'difficulty': '기초',
          'topic': '미분',
        };
        break;
        
      case AIResponseType.explanation:
        response = '''
💡 개념 설명

**미분(Differentiation)**은 함수의 순간 변화율을 구하는 수학적 방법입니다.

예를 들어, 자동차의 위치를 시간에 대한 함수로 나타낸다면:
- 위치 함수를 미분하면 → 속도
- 속도를 미분하면 → 가속도

미분의 기호: f'(x), dy/dx, d/dx[f(x)]

실생활 활용:
- 경제학: 한계비용, 한계수익 계산
- 물리학: 속도, 가속도 계산
- 공학: 최적화 문제 해결
        ''';
        metadata = {
          'concept': '미분',
          'difficulty': '기초',
          'examples': 3,
        };
        break;
        
      case AIResponseType.recommendation:
        response = '''
🎯 학습 추천

당신의 학습 패턴을 분석한 결과:

**강점**:
- 오전 시간대 집중력이 높음
- 문제 해결 능력 우수
- 꾸준한 학습 습관

**개선 필요**:
- 복습 주기가 불규칙함
- 오답 정리 미흡

**추천 사항**:
1. 매일 30분 복습 시간 확보
2. 오답 노트 작성 습관화
3. 주 1회 전체 내용 정리
        ''';
        metadata = {
          'analysis_period': '최근 2주',
          'improvement_areas': 2,
        };
        break;
        
      case AIResponseType.feedback:
        response = '''
📊 학습 피드백

**오늘의 학습 분석**:
- 총 학습 시간: 2시간 15분
- 완료한 주제: 3개
- 정답률: 85%

**잘한 점**:
✅ 목표 시간 달성
✅ 집중도 높음
✅ 노트 정리 우수

**개선할 점**:
⚠️ 어려운 문제 회피 경향
⚠️ 휴식 시간 부족

**내일 추천**:
- 어려운 문제 최소 2개 도전
- 50분 학습 후 10분 휴식
        ''';
        metadata = {
          'session_score': 85,
          'productivity': 'high',
        };
        break;
    }
    
    return AIResponse(
      id: 'ai_response_${_random.nextInt(10000)}',
      userId: 'user_1',
      query: query,
      response: response,
      type: type,
      metadata: metadata,
      createdAt: DateTime.now(),
    );
  }
  
  // 통계 데이터 생성
  static Map<String, dynamic> getMockStatistics() {
    return {
      'todayHours': _random.nextInt(5) + 1,
      'weekHours': _random.nextInt(20) + 10,
      'monthHours': _random.nextInt(100) + 50,
      'completedGoals': _random.nextInt(10) + 5,
      'activeGoals': _random.nextInt(5) + 1,
      'totalSessions': _random.nextInt(50) + 20,
      'streak': _random.nextInt(30) + 1,
      'averageSessionDuration': _random.nextInt(60) + 30,
      'mostStudiedSubject': ['수학', '영어', '과학', '역사'][_random.nextInt(4)],
      'productivityScore': _random.nextInt(30) + 70,
    };
  }
  
  // 대시보드 데이터 생성
  static Map<String, dynamic> getMockDashboardData() {
    return {
      'greeting': '오늘도 화이팅! 💪',
      'todayGoal': '수학 2시간 학습',
      'progress': {
        'daily': 75,
        'weekly': 60,
        'monthly': 45,
      },
      'recentAchievements': [
        '🏆 연속 7일 학습',
        '🎯 주간 목표 달성',
        '📚 100문제 해결',
      ],
      'upcomingTasks': [
        '오후 3시: 영어 단어 복습',
        '오후 5시: 수학 문제 풀이',
        '저녁 8시: 하루 정리',
      ],
    };
  }
}