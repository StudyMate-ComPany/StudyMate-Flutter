class ApiConstants {
  // Base URL - 개발용 (실제 배포시 변경 필요)
  static const String baseUrl = 'http://localhost:8000/api';
  
  // Auth endpoints
  static const String register = '/auth/register/';
  static const String login = '/auth/login/';
  static const String logout = '/auth/logout/';
  static const String profile = '/auth/profile/';
  static const String preferences = '/auth/preferences/';
  static const String skip = '/auth/skip/';
  
  // Home endpoints
  static const String dashboard = '/home/dashboard/';
  static const String dashboardStats = '/home/dashboard/stats/';
  static const String updateGoal = '/home/dashboard/update_goal/';
  static const String logActivity = '/home/dashboard/log_activity/';
  
  // Study endpoints
  static const String subjects = '/study/subjects/';
  static const String generateSummary = '/study/summary/generate/';
  static const String todaySummary = '/study/summary/today/';
  static const String summaryList = '/study/summary/list/';
  static const String summaryDetail = '/study/summary/{id}/';
  static const String saveSummary = '/study/summary/{id}/save/';
  static const String shareSummary = '/study/summary/{id}/share/';
  static const String dailyLimit = '/study/daily-limit/';
  
  // Quiz endpoints
  static const String generateQuiz = '/quiz/generate/';
  static const String quizList = '/quiz/list/';
  static const String quizDetail = '/quiz/{id}/';
  static const String startQuiz = '/quiz/{id}/start/';
  static const String submitAnswer = '/quiz/{id}/answer/';
  static const String quizResult = '/quiz/{id}/result/';
  static const String retryQuiz = '/quiz/{id}/retry/';
  static const String saveWrongAnswer = '/quiz/{id}/save-wrong/';
  static const String wrongAnswers = '/quiz/wrong-answers/';
  
  // Collaboration endpoints
  static const String rooms = '/collab/rooms/';
  static const String createRoom = '/collab/rooms/create_room/';
  static const String joinRoom = '/collab/rooms/join_room/';
  static const String roomDetail = '/collab/rooms/{id}/room_detail/';
  static const String toggleReady = '/collab/rooms/{id}/toggle_ready/';
  static const String startLiveQuiz = '/collab/rooms/{id}/start_quiz/';
  static const String liveStatus = '/collab/rooms/{id}/live_status/';
  static const String submitLiveAnswer = '/collab/rooms/{id}/submit_answer/';
  static const String sendChat = '/collab/rooms/{id}/send_chat/';
  
  // Stats endpoints
  static const String statsOverview = '/stats/overview/';
  static const String statsPeriod = '/stats/period/';
  static const String statsStrengths = '/stats/strengths/';
  static const String statsPeerComparison = '/stats/peer-comparison/';
  
  // Subscription endpoints
  static const String plans = '/subscription/plans/';
  static const String upgrade = '/subscription/upgrade/';
  static const String payment = '/subscription/payment/';
  static const String subscriptionStatus = '/subscription/status/';
  static const String paywall = '/subscription/paywall/';
  
  // Notification endpoints
  static const String notificationPermission = '/notifications/permission/';
  static const String notificationSettings = '/notifications/settings/';
  static const String notificationSnooze = '/notifications/snooze/';
  static const String notificationList = '/notifications/list/';
}