import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';

mixin AuthRequiredMixin<T extends StatefulWidget> on State<T> {
  /// 로그인 상태를 확인하고 로그인이 필요한 경우 로그인 화면으로 이동
  Future<bool> checkAuthAndNavigate() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // 로그인 상태 확인
    if (authProvider.state != AuthState.authenticated) {
      // 로그인 화면으로 이동
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
      
      // 로그인 후 다시 체크
      return authProvider.state == AuthState.authenticated;
    }
    
    return true;
  }

  /// 로그인이 필요한 작업 실행
  Future<void> executeWithAuth(Function() action) async {
    final isAuthenticated = await checkAuthAndNavigate();
    if (isAuthenticated) {
      action();
    }
  }

  /// 로그인 필요 다이얼로그 표시
  Future<bool?> showAuthRequiredDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('로그인이 필요해요'),
        content: const Text('이 기능을 사용하려면 로그인이 필요합니다.\n로그인 하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('로그인'),
          ),
        ],
      ),
    );
  }
}