enum SessionType { focused, break_, review, practice, reading, group }
enum SessionStatus { active, paused, completed, cancelled }

class StudySession {
  final String id;
  final String userId;
  final String? goalId;
  final String subject;
  final String? topic;
  final SessionType type;
  final SessionStatus status;
  final DateTime startTime;
  final DateTime? endTime;
  final int plannedDuration; // in minutes
  final int? actualDuration; // in minutes
  final String? notes;
  final int? focusScore;
  final Map<String, dynamic>? metadata;

  StudySession({
    required this.id,
    required this.userId,
    this.goalId,
    required this.subject,
    this.topic,
    required this.type,
    required this.status,
    required this.startTime,
    this.endTime,
    required this.plannedDuration,
    this.actualDuration,
    this.notes,
    this.focusScore,
    this.metadata,
  });

  factory StudySession.fromJson(Map<String, dynamic> json) {
    return StudySession(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      goalId: json['goal_id'],
      subject: json['subject'] ?? '',
      topic: json['topic'],
      type: SessionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SessionType.focused,
      ),
      status: SessionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SessionStatus.active,
      ),
      startTime: DateTime.tryParse(json['start_time'] ?? '') ?? DateTime.now(),
      endTime: json['end_time'] != null 
          ? DateTime.tryParse(json['end_time']) 
          : null,
      plannedDuration: json['planned_duration'] ?? 0,
      actualDuration: json['actual_duration'],
      notes: json['notes'],
      focusScore: json['focus_score'],
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'goal_id': goalId,
      'subject': subject,
      'topic': topic,
      'type': type.name,
      'status': status.name,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'planned_duration': plannedDuration,
      'actual_duration': actualDuration,
      'notes': notes,
      'focus_score': focusScore,
      'metadata': metadata,
    };
  }

  Duration get elapsed {
    if (endTime != null) {
      return endTime!.difference(startTime);
    }
    return DateTime.now().difference(startTime);
  }

  bool get isActive => status == SessionStatus.active;
  bool get isPaused => status == SessionStatus.paused;
  bool get isCompleted => status == SessionStatus.completed;

  StudySession copyWith({
    String? id,
    String? userId,
    String? goalId,
    String? subject,
    String? topic,
    SessionType? type,
    SessionStatus? status,
    DateTime? startTime,
    DateTime? endTime,
    int? plannedDuration,
    int? actualDuration,
    String? notes,
    int? focusScore,
    Map<String, dynamic>? metadata,
  }) {
    return StudySession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      goalId: goalId ?? this.goalId,
      subject: subject ?? this.subject,
      topic: topic ?? this.topic,
      type: type ?? this.type,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      plannedDuration: plannedDuration ?? this.plannedDuration,
      actualDuration: actualDuration ?? this.actualDuration,
      notes: notes ?? this.notes,
      focusScore: focusScore ?? this.focusScore,
      metadata: metadata ?? this.metadata,
    );
  }
}