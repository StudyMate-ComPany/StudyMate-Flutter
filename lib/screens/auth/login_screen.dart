import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/studymate_theme.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../widgets/korean_text_field.dart';
import 'register_screen.dart';
import '../home/main_navigation_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? '로그인에 실패했습니다'),
            backgroundColor: const Color(0xFFFF6B6B),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        backgroundColor: StudyMateTheme.lightBlue,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  
                  // STUDYMATE 로고
                  Text(
                    'STUDY\nMATE',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                      color: StudyMateTheme.primaryBlue,
                      letterSpacing: -1,
                    ),
                    textAlign: TextAlign.center,
                  ).animate()
                    .fadeIn(duration: 600.ms)
                    .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
                  
                  const SizedBox(height: 60),
                  
                  // 로그인 폼
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // 이메일 입력 필드
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: StudyMateTheme.bodyLarge,
                          decoration: InputDecoration(
                            hintText: '이메일 또는 아이디',
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 18,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: StudyMateTheme.primaryBlue,
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '이메일을 입력해주세요';
                            }
                            return null;
                          },
                        ).animate()
                          .fadeIn(delay: 200.ms, duration: 500.ms)
                          .slideY(begin: 0.2, end: 0),
                        
                        const SizedBox(height: 16),
                        
                        // 비밀번호 입력 필드
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          style: StudyMateTheme.bodyLarge,
                          decoration: InputDecoration(
                            hintText: '비밀번호',
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 18,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: StudyMateTheme.primaryBlue,
                                width: 2,
                              ),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: StudyMateTheme.grayText,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '비밀번호를 입력해주세요';
                            }
                            return null;
                          },
                        ).animate()
                          .fadeIn(delay: 300.ms, duration: 500.ms)
                          .slideY(begin: 0.2, end: 0),
                        
                        const SizedBox(height: 32),
                        
                        // 로그인 버튼
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: StudyMateTheme.primaryBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 2,
                            ),
                            child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  '로그인하기',
                                  style: StudyMateTheme.buttonText,
                                ),
                          ),
                        ).animate()
                          .fadeIn(delay: 400.ms, duration: 500.ms)
                          .slideY(begin: 0.2, end: 0),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 비밀번호 찾기 & 회원가입
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          // 비밀번호 찾기 로직
                        },
                        child: Text(
                          '비밀번호 찾기',
                          style: StudyMateTheme.bodyMedium.copyWith(
                            color: StudyMateTheme.grayText,
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 12,
                        color: StudyMateTheme.grayText.withOpacity(0.3),
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: Text(
                          '이메일로 회원가입',
                          style: StudyMateTheme.bodyMedium.copyWith(
                            color: StudyMateTheme.grayText,
                          ),
                        ),
                      ),
                    ],
                  ).animate()
                    .fadeIn(delay: 500.ms, duration: 500.ms),
                  
                  const SizedBox(height: 40),
                  
                  // SNS 로그인
                  Column(
                    children: [
                      Text(
                        'SNS 계정으로 로그인하기',
                        style: StudyMateTheme.bodyMedium.copyWith(
                          color: StudyMateTheme.grayText,
                        ),
                      ).animate()
                        .fadeIn(delay: 600.ms, duration: 500.ms),
                      const SizedBox(height: 20),
                      
                      // SNS 버튼들
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 카카오톡
                          _buildSocialButton(
                            onTap: () => _handleSocialLogin('kakao'),
                            backgroundColor: StudyMateTheme.kakaoYellow,
                            child: const Text(
                              'TALK',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ).animate()
                            .fadeIn(delay: 700.ms, duration: 500.ms)
                            .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
                          
                          const SizedBox(width: 16),
                          
                          // 네이버
                          _buildSocialButton(
                            onTap: () => _handleSocialLogin('naver'),
                            backgroundColor: StudyMateTheme.naverGreen,
                            child: const Text(
                              'N',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ).animate()
                            .fadeIn(delay: 800.ms, duration: 500.ms)
                            .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
                          
                          const SizedBox(width: 16),
                          
                          // 구글
                          _buildSocialButton(
                            onTap: () => _handleSocialLogin('google'),
                            backgroundColor: StudyMateTheme.googleWhite,
                            border: Border.all(
                              color: StudyMateTheme.lightGray,
                              width: 1,
                            ),
                            child: const Text(
                              'G',
                              style: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ).animate()
                            .fadeIn(delay: 900.ms, duration: 500.ms)
                            .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
                          
                          const SizedBox(width: 16),
                          
                          // 애플
                          _buildSocialButton(
                            onTap: () => _handleSocialLogin('apple'),
                            backgroundColor: StudyMateTheme.appleBlack,
                            child: const Icon(
                              Icons.apple,
                              color: Colors.white,
                              size: 24,
                            ),
                          ).animate()
                            .fadeIn(delay: 1000.ms, duration: 500.ms)
                            .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required VoidCallback onTap,
    required Color backgroundColor,
    required Widget child,
    Border? border,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: border,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }

  Future<void> _handleSocialLogin(String provider) async {
    // SNS 로그인 로직 구현
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$provider 로그인 준비 중입니다'),
        backgroundColor: StudyMateTheme.primaryBlue,
      ),
    );
  }
}