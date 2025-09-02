import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../theme/studymate_theme.dart';
import '../../widgets/korean_enabled_text_field.dart';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  
  bool _isLoading = false;
  bool _isEmailSent = false;
  
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
  
  Future<void> _handlePasswordReset() async {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      
      setState(() {
        _isLoading = true;
      });
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.requestPasswordReset(
        _emailController.text.trim(),
      );
      
      setState(() {
        _isLoading = false;
      });
      
      if (!mounted) return;
      
      if (success) {
        setState(() {
          _isEmailSent = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('비밀번호 재설정 이메일이 전송되었습니다'),
            backgroundColor: StudyMateTheme.primaryBlue,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? '비밀번호 재설정 요청에 실패했습니다'),
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
    return Scaffold(
      backgroundColor: StudyMateTheme.lightBlue,
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
              boxShadow: [
                BoxShadow(
                  color: StudyMateTheme.primaryBlue.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back,
              color: StudyMateTheme.darkNavy,
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
              const SizedBox(height: 40),
              
              // Title & Icon
              _buildHeader(),
              
              const SizedBox(height: 32),
              
              if (!_isEmailSent) ...[
                // Reset Form
                _buildResetForm(),
                
                const SizedBox(height: 32),
                
                // Reset Button
                _buildResetButton(),
              ] else ...[
                // Success Message
                _buildSuccessMessage(),
              ],
              
              const SizedBox(height: 24),
              
              // Back to Login
              _buildBackToLogin(),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                StudyMateTheme.primaryBlue,
                StudyMateTheme.accentPink,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: StudyMateTheme.primaryBlue.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.lock_reset_rounded,
            color: Colors.white,
            size: 32,
          ),
        ).animate()
          .fadeIn(duration: 800.ms)
          .scale(delay: 200.ms),
        
        const SizedBox(height: 24),
        
        // Title
        Text(
          _isEmailSent ? '이메일 전송 완료' : '비밀번호 재설정',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: StudyMateTheme.darkNavy,
            letterSpacing: -0.5,
          ),
        ).animate()
          .fadeIn(delay: 400.ms, duration: 600.ms)
          .slideY(begin: -0.2, end: 0),
        
        const SizedBox(height: 8),
        
        // Subtitle
        Text(
          _isEmailSent
              ? '이메일을 확인해주세요'
              : '이메일 주소를 입력하면 비밀번호 재설정 링크를 보내드립니다',
          style: TextStyle(
            fontSize: 16,
            color: StudyMateTheme.grayText,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ).animate()
          .fadeIn(delay: 600.ms, duration: 600.ms),
      ],
    );
  }
  
  Widget _buildResetForm() {
    return Form(
      key: _formKey,
      child: Container(
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
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _handlePasswordReset(),
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
      ),
    ).animate()
      .fadeIn(delay: 800.ms, duration: 600.ms)
      .slideX(begin: -0.2, end: 0);
  }
  
  Widget _buildResetButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handlePasswordReset,
        style: ElevatedButton.styleFrom(
          backgroundColor: StudyMateTheme.primaryBlue,
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
                '재설정 링크 보내기',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    ).animate()
      .fadeIn(delay: 1000.ms, duration: 600.ms)
      .slideY(begin: 0.2, end: 0);
  }
  
  Widget _buildSuccessMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: StudyMateTheme.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: StudyMateTheme.primaryBlue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.mark_email_read_outlined,
            size: 48,
            color: StudyMateTheme.primaryBlue,
          ),
          const SizedBox(height: 16),
          Text(
            '${_emailController.text}로\n비밀번호 재설정 이메일을 보냈습니다',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: StudyMateTheme.darkNavy,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '이메일을 받지 못하셨다면 스팸 폴더를 확인해주세요',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: StudyMateTheme.grayText,
              height: 1.4,
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 800.ms)
      .scale(delay: 200.ms);
  }
  
  Widget _buildBackToLogin() {
    return Center(
      child: TextButton.icon(
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
        },
        icon: Icon(
          Icons.arrow_back,
          size: 18,
          color: StudyMateTheme.primaryBlue,
        ),
        label: Text(
          '로그인으로 돌아가기',
          style: TextStyle(
            color: StudyMateTheme.primaryBlue,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ).animate()
      .fadeIn(delay: _isEmailSent ? 600.ms : 1200.ms, duration: 600.ms);
  }
}