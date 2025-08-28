import 'package:flutter/foundation.dart';

enum PlanStatus { active, paused, completed, cancelled }
enum PlanType { free, basic, premium, pro }

class LearningPlan {
  final String id;
  final String userId;
  final String goal; // "한국사능력검정시험 1급 한달 합격"
  final String subject; // "한국사"
  final String level; // "1급"
  final int durationDays; // 30
  final DateTime startDate;
  final DateTime endDate;
  final PlanStatus status;
  final PlanType planType;
  final Map<String, dynamic> curriculum; // AI가 생성한 커리큘럼
  final List<DailyTask> dailyTasks;
  final Map<String, dynamic>? metadata;
  
  LearningPlan({
    required this.id,
    required this.userId,
    required this.goal,
    required this.subject,
    required this.level,
    required this.durationDays,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.planType,
    required this.curriculum,
    required this.dailyTasks,
    this.metadata,
  });
  
  factory LearningPlan.fromJson(Map<String, dynamic> json) {
    return LearningPlan(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      goal: json['goal'] ?? '',
      subject: json['subject'] ?? '',
      level: json['level'] ?? '',
      durationDays: json['duration_days'] ?? 30,
      startDate: DateTime.tryParse(json['start_date'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['end_date'] ?? '') ?? DateTime.now().add(const Duration(days: 30)),
      status: PlanStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PlanStatus.active,
      ),
      planType: PlanType.values.firstWhere(
        (e) => e.name == json['plan_type'],
        orElse: () => PlanType.free,
      ),
      curriculum: json['curriculum'] ?? {},
      dailyTasks: (json['daily_tasks'] as List?)
          ?.map((e) => DailyTask.fromJson(e))
          .toList() ?? [],
      metadata: json['metadata'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'goal': goal,
      'subject': subject,
      'level': level,
      'duration_days': durationDays,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'status': status.name,
      'plan_type': planType.name,
      'curriculum': curriculum,
      'daily_tasks': dailyTasks.map((e) => e.toJson()).toList(),
      'metadata': metadata,
    };
  }
  
  double get progressPercentage {
    final totalDays = endDate.difference(startDate).inDays;
    final elapsedDays = DateTime.now().difference(startDate).inDays;
    return (elapsedDays / totalDays * 100).clamp(0, 100);
  }
  
  int get daysRemaining {
    return endDate.difference(DateTime.now()).inDays.clamp(0, durationDays);
  }
  
  DailyTask? get todayTask {
    final today = DateTime.now();
    return dailyTasks.firstWhereOrNull(
      (task) => task.date.year == today.year && 
                task.date.month == today.month && 
                task.date.day == today.day
    );
  }
}

class DailyTask {
  final String id;
  final String planId;
  final DateTime date;
  final String title;
  final String description;
  final List<String> topics; // 오늘 학습할 주제들
  final StudyContent morningContent; // 오전 9시
  final StudyContent afternoonContent; // 오후 12시
  final StudyContent eveningContent; // 저녁 9시
  final bool isCompleted;
  final Map<String, bool> completionStatus; // morning, afternoon, evening
  
  DailyTask({
    required this.id,
    required this.planId,
    required this.date,
    required this.title,
    required this.description,
    required this.topics,
    required this.morningContent,
    required this.afternoonContent,
    required this.eveningContent,
    this.isCompleted = false,
    required this.completionStatus,
  });
  
  factory DailyTask.fromJson(Map<String, dynamic> json) {
    return DailyTask(
      id: json['id'] ?? '',
      planId: json['plan_id'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      topics: List<String>.from(json['topics'] ?? []),
      morningContent: StudyContent.fromJson(json['morning_content'] ?? {}),
      afternoonContent: StudyContent.fromJson(json['afternoon_content'] ?? {}),
      eveningContent: StudyContent.fromJson(json['evening_content'] ?? {}),
      isCompleted: json['is_completed'] ?? false,
      completionStatus: Map<String, bool>.from(json['completion_status'] ?? {
        'morning': false,
        'afternoon': false,
        'evening': false,
      }),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plan_id': planId,
      'date': date.toIso8601String(),
      'title': title,
      'description': description,
      'topics': topics,
      'morning_content': morningContent.toJson(),
      'afternoon_content': afternoonContent.toJson(),
      'evening_content': eveningContent.toJson(),
      'is_completed': isCompleted,
      'completion_status': completionStatus,
    };
  }
  
  double get completionPercentage {
    int completed = 0;
    if (completionStatus['morning'] == true) completed++;
    if (completionStatus['afternoon'] == true) completed++;
    if (completionStatus['evening'] == true) completed++;
    return (completed / 3 * 100);
  }
}

class StudyContent {
  final String type; // 'summary' or 'quiz'
  final String title;
  final String content; // 요약 내용 or 퀴즈 문제들
  final List<QuizQuestion>? questions; // 퀴즈인 경우
  final int estimatedMinutes;
  final String? notificationId; // 알림 ID
  
  StudyContent({
    required this.type,
    required this.title,
    required this.content,
    this.questions,
    required this.estimatedMinutes,
    this.notificationId,
  });
  
  factory StudyContent.fromJson(Map<String, dynamic> json) {
    return StudyContent(
      type: json['type'] ?? 'summary',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      questions: json['questions'] != null
          ? (json['questions'] as List)
              .map((e) => QuizQuestion.fromJson(e))
              .toList()
          : null,
      estimatedMinutes: json['estimated_minutes'] ?? 10,
      notificationId: json['notification_id'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'title': title,
      'content': content,
      'questions': questions?.map((e) => e.toJson()).toList(),
      'estimated_minutes': estimatedMinutes,
      'notification_id': notificationId,
    };
  }
}

class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String explanation;
  
  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });
  
  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] ?? '',
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correct_answer'] ?? 0,
      explanation: json['explanation'] ?? '',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correct_answer': correctAnswer,
      'explanation': explanation,
    };
  }
}

extension IterableExtension<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E) test) {
    for (E element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}