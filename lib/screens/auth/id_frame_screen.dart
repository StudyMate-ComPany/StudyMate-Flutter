import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/studymate_theme.dart';
import '../../widgets/korean_enabled_text_field.dart';
import 'password_frame_screen.dart';

class IdFrameScreen extends StatefulWidget {
  const IdFrameScreen({super.key});

  @override
  State<IdFrameScreen> createState() => _IdFrameScreenState();
}

class _IdFrameScreenState extends State<IdFrameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
    // 자동으로 키보드 올리기
    Future.delayed(const Duration(milliseconds: 500), () {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _validateEmail() {
    final email = _emailController.text.trim();
    final isValid = email.isNotEmpty && 
                   RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
    
    if (_isValid != isValid) {
      setState(() {
        _isValid = isValid;
      });
    }
  }

  void _handleNext() {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      
      // 비밀번호 화면으로 이동 (이메일 전달)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PasswordFrameScreen(
            email: _emailController.text.trim(),
          ),
        ),
      );
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
                  value: 0.5,
                  backgroundColor: StudyMateTheme.grayText.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    StudyMateTheme.primaryBlue,
                  ),
                  minHeight: 4,
                ).animate()
                  .scaleX(
                    begin: 0,
                    end: 1,
                    duration: 500.ms,
                    alignment: Alignment.centerLeft,
                  ),
                
                const SizedBox(height: 40),
                
                // 타이틀
                Text(
                  '이메일을\n입력해주세요',
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
                
                // 서브 타이틀
                Text(
                  'StudyMate 계정으로 사용할 이메일을 입력해주세요',
                  style: TextStyle(
                    fontSize: 15,
                    color: StudyMateTheme.grayText,
                    height: 1.5,
                  ),
                ).animate()
                  .fadeIn(delay: 200.ms, duration: 500.ms),
                
                const SizedBox(height: 40),
                
                // 이메일 입력 필드
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
                    focusNode: _focusNode,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofocus: false,
                    labelText: '이메일',
                    hintText: 'example@email.com',
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: StudyMateTheme.primaryBlue,
                    ),
                    suffixIcon: _emailController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              _isValid ? Icons.check_circle : Icons.cancel,
                              color: _isValid ? Colors.green : Colors.red,
                            ),
                            onPressed: () {
                              _emailController.clear();
                            },
                          )
                        : null,
                    decoration: InputDecoration(
                      labelText: '이메일',
                      hintText: 'example@email.com',
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: StudyMateTheme.primaryBlue,
                      ),
                      suffixIcon: _emailController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                _isValid ? Icons.check_circle : Icons.cancel,
                                color: _isValid ? Colors.green : Colors.red,
                              ),
                              onPressed: () {
                                _emailController.clear();
                              },
                            )
                          : null,
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
                    onFieldSubmitted: (_) => _handleNext(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '이메일을 입력해주세요';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return '올바른 이메일 형식이 아닙니다';
                      }
                      return null;
                    },
                  ),
                ).animate()
                  .fadeIn(delay: 400.ms, duration: 500.ms)
                  .slideY(begin: 0.2, end: 0),
                
                const SizedBox(height: 16),
                
                // 이메일 형식 안내
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: StudyMateTheme.primaryBlue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 20,
                        color: StudyMateTheme.primaryBlue,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '유효한 이메일 주소를 입력해주세요',
                          style: TextStyle(
                            fontSize: 13,
                            color: StudyMateTheme.darkNavy,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate()
                  .fadeIn(delay: 600.ms, duration: 500.ms),
                
                const Spacer(),
                
                // 다음 버튼
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isValid ? _handleNext : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: StudyMateTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      disabledBackgroundColor: StudyMateTheme.grayText.withOpacity(0.3),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '다음',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: _isValid ? Colors.white : StudyMateTheme.grayText,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 20,
                          color: _isValid ? Colors.white : StudyMateTheme.grayText,
                        ),
                      ],
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