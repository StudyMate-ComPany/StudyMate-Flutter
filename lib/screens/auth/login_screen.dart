import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../home/main_navigation_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이메일과 비밀번호를 입력해주세요')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.login(
        _emailController.text,
        _passwordController.text,
      );

      if (mounted) {
        if (success) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const MainNavigationScreen(),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('로그인에 실패했습니다')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleSocialLogin(String provider) async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.socialLogin(provider);

      if (mounted) {
        if (success) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const MainNavigationScreen(),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$provider 로그인에 실패했습니다')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
            child: Column(
              children: [
                // 상단 영역 제거 (로그인 화면에는 불필요)

                const SizedBox(height: 135),

                // STUDY 로고 텍스트
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // STUDY 텍스트 (SVG 대신 직접 구현)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/images/login_logo_9.svg',
                          width: 29,
                          height: 32,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF70C4DE),
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 2),
                        SvgPicture.asset(
                          'assets/images/login_logo_8.svg',
                          width: 28,
                          height: 31,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF70C4DE),
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 2),
                        SvgPicture.asset(
                          'assets/images/login_logo_7.svg',
                          width: 30,
                          height: 32,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF70C4DE),
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 2),
                        SvgPicture.asset(
                          'assets/images/login_logo_6.svg',
                          width: 28,
                          height: 31,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF70C4DE),
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 2),
                        SvgPicture.asset(
                          'assets/images/login_logo_5.svg',
                          width: 32,
                          height: 31,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF70C4DE),
                            BlendMode.srcIn,
                          ),
                        ),
                      ],
                    ).animate()
                      .fadeIn(duration: 600.ms)
                      .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
                    
                    // MATE 텍스트
                    Positioned(
                      top: 35,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/images/login_logo_4.svg',
                            width: 44,
                            height: 39,
                            colorFilter: const ColorFilter.mode(
                              Color(0xFF70C4DE),
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 2),
                          SvgPicture.asset(
                            'assets/images/login_logo_3.svg',
                            width: 41,
                            height: 39,
                            colorFilter: const ColorFilter.mode(
                              Color(0xFF70C4DE),
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 2),
                          SvgPicture.asset(
                            'assets/images/login_logo_2.svg',
                            width: 36,
                            height: 39,
                            colorFilter: const ColorFilter.mode(
                              Color(0xFF70C4DE),
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 2),
                          SvgPicture.asset(
                            'assets/images/login_logo_1.svg',
                            width: 31,
                            height: 39,
                            colorFilter: const ColorFilter.mode(
                              Color(0xFF70C4DE),
                              BlendMode.srcIn,
                            ),
                          ),
                        ],
                      ).animate()
                        .fadeIn(delay: 200.ms, duration: 600.ms)
                        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
                    ),
                  ],
                ),

                const SizedBox(height: 125),

                // 입력 필드들
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    children: [
                      // 이메일 또는 아이디 입력
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFCCCCCC),
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF555555),
                            fontFamily: 'Pretendard',
                          ),
                          decoration: const InputDecoration(
                            hintText: '이메일 또는 아이디',
                            hintStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF555555),
                              fontFamily: 'Pretendard',
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                          ),
                        ),
                      ).animate()
                        .fadeIn(delay: 400.ms, duration: 500.ms)
                        .slideY(begin: 0.2, end: 0),

                      const SizedBox(height: 10),

                      // 비밀번호 입력
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFCCCCCC),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _passwordController,
                                focusNode: _passwordFocusNode,
                                obscureText: !_isPasswordVisible,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF555555),
                                  fontFamily: 'Pretendard',
                                ),
                                decoration: const InputDecoration(
                                  hintText: '비밀번호',
                                  hintStyle: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF555555),
                                    fontFamily: 'Pretendard',
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: const Color(0xFF888888),
                                size: 26,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ],
                        ),
                      ).animate()
                        .fadeIn(delay: 500.ms, duration: 500.ms)
                        .slideY(begin: 0.2, end: 0),

                      const SizedBox(height: 15),

                      // 로그인하기 버튼
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF70C4DE),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
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
                              : const Text(
                                  '로그인하기',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Pretendard',
                                  ),
                                ),
                        ),
                      ).animate()
                        .fadeIn(delay: 600.ms, duration: 500.ms)
                        .slideY(begin: 0.2, end: 0),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // 비밀번호 찾기 | 이메일로 회원가입
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        // TODO: 비밀번호 찾기 화면
                      },
                      child: const Text(
                        '비밀번호 찾기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF555555),
                          fontFamily: 'Pretendard',
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 16,
                      color: const Color(0xFFCCCCCC),
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignupScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        '이메일로 회원가입',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF555555),
                          fontFamily: 'Pretendard',
                        ),
                      ),
                    ),
                  ],
                ).animate()
                  .fadeIn(delay: 700.ms, duration: 500.ms),

                const Spacer(),

                // SNS 로그인 섹션
                Column(
                  children: [
                    const Text(
                      'SNS 계정으로 로그인하기',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF70C4DE),
                        fontFamily: 'Pretendard',
                      ),
                    ).animate()
                      .fadeIn(delay: 800.ms, duration: 500.ms),

                    const SizedBox(height: 30),

                    // SNS 로그인 버튼들
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 카카오톡
                        _buildSocialButton(
                          onTap: () => _handleSocialLogin('kakao'),
                          backgroundColor: const Color(0xFFFEE32D),
                          child: SvgPicture.asset(
                            'assets/images/kakao_logo.svg',
                            width: 28,
                            height: 28,
                          ),
                        ),
                        const SizedBox(width: 30),
                        // 네이버
                        _buildSocialButton(
                          onTap: () => _handleSocialLogin('naver'),
                          backgroundColor: const Color(0xFF5AC451),
                          child: SvgPicture.asset(
                            'assets/images/naver_logo_new.svg',
                            width: 18,
                            height: 18,
                          ),
                        ),
                        const SizedBox(width: 30),
                        // 구글
                        _buildSocialButton(
                          onTap: () => _handleSocialLogin('google'),
                          backgroundColor: Colors.white,
                          border: Border.all(
                            color: const Color(0xFFCCCCCC),
                            width: 1,
                          ),
                          child: SvgPicture.asset(
                            'assets/images/google_logo_complete.svg',
                            width: 24,
                            height: 24,
                          ),
                        ),
                        const SizedBox(width: 30),
                        // 애플
                        _buildSocialButton(
                          onTap: () => _handleSocialLogin('apple'),
                          backgroundColor: Colors.black,
                          child: SvgPicture.asset(
                            'assets/images/apple_logo_complete.svg',
                            width: 24,
                            height: 24,
                          ),
                        ),
                      ],
                    ).animate()
                      .fadeIn(delay: 900.ms, duration: 500.ms)
                      .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
                  ],
                ),

                const SizedBox(height: 110),
              ],
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
      borderRadius: BorderRadius.circular(27),
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: border,
        ),
        child: Center(child: child),
      ),
    );
  }
}