import 'package:flutter_test/flutter_test.dart';
import 'package:studymate_flutter/models/study_goal.dart';

void main() {
  group('StudyGoal Model Tests', () {
    test('should create StudyGoal from JSON', () {
      final json = {
        'id': 1,
        'title': '수학 마스터하기',
        'description': '고등학교 수학 완전 정복',
        'goal_type': 'monthly',
        'status': 'active',
        'start_date': '2024-01-01T00:00:00Z',
        'end_date': '2024-01-31T23:59:59Z',
        'target_summaries': 20,
        'target_quizzes': 15,
        'target_study_time': '30:00:00',
        'current_summaries': 5,
        'current_quizzes': 3,
        'current_study_time': '08:30:00',
        'created_at': '2024-01-01T00:00:00Z',
        'updated_at': '2024-01-15T12:00:00Z',
      };

      final goal = StudyGoal.fromJson(json);

      expect(goal.id, '1');
      expect(goal.title, '수학 마스터하기');
      expect(goal.description, '고등학교 수학 완전 정복');
      expect(goal.goalType, 'monthly');
      expect(goal.status, 'active');
      expect(goal.targetSummaries, 20);
      expect(goal.targetQuizzes, 15);
      expect(goal.currentSummaries, 5);
      expect(goal.currentQuizzes, 3);
    });

    test('should handle missing optional fields', () {
      final json = {
        'id': 2,
        'title': '영어 공부',
        'description': '토익 900점 달성',
        'goal_type': 'custom',
        'status': 'active',
        'start_date': '2024-01-01T00:00:00Z',
        'end_date': '2024-03-31T23:59:59Z',
        'target_summaries': 50,
        'target_quizzes': 30,
        'target_study_time': '100:00:00',
        'created_at': '2024-01-01T00:00:00Z',
        'updated_at': '2024-01-01T00:00:00Z',
      };

      final goal = StudyGoal.fromJson(json);

      expect(goal.id, '2');
      expect(goal.subjectId, null);
      expect(goal.currentSummaries, 0);
      expect(goal.currentQuizzes, 0);
      expect(goal.currentStudyTime, '00:00:00');
      expect(goal.completedAt, null);
    });

    test('should convert StudyGoal to JSON', () {
      final goal = StudyGoal(
        id: '3',
        title: '프로그래밍 학습',
        description: '파이썬 마스터',
        goalType: 'weekly',
        status: 'active',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 7),
        targetSummaries: 10,
        targetQuizzes: 5,
        targetStudyTime: '20:00:00',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 2),
      );

      final json = goal.toJson();

      expect(json['id'], '3');
      expect(json['title'], '프로그래밍 학습');
      expect(json['description'], '파이썬 마스터');
      expect(json['goal_type'], 'weekly');
      expect(json['status'], 'active');
      expect(json['target_summaries'], 10);
      expect(json['target_quizzes'], 5);
      expect(json['target_study_time'], '20:00:00');
    });

    test('should create copy with updated fields', () {
      final original = StudyGoal(
        id: '4',
        title: '원본 목표',
        description: '원본 설명',
        goalType: 'daily',
        status: 'active',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 1),
        targetSummaries: 5,
        targetQuizzes: 3,
        targetStudyTime: '02:00:00',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final updated = original.copyWith(
        title: '수정된 목표',
        status: 'completed',
        currentSummaries: 5,
        currentQuizzes: 3,
      );

      expect(updated.id, '4');
      expect(updated.title, '수정된 목표');
      expect(updated.description, '원본 설명');
      expect(updated.status, 'completed');
      expect(updated.currentSummaries, 5);
      expect(updated.currentQuizzes, 3);
      expect(original.title, '원본 목표'); // 원본은 변경되지 않음
    });

    test('should handle dynamic id types correctly', () {
      // Test with string ID
      final jsonWithStringId = {'id': 'abc123', 'title': 'Test'};
      final goalWithStringId = StudyGoal.fromJson({
        ...jsonWithStringId,
        'description': '',
        'goal_type': 'custom',
        'status': 'active',
        'start_date': '2024-01-01',
        'end_date': '2024-01-31',
        'target_summaries': 1,
        'target_quizzes': 1,
        'target_study_time': '01:00:00',
        'created_at': '2024-01-01',
        'updated_at': '2024-01-01',
      });
      expect(goalWithStringId.id, 'abc123');

      // Test with numeric ID
      final jsonWithNumericId = {'id': 456};
      final goalWithNumericId = StudyGoal.fromJson({
        ...jsonWithNumericId,
        'title': 'Test',
        'description': '',
        'goal_type': 'custom',
        'status': 'active',
        'start_date': '2024-01-01',
        'end_date': '2024-01-31',
        'target_summaries': 1,
        'target_quizzes': 1,
        'target_study_time': '01:00:00',
        'created_at': '2024-01-01',
        'updated_at': '2024-01-01',
      });
      expect(goalWithNumericId.id, '456');
    });
  });
}