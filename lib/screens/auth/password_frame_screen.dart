import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../theme/studymate_theme.dart';
import '../../widgets/korean_enabled_text_field.dart';
import '../../providers/auth_provider.dart';

class PasswordFrameScreen extends StatefulWidget {
  final String email;
  
  const PasswordFrameScreen({
    super.key,
    required this.email,
  });

  @override
  State<PasswordFrameScreen> createState() => _PasswordFrameScreenState();
}

class _PasswordFrameScreenState extends State<PasswordFrameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _focusNode = FocusNode();
  
  bool _isPasswordVisible = false;
  bool _isValid = false;
  bool _isLoading = false;
  
  // 비밀번호 강도 체크
  int _passwordStrength = 0;
  String _passwordStrengthText = '';
  Color _passwordStrengthColor = Colors.red;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePassword);
    // 자동으로 키보드 올리기
    Future.delayed(const Duration(milliseconds: 500), () {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _validatePassword() {
    final password = _passwordController.text;
    int strength = 0;
    
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;
    
    String strengthText = '';
    Color strengthColor = Colors.red;
    
    switch (strength) {
      case 0:
      case 1:
        strengthText = '매우 약함';
        strengthColor = Colors.red;
        break;
      case 2:
        strengthText = '약함';
        strengthColor = Colors.orange;
        break;
      case 3:
        strengthText = '보통';
        strengthColor = Colors.yellow[700]!;
        break;
      case 4:
        strengthText = '강함';
        strengthColor = Colors.lightGreen;
        break;
      case 5:
        strengthText = '매우 강함';
        strengthColor = Colors.green;
        break;
    }
    
    setState(() {
      _passwordStrength = strength;
      _passwordStrengthText = strengthText;
      _passwordStrengthColor = strengthColor;
      _isValid = password.length >= 6;
    });
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      
      setState(() {
        _isLoading = true;
      });
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.login(
        widget.email,
        _passwordController.text,
      );
      
      setState(() {
        _isLoading = false;
      });
      
      if (!mounted) return;
      
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? '로그인에 실패했습니다'),
            backgroundColor: StudyMateTheme.accentPink,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
      // 성공하면 AuthProvider가 자동으로 홈 화면으로 이동시킴
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StudyMateTheme.lightBlue,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: StudyMateTheme.darkNavy,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                
                // 진행 표시기
                LinearProgressIndicator(
                  value: 1.0,
                  backgroundColor: StudyMateTheme.grayText.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    StudyMateTheme.primaryBlue,
                  ),
                  minHeight: 4,
                ).animate()
                  .scaleX(
                    begin: 0.5,
                    end: 1,
                    duration: 500.ms,
                    alignment: Alignment.centerLeft,
                  ),
                
                const SizedBox(height: 40),
                
                // 타이틀
                Text(
                  '비밀번호를\n입력해주세요',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: StudyMateTheme.darkNavy,
                    height: 1.3,
                  ),
                ).animate()
                  .fadeIn(duration: 500.ms)
                  .slideX(begin: -0.2, end: 0),
                
                const SizedBox(height: 12),
                
                // 이메일 표시
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: StudyMateTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.email_outlined,
                        size: 16,
                        color: StudyMateTheme.primaryBlue,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.email,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: StudyMateTheme.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ).animate()
                  .fadeIn(delay: 200.ms, duration: 500.ms),
                
                const SizedBox(height: 40),
                
                // 비밀번호 입력 필드
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: StudyMateTheme.primaryBlue.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: KoreanEnabledTextField(
                    controller: _passwordController,
                    focusNode: _focusNode,
                    obscureText: !_isPasswordVisible,
                    textInputAction: TextInputAction.done,
                    autofocus: false,
                    labelText: '비밀번호',
                    hintText: '••••••••',
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: StudyMateTheme.primaryBlue,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                      icon: Icon(
                        _isPasswordVisible 
                            ? Icons.visibility_off 
                            : Icons.visibility,
                        color: StudyMateTheme.grayText,
                      ),
                    ),
                    decoration: InputDecoration(
                      labelText: '비밀번호',
                      hintText: '••••••••',
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: StudyMateTheme.primaryBlue,
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                        icon: Icon(
                          _isPasswordVisible 
                              ? Icons.visibility_off 
                              : Icons.visibility,
                          color: StudyMateTheme.grayText,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      errorStyle: TextStyle(
                        color: StudyMateTheme.accentPink,
                        fontSize: 12,
                      ),
                    ),
                    onFieldSubmitted: (_) => _handleLogin(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '비밀번호를 입력해주세요';
                      }
                      if (value.length < 6) {
                        return '비밀번호는 6자 이상이어야 합니다';
                      }
                      return null;
                    },
                  ),
                ).animate()
                  .fadeIn(delay: 400.ms, duration: 500.ms)
                  .slideY(begin: 0.2, end: 0),
                
                const SizedBox(height: 16),
                
                // 비밀번호 강도 표시
                if (_passwordController.text.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _passwordStrengthColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _passwordStrengthColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.security_rounded,
                              size: 20,
                              color: _passwordStrengthColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '비밀번호 강도: $_passwordStrengthText',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _passwordStrengthColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: _passwordStrength / 5,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _passwordStrengthColor,
                          ),
                          minHeight: 4,
                        ),
                      ],
                    ),
                  ).animate()
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: -0.1, end: 0),
                
                const SizedBox(height: 16),
                
                // 비밀번호 찾기
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      // TODO: 비밀번호 찾기 화면으로 이동
                    },
                    child: Text(
                      '비밀번호를 잊으셨나요?',
                      style: TextStyle(
                        color: StudyMateTheme.primaryBlue,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ).animate()
                  .fadeIn(delay: 600.ms, duration: 500.ms),
                
                const Spacer(),
                
                // 로그인 버튼
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: (_isValid && !_isLoading) ? _handleLogin : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: StudyMateTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      disabledBackgroundColor: StudyMateTheme.grayText.withOpacity(0.3),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            '로그인',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: _isValid 
                                  ? Colors.white 
                                  : StudyMateTheme.grayText,
                            ),
                          ),
                  ),
                ).animate()
                  .fadeIn(delay: 800.ms, duration: 500.ms)
                  .slideY(begin: 0.2, end: 0),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}