import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/pomodoro_settings.dart';
import '../../theme/app_theme.dart';
import '../../services/local_storage_service.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PomodoroSettingsScreen extends StatefulWidget {
  const PomodoroSettingsScreen({super.key});

  @override
  State<PomodoroSettingsScreen> createState() => _PomodoroSettingsScreenState();
}

class _PomodoroSettingsScreenState extends State<PomodoroSettingsScreen> {
  late PomodoroSettings _settings;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    final stored = await LocalStorageService.getData('pomodoro_settings');
    if (stored != null) {
      setState(() {
        _settings = PomodoroSettings.fromJson(stored);
      });
    } else {
      _settings = const PomodoroSettings();
    }
  }
  
  Future<void> _saveSettings() async {
    await LocalStorageService.saveData('pomodoro_settings', _settings.toJson());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('설정이 저장되었습니다'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      Navigator.pop(context, _settings);
    }
  }
  
  Widget _buildTimerSlider({
    required String title,
    required int value,
    required int min,
    required int max,
    required Function(double) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: value.toDouble(),
                min: min.toDouble(),
                max: max.toDouble(),
                divisions: max - min,
                activeColor: AppTheme.primaryColor,
                onChanged: onChanged,
              ),
            ),
            Container(
              width: 60,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$value분',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('포모도로 설정'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '타이머 설정',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    _buildTimerSlider(
                      title: '집중 시간',
                      value: _settings.workMinutes,
                      min: 5,
                      max: 60,
                      onChanged: (value) {
                        setState(() {
                          _settings = _settings.copyWith(
                            workMinutes: value.toInt(),
                          );
                        });
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    _buildTimerSlider(
                      title: '짧은 휴식',
                      value: _settings.shortBreakMinutes,
                      min: 1,
                      max: 15,
                      onChanged: (value) {
                        setState(() {
                          _settings = _settings.copyWith(
                            shortBreakMinutes: value.toInt(),
                          );
                        });
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    _buildTimerSlider(
                      title: '긴 휴식',
                      value: _settings.longBreakMinutes,
                      min: 5,
                      max: 30,
                      onChanged: (value) {
                        setState(() {
                          _settings = _settings.copyWith(
                            longBreakMinutes: value.toInt(),
                          );
                        });
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '긴 휴식까지 세션 수',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: _settings.sessionsUntilLongBreak > 2
                                  ? () {
                                      setState(() {
                                        _settings = _settings.copyWith(
                                          sessionsUntilLongBreak:
                                              _settings.sessionsUntilLongBreak - 1,
                                        );
                                      });
                                    }
                                  : null,
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${_settings.sessionsUntilLongBreak}회',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: _settings.sessionsUntilLongBreak < 8
                                  ? () {
                                      setState(() {
                                        _settings = _settings.copyWith(
                                          sessionsUntilLongBreak:
                                              _settings.sessionsUntilLongBreak + 1,
                                        );
                                      });
                                    }
                                  : null,
                              icon: const Icon(Icons.add_circle_outline),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate()
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.1, end: 0),
              
              const SizedBox(height: 20),
              
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '자동 시작 설정',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    SwitchListTile(
                      title: const Text('휴식 자동 시작'),
                      subtitle: const Text('세션 종료 후 휴식을 자동으로 시작합니다'),
                      value: _settings.autoStartBreaks,
                      activeColor: AppTheme.primaryColor,
                      onChanged: (value) {
                        setState(() {
                          _settings = _settings.copyWith(autoStartBreaks: value);
                        });
                      },
                    ),
                    
                    SwitchListTile(
                      title: const Text('포모도로 자동 시작'),
                      subtitle: const Text('휴식 종료 후 다음 세션을 자동으로 시작합니다'),
                      value: _settings.autoStartPomodoros,
                      activeColor: AppTheme.primaryColor,
                      onChanged: (value) {
                        setState(() {
                          _settings = _settings.copyWith(autoStartPomodoros: value);
                        });
                      },
                    ),
                  ],
                ),
              ).animate()
                .fadeIn(duration: 600.ms, delay: 200.ms)
                .slideY(begin: 0.1, end: 0),
              
              const SizedBox(height: 20),
              
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '알림 설정',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    SwitchListTile(
                      title: const Text('소리 알림'),
                      subtitle: const Text('세션 종료 시 소리로 알려줍니다'),
                      value: _settings.soundEnabled,
                      activeColor: AppTheme.primaryColor,
                      onChanged: (value) {
                        setState(() {
                          _settings = _settings.copyWith(soundEnabled: value);
                        });
                      },
                    ),
                    
                    SwitchListTile(
                      title: const Text('진동 알림'),
                      subtitle: const Text('세션 종료 시 진동으로 알려줍니다'),
                      value: _settings.vibrationEnabled,
                      activeColor: AppTheme.primaryColor,
                      onChanged: (value) {
                        setState(() {
                          _settings = _settings.copyWith(vibrationEnabled: value);
                        });
                      },
                    ),
                  ],
                ),
              ).animate()
                .fadeIn(duration: 600.ms, delay: 400.ms)
                .slideY(begin: 0.1, end: 0),
              
              const SizedBox(height: 32),
              
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _settings = const PomodoroSettings();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '기본값으로 재설정',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '저장',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ).animate()
                .fadeIn(duration: 600.ms, delay: 600.ms)
                .slideY(begin: 0.1, end: 0),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}