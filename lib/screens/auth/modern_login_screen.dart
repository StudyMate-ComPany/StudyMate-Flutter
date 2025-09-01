import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../theme/studymate_theme.dart';
import '../../widgets/korean_enabled_text_field.dart';
import 'modern_register_screen.dart';

class ModernLoginScreen extends StatefulWidget {
  const ModernLoginScreen({super.key});

  @override
  State<ModernLoginScreen> createState() => _ModernLoginScreenState();
}

class _ModernLoginScreenState extends State<ModernLoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  bool _isLoading = false;
  
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      
      setState(() {
        _isLoading = true;
      });
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.login(
        _emailController.text.trim(),
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
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: StudyMateTheme.lightBlue,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // Logo Section
              _buildLogoSection(),
              
              const SizedBox(height: 20),
              
              // Login Form
              _buildLoginForm(),
              
              const SizedBox(height: 16),
              
              // Login Button
              _buildLoginButton(),
              
              const SizedBox(height: 12),
              
              // Social Login
              _buildSocialLogin(),
              
              const Spacer(),
              
              // Register Link
              _buildRegisterLink(),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildLogoSection() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    StudyMateTheme.primaryBlue,
                    StudyMateTheme.lightBlue,
                    StudyMateTheme.accentPink,
                  ],
                  transform: GradientRotation(_animationController.value * 3.14),
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: StudyMateTheme.primaryBlue.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.school_rounded,
                color: Colors.white,
                size: 40,
              ),
            );
          },
        ).animate()
          .fadeIn(duration: 800.ms)
          .scale(delay: 200.ms),
        
        const SizedBox(height: 16),
        
        Text(
          'StudyMate',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: StudyMateTheme.darkNavy,
            letterSpacing: -0.5,
          ),
        ).animate()
          .fadeIn(delay: 400.ms, duration: 600.ms)
          .slideY(begin: 0.2, end: 0),
        
        const SizedBox(height: 6),
        
        Text(
          '스마트한 학습의 시작',
          style: TextStyle(
            fontSize: 14,
            color: StudyMateTheme.grayText,
            fontWeight: FontWeight.w500,
          ),
        ).animate()
          .fadeIn(delay: 600.ms, duration: 600.ms),
      ],
    );
  }
  
  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email Field
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
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              labelText: '이메일',
              hintText: 'example@email.com',
              prefixIcon: Icon(
                Icons.email_outlined,
                color: StudyMateTheme.primaryBlue,
              ),
              decoration: InputDecoration(
                labelText: '이메일',
                hintText: 'example@email.com',
                prefixIcon: Icon(
                  Icons.email_outlined,
                  color: StudyMateTheme.primaryBlue,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '이메일을 입력해주세요';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return '올바른 이메일 형식이 아닙니다';
                }
                return null;
              },
            ),
          ).animate()
            .fadeIn(delay: 800.ms, duration: 600.ms)
            .slideX(begin: -0.2, end: 0),
          
          const SizedBox(height: 16),
          
          // Password Field
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
              obscureText: !_isPasswordVisible,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _handleLogin(),
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
                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
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
                    _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                    color: StudyMateTheme.grayText,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
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
            .fadeIn(delay: 900.ms, duration: 600.ms)
            .slideX(begin: -0.2, end: 0),
          
          const SizedBox(height: 12),
          
          // Remember Me & Forgot Password
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                      activeColor: StudyMateTheme.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '자동 로그인',
                    style: TextStyle(
                      color: StudyMateTheme.grayText,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  // TODO: 비밀번호 찾기 화면으로 이동
                },
                child: Text(
                  '비밀번호 찾기',
                  style: TextStyle(
                    color: StudyMateTheme.primaryBlue,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ).animate()
            .fadeIn(delay: 1000.ms, duration: 600.ms),
        ],
      ),
    );
  }
  
  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: StudyMateTheme.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                '로그인',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    ).animate()
      .fadeIn(delay: 1100.ms, duration: 600.ms)
      .slideY(begin: 0.2, end: 0);
  }
  
  Widget _buildSocialLogin() {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(
              child: Divider(
                color: StudyMateTheme.grayText,
                thickness: 0.5,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                '또는',
                style: TextStyle(
                  color: StudyMateTheme.grayText,
                  fontSize: 13,
                ),
              ),
            ),
            const Expanded(
              child: Divider(
                color: StudyMateTheme.grayText,
                thickness: 0.5,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialButton(
              icon: Icons.g_mobiledata,
              color: const Color(0xFF4285F4),
              onTap: () {
                HapticFeedback.lightImpact();
                // TODO: Google 로그인
              },
            ),
            const SizedBox(width: 12),
            _buildSocialButton(
              icon: Icons.apple,
              color: Colors.black,
              onTap: () {
                HapticFeedback.lightImpact();
                // TODO: Apple 로그인
              },
            ),
            const SizedBox(width: 12),
            _buildSocialButton(
              icon: Icons.chat_bubble,
              color: const Color(0xFFFEE500),
              onTap: () {
                HapticFeedback.lightImpact();
                // TODO: Kakao 로그인
              },
            ),
          ],
        ),
      ],
    ).animate()
      .fadeIn(delay: 1200.ms, duration: 600.ms);
  }
  
  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
          BoxShadow(
            color: StudyMateTheme.primaryBlue.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 3),
          ),
        ],
        ),
        child: Icon(
          icon,
          color: color,
          size: 24,
        ),
      ),
    );
  }
  
  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '아직 계정이 없으신가요?',
          style: TextStyle(
            color: StudyMateTheme.grayText,
            fontSize: 13,
          ),
        ),
        TextButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ModernRegisterScreen(),
              ),
            );
          },
          child: Text(
            '회원가입',
            style: TextStyle(
              color: StudyMateTheme.primaryBlue,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ).animate()
      .fadeIn(delay: 1300.ms, duration: 600.ms);
  }
}