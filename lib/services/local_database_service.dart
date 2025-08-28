import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/study_goal.dart';
import '../models/study_session.dart';
import '../models/ai_response.dart';
import '../models/user.dart';

/// 로컬 SQLite 데이터베이스 서비스
class LocalDatabaseService {
  static Database? _database;
  static const String _dbName = 'studymate.db';
  static const int _dbVersion = 1;

  /// 데이터베이스 인스턴스 가져오기
  static Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// 데이터베이스 초기화
  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// 테이블 생성
  static Future<void> _onCreate(Database db, int version) async {
    // 사용자 테이블
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        email TEXT NOT NULL,
        name TEXT NOT NULL,
        bio TEXT,
        avatar_url TEXT,
        created_at TEXT NOT NULL,
        last_login_at TEXT,
        preferences TEXT,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // 학습 목표 테이블
    await db.execute('''
      CREATE TABLE study_goals (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        target_date TEXT,
        category TEXT,
        priority INTEGER DEFAULT 1,
        status TEXT DEFAULT 'active',
        progress REAL DEFAULT 0.0,
        created_at TEXT NOT NULL,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        is_synced INTEGER DEFAULT 0
      )
    ''');

    // 학습 세션 테이블
    await db.execute('''
      CREATE TABLE study_sessions (
        id TEXT PRIMARY KEY,
        goal_id TEXT,
        start_time TEXT NOT NULL,
        end_time TEXT,
        duration INTEGER DEFAULT 0,
        notes TEXT,
        focus_score REAL,
        created_at TEXT NOT NULL,
        is_synced INTEGER DEFAULT 0,
        FOREIGN KEY (goal_id) REFERENCES study_goals (id)
      )
    ''');

    // AI 응답 테이블
    await db.execute('''
      CREATE TABLE ai_responses (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        type TEXT NOT NULL,
        query TEXT NOT NULL,
        response TEXT NOT NULL,
        metadata TEXT,
        confidence REAL,
        tags TEXT,
        created_at TEXT NOT NULL,
        is_synced INTEGER DEFAULT 0
      )
    ''');

    // 통계 캐시 테이블
    await db.execute('''
      CREATE TABLE statistics_cache (
        key TEXT PRIMARY KEY,
        data TEXT NOT NULL,
        created_at TEXT NOT NULL,
        expires_at TEXT NOT NULL
      )
    ''');
  }

  /// 데이터베이스 업그레이드
  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 향후 버전 업그레이드 시 마이그레이션 로직 추가
  }

  // ============= User Methods =============

  /// 사용자 저장
  static Future<void> saveUser(User user) async {
    final db = await database;
    await db.insert(
      'users',
      {
        'id': user.id,
        'email': user.email,
        'name': user.name,
        'bio': user.bio,
        'avatar_url': user.avatarUrl,
        'created_at': user.createdAt.toIso8601String(),
        'last_login_at': user.lastLoginAt?.toIso8601String(),
        'preferences': user.preferences != null ? jsonEncode(user.preferences) : null,
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 사용자 가져오기
  static Future<User?> getUser(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;

    final map = maps.first;
    return User(
      id: map['id'],
      email: map['email'],
      name: map['name'],
      bio: map['bio'],
      avatarUrl: map['avatar_url'],
      createdAt: DateTime.parse(map['created_at']),
      lastLoginAt: map['last_login_at'] != null ? DateTime.parse(map['last_login_at']) : null,
      preferences: map['preferences'] != null ? jsonDecode(map['preferences']) : null,
    );
  }

  // ============= Study Goals Methods =============

  /// 학습 목표 저장
  static Future<void> saveGoal(StudyGoal goal) async {
    final db = await database;
    await db.insert(
      'study_goals',
      {
        'id': goal.id,
        'title': goal.title,
        'description': goal.description,
        'target_date': goal.targetDate?.toIso8601String(),
        'category': goal.category,
        'priority': goal.priority,
        'status': goal.status,
        'progress': goal.progress,
        'created_at': goal.createdAt.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'is_synced': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 모든 학습 목표 가져오기
  static Future<List<StudyGoal>> getAllGoals() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'study_goals',
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => StudyGoal(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      targetDate: map['target_date'] != null ? DateTime.parse(map['target_date']) : null,
      category: map['category'],
      priority: map['priority'],
      status: map['status'],
      progress: map['progress'],
      createdAt: DateTime.parse(map['created_at']),
    )).toList();
  }

  /// 학습 목표 삭제
  static Future<void> deleteGoal(String id) async {
    final db = await database;
    await db.delete(
      'study_goals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============= Study Sessions Methods =============

  /// 학습 세션 저장
  static Future<void> saveSession(StudySession session) async {
    final db = await database;
    await db.insert(
      'study_sessions',
      {
        'id': session.id,
        'goal_id': session.goalId,
        'start_time': session.startTime.toIso8601String(),
        'end_time': session.endTime?.toIso8601String(),
        'duration': session.duration,
        'notes': session.notes,
        'focus_score': session.focusScore,
        'created_at': session.createdAt.toIso8601String(),
        'is_synced': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 모든 학습 세션 가져오기
  static Future<List<StudySession>> getAllSessions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'study_sessions',
      orderBy: 'start_time DESC',
    );

    return maps.map((map) => StudySession(
      id: map['id'],
      goalId: map['goal_id'],
      startTime: DateTime.parse(map['start_time']),
      endTime: map['end_time'] != null ? DateTime.parse(map['end_time']) : null,
      duration: map['duration'],
      notes: map['notes'],
      focusScore: map['focus_score'],
      createdAt: DateTime.parse(map['created_at']),
    )).toList();
  }

  /// 특정 목표의 세션 가져오기
  static Future<List<StudySession>> getSessionsByGoal(String goalId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'study_sessions',
      where: 'goal_id = ?',
      whereArgs: [goalId],
      orderBy: 'start_time DESC',
    );

    return maps.map((map) => StudySession(
      id: map['id'],
      goalId: map['goal_id'],
      startTime: DateTime.parse(map['start_time']),
      endTime: map['end_time'] != null ? DateTime.parse(map['end_time']) : null,
      duration: map['duration'],
      notes: map['notes'],
      focusScore: map['focus_score'],
      createdAt: DateTime.parse(map['created_at']),
    )).toList();
  }

  // ============= AI Response Methods =============

  /// AI 응답 저장
  static Future<void> saveAIResponse(AIResponse response) async {
    final db = await database;
    await db.insert(
      'ai_responses',
      {
        'id': response.id,
        'user_id': response.userId,
        'type': response.type.toString().split('.').last,
        'query': response.query,
        'response': response.response,
        'metadata': response.metadata != null ? jsonEncode(response.metadata) : null,
        'confidence': response.confidence,
        'tags': response.tags != null ? jsonEncode(response.tags) : null,
        'created_at': response.createdAt.toIso8601String(),
        'is_synced': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// AI 응답 기록 가져오기
  static Future<List<AIResponse>> getAIHistory({int limit = 50}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'ai_responses',
      orderBy: 'created_at DESC',
      limit: limit,
    );

    return maps.map((map) => AIResponse(
      id: map['id'],
      userId: map['user_id'],
      type: AIResponseType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => AIResponseType.explanation,
      ),
      query: map['query'],
      response: map['response'],
      metadata: map['metadata'] != null ? jsonDecode(map['metadata']) : null,
      confidence: map['confidence'],
      tags: map['tags'] != null ? List<String>.from(jsonDecode(map['tags'])) : null,
      createdAt: DateTime.parse(map['created_at']),
    )).toList();
  }

  // ============= Statistics Cache Methods =============

  /// 통계 캐시 저장
  static Future<void> cacheStatistics(String key, Map<String, dynamic> data, {Duration expiry = const Duration(hours: 1)}) async {
    final db = await database;
    final now = DateTime.now();
    await db.insert(
      'statistics_cache',
      {
        'key': key,
        'data': jsonEncode(data),
        'created_at': now.toIso8601String(),
        'expires_at': now.add(expiry).toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 통계 캐시 가져오기
  static Future<Map<String, dynamic>?> getCachedStatistics(String key) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'statistics_cache',
      where: 'key = ? AND expires_at > ?',
      whereArgs: [key, DateTime.now().toIso8601String()],
    );

    if (maps.isEmpty) return null;
    
    return jsonDecode(maps.first['data']);
  }

  // ============= Sync Methods =============

  /// 동기화되지 않은 데이터 가져오기
  static Future<Map<String, List<dynamic>>> getUnsyncedData() async {
    final db = await database;
    
    final goals = await db.query('study_goals', where: 'is_synced = 0');
    final sessions = await db.query('study_sessions', where: 'is_synced = 0');
    final aiResponses = await db.query('ai_responses', where: 'is_synced = 0');

    return {
      'goals': goals,
      'sessions': sessions,
      'ai_responses': aiResponses,
    };
  }

  /// 동기화 상태 업데이트
  static Future<void> markAsSynced(String table, String id) async {
    final db = await database;
    await db.update(
      table,
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 모든 데이터 삭제
  static Future<void> clearAllData() async {
    final db = await database;
    await db.delete('users');
    await db.delete('study_goals');
    await db.delete('study_sessions');
    await db.delete('ai_responses');
    await db.delete('statistics_cache');
  }

  /// 데이터베이스 닫기
  static Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}