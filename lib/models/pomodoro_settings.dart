class PomodoroSettings {
  final int workMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;
  final int sessionsUntilLongBreak;
  final bool autoStartBreaks;
  final bool autoStartPomodoros;
  final bool soundEnabled;
  final bool vibrationEnabled;
  
  const PomodoroSettings({
    this.workMinutes = 25,
    this.shortBreakMinutes = 5,
    this.longBreakMinutes = 15,
    this.sessionsUntilLongBreak = 4,
    this.autoStartBreaks = false,
    this.autoStartPomodoros = false,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
  });
  
  PomodoroSettings copyWith({
    int? workMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
    int? sessionsUntilLongBreak,
    bool? autoStartBreaks,
    bool? autoStartPomodoros,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    return PomodoroSettings(
      workMinutes: workMinutes ?? this.workMinutes,
      shortBreakMinutes: shortBreakMinutes ?? this.shortBreakMinutes,
      longBreakMinutes: longBreakMinutes ?? this.longBreakMinutes,
      sessionsUntilLongBreak: sessionsUntilLongBreak ?? this.sessionsUntilLongBreak,
      autoStartBreaks: autoStartBreaks ?? this.autoStartBreaks,
      autoStartPomodoros: autoStartPomodoros ?? this.autoStartPomodoros,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }
  
  Map<String, dynamic> toJson() => {
    'workMinutes': workMinutes,
    'shortBreakMinutes': shortBreakMinutes,
    'longBreakMinutes': longBreakMinutes,
    'sessionsUntilLongBreak': sessionsUntilLongBreak,
    'autoStartBreaks': autoStartBreaks,
    'autoStartPomodoros': autoStartPomodoros,
    'soundEnabled': soundEnabled,
    'vibrationEnabled': vibrationEnabled,
  };
  
  factory PomodoroSettings.fromJson(Map<String, dynamic> json) => PomodoroSettings(
    workMinutes: json['workMinutes'] ?? 25,
    shortBreakMinutes: json['shortBreakMinutes'] ?? 5,
    longBreakMinutes: json['longBreakMinutes'] ?? 15,
    sessionsUntilLongBreak: json['sessionsUntilLongBreak'] ?? 4,
    autoStartBreaks: json['autoStartBreaks'] ?? false,
    autoStartPomodoros: json['autoStartPomodoros'] ?? false,
    soundEnabled: json['soundEnabled'] ?? true,
    vibrationEnabled: json['vibrationEnabled'] ?? true,
  );
}