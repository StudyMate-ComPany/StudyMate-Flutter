enum GoalType { daily, weekly, monthly, custom }
enum GoalStatus { active, completed, paused, cancelled, archived }

class StudyGoal {
  final String id;
  final String? subjectId;
  final String title;
  final String description;
  final String goalType;  // Store as string to match server
  final String status;    // Store as string to match server
  final DateTime startDate;
  final DateTime endDate;
  final int targetSummaries;
  final int targetQuizzes;
  final String targetStudyTime;  // Duration as string from server
  final int currentSummaries;
  final int currentQuizzes;
  final String currentStudyTime;  // Duration as string from server
  final DateTime? completedAt;
  final Map<String, dynamic>? progress;
  final int? daysRemaining;
  final bool isCompleted;
  final double progressPercentage;
  final DateTime createdAt;
  final DateTime updatedAt;

  StudyGoal({
    required this.id,
    this.subjectId,
    required this.title,
    required this.description,
    required this.goalType,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.targetSummaries,
    required this.targetQuizzes,
    required this.targetStudyTime,
    this.currentSummaries = 0,
    this.currentQuizzes = 0,
    this.currentStudyTime = "00:00:00",
    this.completedAt,
    this.progress,
    this.daysRemaining,
    this.isCompleted = false,
    this.progressPercentage = 0.0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StudyGoal.fromJson(Map<String, dynamic> json) {
    return StudyGoal(
      id: (json['id'] ?? '').toString(),
      subjectId: json['subject']?.toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      goalType: json['goal_type'] ?? 'custom',
      status: json['status'] ?? 'active',
      startDate: DateTime.tryParse(json['start_date'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['end_date'] ?? '') ?? DateTime.now(),
      targetSummaries: json['target_summaries'] ?? 0,
      targetQuizzes: json['target_quizzes'] ?? 0,
      targetStudyTime: json['target_study_time'] ?? "00:00:00",
      currentSummaries: json['current_summaries'] ?? 0,
      currentQuizzes: json['current_quizzes'] ?? 0,
      currentStudyTime: json['current_study_time'] ?? "00:00:00",
      completedAt: json['completed_at'] != null 
          ? DateTime.tryParse(json['completed_at']) 
          : null,
      progress: json['progress'],
      daysRemaining: json['days_remaining'],
      isCompleted: json['is_completed'] ?? false,
      progressPercentage: (json['progress_percentage'] ?? 0).toDouble(),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      if (subjectId != null) 'subject': subjectId,
      'title': title,
      'description': description,
      'goal_type': goalType,
      'status': status,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'target_summaries': targetSummaries,
      'target_quizzes': targetQuizzes,
      'target_study_time': targetStudyTime,
      'current_summaries': currentSummaries,
      'current_quizzes': currentQuizzes,
      'current_study_time': currentStudyTime,
      if (completedAt != null) 'completed_at': completedAt!.toIso8601String(),
    };
  }

  // Helper getters for backward compatibility
  GoalType get type => GoalType.values.firstWhere(
    (e) => e.name == goalType,
    orElse: () => GoalType.custom,
  );

  GoalStatus get statusEnum => GoalStatus.values.firstWhere(
    (e) => e.name == status,
    orElse: () => GoalStatus.active,
  );

  // Convert duration string to hours for display
  int get targetHours {
    try {
      final parts = targetStudyTime.split(' ');
      if (parts.length == 2) {
        // Format: "4 04:00:00" (days hours:minutes:seconds)
        final days = int.parse(parts[0]);
        final timeParts = parts[1].split(':');
        final hours = int.parse(timeParts[0]);
        return days * 24 + hours;
      } else {
        // Format: "04:00:00" (hours:minutes:seconds)
        final timeParts = targetStudyTime.split(':');
        return int.parse(timeParts[0]);
      }
    } catch (e) {
      return 0;
    }
  }

  int get completedHours {
    try {
      final parts = currentStudyTime.split(' ');
      if (parts.length == 2) {
        final days = int.parse(parts[0]);
        final timeParts = parts[1].split(':');
        final hours = int.parse(timeParts[0]);
        return days * 24 + hours;
      } else {
        final timeParts = currentStudyTime.split(':');
        return int.parse(timeParts[0]);
      }
    } catch (e) {
      return 0;
    }
  }

  double get progressForDisplay => progressPercentage;

  StudyGoal copyWith({
    dynamic id,
    String? subjectId,
    String? title,
    String? description,
    String? goalType,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int? targetSummaries,
    int? targetQuizzes,
    String? targetStudyTime,
    int? currentSummaries,
    int? currentQuizzes,
    String? currentStudyTime,
    DateTime? completedAt,
    Map<String, dynamic>? progress,
    int? daysRemaining,
    bool? isCompleted,
    double? progressPercentage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudyGoal(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      title: title ?? this.title,
      description: description ?? this.description,
      goalType: goalType ?? this.goalType,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      targetSummaries: targetSummaries ?? this.targetSummaries,
      targetQuizzes: targetQuizzes ?? this.targetQuizzes,
      targetStudyTime: targetStudyTime ?? this.targetStudyTime,
      currentSummaries: currentSummaries ?? this.currentSummaries,
      currentQuizzes: currentQuizzes ?? this.currentQuizzes,
      currentStudyTime: currentStudyTime ?? this.currentStudyTime,
      completedAt: completedAt ?? this.completedAt,
      progress: progress ?? this.progress,
      daysRemaining: daysRemaining ?? this.daysRemaining,
      isCompleted: isCompleted ?? this.isCompleted,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}