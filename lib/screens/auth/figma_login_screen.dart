import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'modern_register_screen.dart';
import 'password_reset_screen.dart';
import 'terms_of_service_screen.dart';
import 'studymate_ready_screen.dart';
import '../../services/social_login_service.dart';
import '../../providers/auth_provider.dart';

class FigmaLoginScreen extends StatefulWidget {
  const FigmaLoginScreen({super.key});

  @override
  State<FigmaLoginScreen> createState() => _FigmaLoginScreenState();
}

class _FigmaLoginScreenState extends State<FigmaLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _socialLoginService = SocialLoginService();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('이메일과 비밀번호를 입력해주세요'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // BuildContext와 필요한 서비스들을 미리 저장
    final navigatorState = Navigator.of(context);
    final scaffoldState = ScaffoldMessenger.of(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    
    // 먼저 이용약관 동의 화면으로 이동
    navigatorState.push(
      MaterialPageRoute(
        builder: (context) => TermsOfServiceScreen(
          onAgreementComplete: () async {
            // 약관 동의 완료 후 이메일 로그인 진행
            setState(() {
              _isLoading = true;
            });

            final success = await authProvider.login(email, password);

            setState(() {
              _isLoading = false;
            });

            if (success) {
              // 로그인 성공 시 준비 완료 화면으로 이동
              navigatorState.pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const StudyMateReadyScreen(),
                ),
                (route) => false,
              );
            } else {
              scaffoldState.showSnackBar(
                SnackBar(
                  content: Text(authProvider.errorMessage ?? '로그인에 실패했습니다'),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,  // 키보드가 올라올 때 화면 조정
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),  // 스크롤 바운스 효과 제거
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      // 상단 여백
                      const SizedBox(height: 150),  // 130 + 20 = 150
                      
                      // STUDYMATE 로고
                      _buildLogo(),
                      
                      // 로그인 폼 영역
                      const SizedBox(height: 90),  // 80 + 10 = 90
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Column(
                          children: [
                            // 이메일과 비밀번호 입력 필드
                            _buildInputFields(),
                            
                            const SizedBox(height: 30),
                            
                            // 로그인 버튼
                            _buildLoginButton(),
                            
                            const SizedBox(height: 30),
                            
                            // 비밀번호 찾기 | 이메일로 회원가입
                            _buildAuthLinks(),
                          ],
                        ),
                      ),
                      
                      // SNS 로그인 섹션을 아래쪽에 배치
                      const Spacer(),
                      
                      _buildSNSSection(),
                      
                      const SizedBox(height: 50), // 하단 여백
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLogo() {
    // 피그마와 동일한 로고 - 두 개의 SVG 그룹으로 구성
    return Container(
      width: 150,
      height: 73,
      child: Stack(
        children: [
          // Group 2 (상단)
          Positioned(
            top: 0,
            left: 0,
            child: SvgPicture.asset(
              'assets/images/studymate_logo_group2.svg',
              width: 150,
              height: 32,
              colorFilter: const ColorFilter.mode(
                Color(0xFF70C4DE),
                BlendMode.srcIn,
              ),
            ),
          ),
          // Group 3 (하단)
          Positioned(
            bottom: 0,
            left: 0,
            child: SvgPicture.asset(
              'assets/images/studymate_logo_group3.svg',
              width: 150,
              height: 39,
              colorFilter: const ColorFilter.mode(
                Color(0xFF70C4DE),
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputFields() {
    return Column(
      children: [
        // 이메일 입력 필드 - Component 3 (placeholder만 있음)
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          child: TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: '이메일을 입력해주세요',
              hintStyle: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 16,
                fontWeight: FontWeight.w600,  // 피그마: 600
                color: Color(0xFF555555),  // 피그마: #555555
                height: 1.5,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF555555),
              height: 1.5,
            ),
          ),
        ),
        
        const SizedBox(height: 10),
        
        // 비밀번호 입력 필드 - Component 4 (라벨 "비밀번호"가 있음)
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 비밀번호 라벨과 입력 필드
              Expanded(
                child: Row(
                  children: [
                    const Text(
                      '비밀번호',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,  // 피그마: 600
                        color: Color(0xFF555555),  // 피그마: #555555
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: const InputDecoration(
                          hintText: '',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF555555),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 비밀번호 토글 아이콘
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
                child: Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  child: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: const Color(0xFF888888),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return Container(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF70C4DE),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          padding: EdgeInsets.zero,  // 패딩 제거
        ),
        child: Container(
          height: 52,
          alignment: Alignment.center,  // 중앙 정렬 보장
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
                    fontFamily: 'Pretendard',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.3,
                    height: 1.2,  // 라인 높이 조정
                  ),
                  textAlign: TextAlign.center,
                ),
        ),
      ),
    );
  }

  Widget _buildAuthLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PasswordResetScreen(),
              ),
            );
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            '비밀번호 찾기',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 17,
              fontWeight: FontWeight.w400,
              color: Color(0xFF555555),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            '|',
            style: TextStyle(
              color: Color(0xFFCCCCCC),
              fontSize: 17,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ModernRegisterScreen(),
              ),
            );
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            '이메일로 회원가입',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 17,
              fontWeight: FontWeight.w400,
              color: Color(0xFF555555),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSNSSection() {
    return Column(
      children: [
        const Text(
          'SNS 계정으로 로그인하기',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF70C4DE),
          ),
        ),
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 카카오 버튼
              _buildSNSButton(
                color: const Color(0xFFFEE32D),
                padding: 11,
                child: SvgPicture.asset(
                  'assets/icons/kakao-icon.svg',
                  width: 32,
                  height: 32,
                  placeholderBuilder: (context) => Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3A1D1D),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Center(
                      child: Text(
                        'K',
                        style: TextStyle(
                          color: Color(0xFFFEE32D),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                onTap: () async {
                  // BuildContext와 필요한 서비스들을 미리 저장
                  final navigatorState = Navigator.of(context);
                  final scaffoldState = ScaffoldMessenger.of(context);
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  
                  // 먼저 이용약관 동의 화면으로 이동
                  navigatorState.push(
                    MaterialPageRoute(
                      builder: (context) => TermsOfServiceScreen(
                        onAgreementComplete: () async {
                          // 약관 동의 완료 후 카카오 로그인 진행
                          debugPrint('🎯 Starting Kakao login after agreement');
                          
                          // 여기서는 context가 아닌 navigatorState의 context를 사용
                          final result = await _socialLoginService.signInWithKakao(navigatorState.context);
                          
                          if (result != null) {
                            debugPrint('✅ Kakao login result received');
                            final success = await authProvider.socialLogin(result);
                            
                            if (success) {
                              debugPrint('✅ Social login successful, navigating to ready screen');
                              // 로그인 성공 시 준비 완료 화면으로 이동
                              navigatorState.pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => const StudyMateReadyScreen(),
                                ),
                                (route) => false,
                              );
                            } else {
                              scaffoldState.showSnackBar(
                                const SnackBar(
                                  content: Text('카카오 로그인에 실패했습니다'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          } else {
                            debugPrint('❌ Kakao login result is null');
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 30),
              
              // 네이버 버튼
              _buildSNSButton(
                color: const Color(0xFF5AC451),
                padding: 14,
                child: SvgPicture.asset(
                  'assets/icons/naver-icon.svg',
                  width: 26,
                  height: 26,
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  placeholderBuilder: (context) => const Text(
                    'N',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                onTap: () async {
                  // BuildContext와 필요한 서비스들을 미리 저장
                  final navigatorState = Navigator.of(context);
                  final scaffoldState = ScaffoldMessenger.of(context);
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  
                  // 먼저 이용약관 동의 화면으로 이동
                  navigatorState.push(
                    MaterialPageRoute(
                      builder: (context) => TermsOfServiceScreen(
                        onAgreementComplete: () async {
                          // 약관 동의 완료 후 네이버 로그인 진행
                          final result = await _socialLoginService.signInWithNaver(navigatorState.context);
                          
                          if (result != null) {
                            final success = await authProvider.socialLogin(result);
                            
                            if (success) {
                              // 로그인 성공 시 준비 완료 화면으로 이동
                              navigatorState.pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => const StudyMateReadyScreen(),
                                ),
                                (route) => false,
                              );
                            } else {
                              scaffoldState.showSnackBar(
                                const SnackBar(
                                  content: Text('네이버 로그인에 실패했습니다'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 30),
              
              // 구글 버튼
              _buildSNSButton(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFCCCCCC)),
                padding: 11,
                child: SvgPicture.asset(
                  'assets/icons/google-icon.svg',
                  width: 32,
                  height: 32,
                  placeholderBuilder: (context) => Image.asset(
                    'assets/images/google_logo_complete.svg',
                    width: 32,
                    height: 32,
                    errorBuilder: (context, error, stackTrace) => const Text(
                      'G',
                      style: TextStyle(
                        color: Color(0xFF4285F4),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                onTap: () async {
                  // BuildContext와 필요한 서비스들을 미리 저장
                  final navigatorState = Navigator.of(context);
                  final scaffoldState = ScaffoldMessenger.of(context);
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  
                  // 먼저 이용약관 동의 화면으로 이동
                  navigatorState.push(
                    MaterialPageRoute(
                      builder: (context) => TermsOfServiceScreen(
                        onAgreementComplete: () async {
                          // 약관 동의 완료 후 구글 로그인 진행
                          final result = await _socialLoginService.signInWithGoogle(navigatorState.context);
                          
                          if (result != null) {
                            final success = await authProvider.socialLogin(result);
                            
                            if (success) {
                              // 로그인 성공 시 준비 완료 화면으로 이동
                              navigatorState.pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => const StudyMateReadyScreen(),
                                ),
                                (route) => false,
                              );
                            } else {
                              scaffoldState.showSnackBar(
                                const SnackBar(
                                  content: Text('구글 로그인에 실패했습니다'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 30),
              
              // 애플 버튼
              _buildSNSButton(
                color: Colors.black,
                padding: 11,
                child: SvgPicture.asset(
                  'assets/icons/apple-icon.svg',
                  width: 32,
                  height: 32,
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  placeholderBuilder: (context) => const Icon(
                    Icons.apple,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                onTap: () async {
                  // BuildContext와 필요한 서비스들을 미리 저장
                  final navigatorState = Navigator.of(context);
                  final scaffoldState = ScaffoldMessenger.of(context);
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  
                  // 먼저 이용약관 동의 화면으로 이동
                  navigatorState.push(
                    MaterialPageRoute(
                      builder: (context) => TermsOfServiceScreen(
                        onAgreementComplete: () async {
                          // 약관 동의 완료 후 애플 로그인 진행
                          final result = await _socialLoginService.signInWithApple(navigatorState.context);
                          
                          if (result != null) {
                            final success = await authProvider.socialLogin(result);
                            
                            if (success) {
                              // 로그인 성공 시 준비 완료 화면으로 이동
                              navigatorState.pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => const StudyMateReadyScreen(),
                                ),
                                (route) => false,
                              );
                            } else {
                              scaffoldState.showSnackBar(
                                const SnackBar(
                                  content: Text('애플 로그인에 실패했습니다'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSNSButton({
    required Color color,
    required Widget child,
    required VoidCallback onTap,
    Border? border,
    double padding = 11,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(27),
      child: Container(
        width: 54,
        height: 54,
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: border,
        ),
        child: Center(child: child),
      ),
    );
  }
}