import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../theme/modern_theme.dart';
import '../../widgets/korean_enabled_text_field.dart';
import '../home/new_home_screen.dart';

class ModernRegisterScreen extends StatefulWidget {
  const ModernRegisterScreen({super.key});

  @override
  State<ModernRegisterScreen> createState() => _ModernRegisterScreenState();
}

class _ModernRegisterScreenState extends State<ModernRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreeToTerms = false;
  bool _agreeToPrivacy = false;
  bool _isLoading = false;
  
  int _currentStep = 0;
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate() && _agreeToTerms && _agreeToPrivacy) {
      HapticFeedback.mediumImpact();
      
      setState(() {
        _isLoading = true;
      });
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.register(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
        termsAccepted: _agreeToTerms,
        privacyAccepted: _agreeToPrivacy,
      );
      
      setState(() {
        _isLoading = false;
      });
      
      if (!mounted) return;
      
      if (success) {
        // 회원가입 성공 시 바로 메인 화면으로 이동 (AuthProvider에서 이미 자동 로그인 처리됨)
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const NewHomeScreen(),
          ),
          (route) => false, // 모든 이전 화면을 스택에서 제거하여 뒤로가기 방지
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? '회원가입에 실패했습니다'),
            backgroundColor: ModernTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } else if (!_agreeToTerms || !_agreeToPrivacy) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('약관에 동의해주세요'),
          backgroundColor: ModernTheme.warningColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: ModernTheme.cardShadow,
            ),
            child: const Icon(
              Icons.arrow_back,
              color: ModernTheme.textPrimary,
              size: 20,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // Title
              _buildTitle(),
              
              const SizedBox(height: 8),
              
              // Progress Indicator
              _buildProgressIndicator(),
              
              const SizedBox(height: 32),
              
              // Form
              _buildRegisterForm(),
              
              const SizedBox(height: 24),
              
              // Terms Agreement
              _buildTermsAgreement(),
              
              const SizedBox(height: 32),
              
              // Register Button
              _buildRegisterButton(),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '회원가입',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: ModernTheme.textPrimary,
            letterSpacing: -0.5,
          ),
        ).animate()
          .fadeIn(duration: 600.ms)
          .slideY(begin: -0.2, end: 0),
        
        const SizedBox(height: 8),
        
        Text(
          'StudyMate와 함께 학습을 시작해보세요',
          style: TextStyle(
            fontSize: 16,
            color: ModernTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ).animate()
          .fadeIn(delay: 200.ms, duration: 600.ms),
      ],
    );
  }
  
  Widget _buildProgressIndicator() {
    return Row(
      children: List.generate(4, (index) {
        final isActive = index <= _currentStep;
        return Expanded(
          child: Container(
            height: 4,
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: isActive ? ModernTheme.primaryColor : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ).animate()
            .scaleX(
              begin: 0,
              end: 1,
              delay: (index * 100).ms,
              duration: 400.ms,
            ),
        );
      }),
    );
  }
  
  Widget _buildRegisterForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Name Field
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: ModernTheme.cardShadow,
            ),
            child: TextFormField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              onChanged: (_) => setState(() => _currentStep = 0),
              decoration: InputDecoration(
                labelText: '이름',
                hintText: '홍길동',
                prefixIcon: Icon(
                  Icons.person_outline,
                  color: ModernTheme.primaryColor,
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
                  return '이름을 입력해주세요';
                }
                if (value.length < 2) {
                  return '이름은 2자 이상이어야 합니다';
                }
                return null;
              },
            ),
          ).animate()
            .fadeIn(delay: 400.ms, duration: 600.ms)
            .slideX(begin: -0.2, end: 0),
          
          const SizedBox(height: 16),
          
          // Email Field
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: ModernTheme.cardShadow,
            ),
            child: TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              onChanged: (_) => setState(() => _currentStep = 1),
              decoration: InputDecoration(
                labelText: '이메일',
                hintText: 'example@email.com',
                prefixIcon: Icon(
                  Icons.email_outlined,
                  color: ModernTheme.primaryColor,
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
            .fadeIn(delay: 500.ms, duration: 600.ms)
            .slideX(begin: -0.2, end: 0),
          
          const SizedBox(height: 16),
          
          // Password Field
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: ModernTheme.cardShadow,
            ),
            child: TextFormField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              textInputAction: TextInputAction.next,
              onChanged: (_) => setState(() => _currentStep = 2),
              decoration: InputDecoration(
                labelText: '비밀번호',
                hintText: '6자 이상',
                prefixIcon: Icon(
                  Icons.lock_outline,
                  color: ModernTheme.primaryColor,
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                    color: ModernTheme.textSecondary,
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
            .fadeIn(delay: 600.ms, duration: 600.ms)
            .slideX(begin: -0.2, end: 0),
          
          const SizedBox(height: 16),
          
          // Confirm Password Field
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: ModernTheme.cardShadow,
            ),
            child: TextFormField(
              controller: _confirmPasswordController,
              obscureText: !_isConfirmPasswordVisible,
              textInputAction: TextInputAction.done,
              onChanged: (_) => setState(() => _currentStep = 3),
              decoration: InputDecoration(
                labelText: '비밀번호 확인',
                hintText: '비밀번호를 다시 입력해주세요',
                prefixIcon: Icon(
                  Icons.lock_outline,
                  color: ModernTheme.primaryColor,
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                  icon: Icon(
                    _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                    color: ModernTheme.textSecondary,
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
                  return '비밀번호를 다시 입력해주세요';
                }
                if (value != _passwordController.text) {
                  return '비밀번호가 일치하지 않습니다';
                }
                return null;
              },
            ),
          ).animate()
            .fadeIn(delay: 700.ms, duration: 600.ms)
            .slideX(begin: -0.2, end: 0),
        ],
      ),
    );
  }
  
  Widget _buildTermsAgreement() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: ModernTheme.cardShadow,
      ),
      child: Column(
        children: [
          // 전체 동의
          InkWell(
            onTap: () {
              setState(() {
                final newValue = !(_agreeToTerms && _agreeToPrivacy);
                _agreeToTerms = newValue;
                _agreeToPrivacy = newValue;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (_agreeToTerms && _agreeToPrivacy)
                    ? ModernTheme.primaryColor.withOpacity(0.1)
                    : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    (_agreeToTerms && _agreeToPrivacy)
                        ? Icons.check_circle
                        : Icons.check_circle_outline,
                    color: (_agreeToTerms && _agreeToPrivacy)
                        ? ModernTheme.primaryColor
                        : Colors.grey[400],
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '전체 동의',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: ModernTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 8),
          
          // 이용약관
          _buildCheckboxItem(
            value: _agreeToTerms,
            onChanged: (value) {
              setState(() {
                _agreeToTerms = value ?? false;
              });
            },
            title: '[필수] 이용약관 동의',
            onTap: () {
              // TODO: 이용약관 보기
            },
          ),
          
          // 개인정보처리방침
          _buildCheckboxItem(
            value: _agreeToPrivacy,
            onChanged: (value) {
              setState(() {
                _agreeToPrivacy = value ?? false;
              });
            },
            title: '[필수] 개인정보처리방침 동의',
            onTap: () {
              // TODO: 개인정보처리방침 보기
            },
          ),
        ],
      ),
    ).animate()
      .fadeIn(delay: 800.ms, duration: 600.ms)
      .slideY(begin: 0.1, end: 0);
  }
  
  Widget _buildCheckboxItem({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                activeColor: ModernTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: ModernTheme.textPrimary,
                ),
              ),
            ),
            IconButton(
              onPressed: onTap,
              icon: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: ModernTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRegisterButton() {
    final isValid = _agreeToTerms && _agreeToPrivacy;
    
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: (_isLoading || !isValid) ? null : _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: isValid ? ModernTheme.primaryColor : Colors.grey[300],
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                '가입하기',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    ).animate()
      .fadeIn(delay: 900.ms, duration: 600.ms)
      .slideY(begin: 0.2, end: 0);
  }
}