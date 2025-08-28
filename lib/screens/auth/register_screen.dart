import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../widgets/korean_text_field.dart';
import '../home/new_home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _agreeToPrivacy = false;
  
  late AnimationController _animationController;
  late AnimationController _checkAnimationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    
    _checkAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    _checkAnimationController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeToTerms || !_agreeToPrivacy) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('약관에 동의해주세요 😊'),
          backgroundColor: AppTheme.warningColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.register(
      _emailController.text.trim(),
      _passwordController.text,
      _nameController.text.trim(),
      username: _usernameController.text.trim(),
      passwordConfirm: _confirmPasswordController.text,
      termsAccepted: _agreeToTerms,
      privacyAccepted: _agreeToPrivacy,
    );

    if (mounted) {
      setState(() => _isLoading = false);

      if (success) {
        // 회원가입 성공 시 바로 메인 화면으로 이동 (AuthProvider에서 이미 자동 로그인 처리됨)
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const NewHomeScreen(),
          ),
          (route) => false, // 모든 이전 화면을 스택에서 제거하여 뒤로가기 방지
        );
      } else if (authProvider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage!),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
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
        backgroundColor: AppTheme.backgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 뒤로가기 버튼
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                    ),
                  ).animate()
                    .fadeIn(duration: 600.ms)
                    .slideX(begin: -0.2, end: 0),
                  
                  const SizedBox(height: 20),
                  
                  // 타이틀
                  Center(
                    child: Column(
                      children: [
                        AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.secondaryColor,
                                    AppTheme.primaryColor,
                                    AppTheme.accentColor,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  transform: GradientRotation(_animationController.value * 2 * 3.14159),
                                ),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryColor.withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: Offset(0, 10 * _animationController.value),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.school_rounded,
                                size: 50,
                                color: Colors.white,
                              ),
                            );
                          },
                        ).animate()
                          .fadeIn(duration: 800.ms)
                          .scale(delay: 200.ms),
                        
                        const SizedBox(height: 20),
                        
                        const Text(
                          '회원가입',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ).animate()
                          .fadeIn(delay: 400.ms)
                          .slideY(begin: -0.2, end: 0),
                        
                        const SizedBox(height: 8),
                        
                        const Text(
                          '스터디메이트와 함께 시작해요! 🚀',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey,
                          ),
                        ).animate()
                          .fadeIn(delay: 600.ms),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // 회원가입 폼
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // 이름 필드
                        _buildTextField(
                          controller: _nameController,
                          label: '이름',
                          hint: '홍길동',
                          icon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '이름을 입력해주세요';
                            }
                            return null;
                          },
                          delay: 800,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // 사용자명 필드
                        _buildTextField(
                          controller: _usernameController,
                          label: '사용자 이름',
                          hint: '사용자123',
                          icon: Icons.badge_outlined,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '사용자 이름을 입력해주세요';
                            }
                            if (value.length < 3) {
                              return '3자 이상 입력해주세요';
                            }
                            return null;
                          },
                          delay: 900,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // 이메일 필드
                        _buildTextField(
                          controller: _emailController,
                          label: '이메일',
                          hint: '이메일@example.com',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '이메일을 입력해주세요';
                            }
                            if (!value.contains('@')) {
                              return '올바른 이메일 주소를 입력해주세요';
                            }
                            return null;
                          },
                          delay: 1000,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // 비밀번호 필드
                        _buildPasswordField(
                          controller: _passwordController,
                          label: '비밀번호',
                          hint: '대문자, 특수문자 포함 8자 이상',
                          obscure: _obscurePassword,
                          onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '비밀번호를 입력해주세요';
                            }
                            if (value.length < 8) {
                              return '8자 이상 입력해주세요';
                            }
                            if (!RegExp(r'[A-Z]').hasMatch(value)) {
                              return '대문자를 포함해주세요';
                            }
                            if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                              return '특수문자를 포함해주세요';
                            }
                            return null;
                          },
                          delay: 1100,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // 비밀번호 확인 필드
                        _buildPasswordField(
                          controller: _confirmPasswordController,
                          label: '비밀번호 확인',
                          hint: '비밀번호를 다시 입력하세요',
                          obscure: _obscureConfirmPassword,
                          onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '비밀번호를 다시 입력해주세요';
                            }
                            if (value != _passwordController.text) {
                              return '비밀번호가 일치하지 않아요';
                            }
                            return null;
                          },
                          delay: 1200,
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // 약관 동의
                        _buildCheckbox(
                          value: _agreeToTerms,
                          onChanged: (value) => setState(() => _agreeToTerms = value!),
                          text: '이용약관에 동의합니다',
                          delay: 1300,
                        ),
                        
                        const SizedBox(height: 12),
                        
                        _buildCheckbox(
                          value: _agreeToPrivacy,
                          onChanged: (value) => setState(() => _agreeToPrivacy = value!),
                          text: '개인정보처리방침에 동의합니다',
                          delay: 1400,
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // 회원가입 버튼
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              elevation: 8,
                              shadowColor: AppTheme.primaryColor.withOpacity(0.4),
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
                                  '가입하기',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                          ),
                        ).animate()
                          .fadeIn(delay: 1500.ms)
                          .scale(delay: 1500.ms),
                        
                        const SizedBox(height: 24),
                        
                        // 로그인 링크
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              '이미 계정이 있으신가요?',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                '로그인',
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ).animate()
                          .fadeIn(delay: 1600.ms),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    required int delay,
  }) {
    return KoreanTextField(
      controller: controller,
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(
        icon,
        color: AppTheme.primaryColor,
      ),
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      validator: validator,
    ).animate()
      .fadeIn(delay: delay.ms)
      .slideX(begin: -0.2, end: 0);
  }
  
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
    required int delay,
  }) {
    return KoreanTextField(
      controller: controller,
      labelText: label,
      hintText: hint,
      obscureText: obscure,
      prefixIcon: const Icon(
        Icons.lock_outline,
        color: AppTheme.primaryColor,
      ),
      suffixIcon: IconButton(
        icon: Icon(
          obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: Colors.grey,
        ),
        onPressed: onToggle,
      ),
      textInputAction: TextInputAction.next,
      validator: validator,
    ).animate()
      .fadeIn(delay: delay.ms)
      .slideX(begin: -0.2, end: 0);
  }
  
  Widget _buildCheckbox({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String text,
    required int delay,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: value ? AppTheme.primaryColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: value ? AppTheme.primaryColor : Colors.grey.shade300,
            width: value ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: value ? AppTheme.primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: value ? AppTheme.primaryColor : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: value
                ? const Icon(
                    Icons.check,
                    size: 16,
                    color: Colors.white,
                  )
                : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  color: value ? AppTheme.primaryColor : Colors.grey.shade700,
                  fontWeight: value ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate()
      .fadeIn(delay: delay.ms)
      .slideX(begin: -0.2, end: 0);
  }
}