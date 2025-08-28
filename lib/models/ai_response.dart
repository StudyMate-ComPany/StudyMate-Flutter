enum AIResponseType { studyPlan, quiz, explanation, recommendation, feedback }

class AIResponse {
  final String id;
  final String userId;
  final AIResponseType type;
  final String query;
  final String response;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final double? confidence;
  final List<String>? tags;

  AIResponse({
    required this.id,
    required this.userId,
    required this.type,
    required this.query,
    required this.response,
    this.metadata,
    required this.createdAt,
    this.confidence,
    this.tags,
  });

  factory AIResponse.fromJson(Map<String, dynamic> json) {
    return AIResponse(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      type: AIResponseType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AIResponseType.explanation,
      ),
      query: json['query'] ?? '',
      response: json['response'] ?? '',
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      confidence: json['confidence']?.toDouble(),
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.name,
      'query': query,
      'response': response,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'confidence': confidence,
      'tags': tags,
    };
  }

  AIResponse copyWith({
    String? id,
    String? userId,
    AIResponseType? type,
    String? query,
    String? response,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    double? confidence,
    List<String>? tags,
  }) {
    return AIResponse(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      query: query ?? this.query,
      response: response ?? this.response,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      confidence: confidence ?? this.confidence,
      tags: tags ?? this.tags,
    );
  }
}