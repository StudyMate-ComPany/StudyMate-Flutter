import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 모든 언어 입력을 지원하는 범용 텍스트 필드
class UniversalTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onFieldSubmitted;
  final bool autofocus;

  const UniversalTextField({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.validator,
    this.textInputAction,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      textInputAction: textInputAction,
      onEditingComplete: onEditingComplete,
      onFieldSubmitted: onFieldSubmitted,
      autofocus: autofocus,
      
      // 한글 입력을 위한 핵심 설정
      keyboardType: TextInputType.text,  // 명시적으로 text 타입 지정
      maxLines: 1,
      
      // Android IME 설정
      enableSuggestions: false,
      autocorrect: false,
      enableIMEPersonalizedLearning: false,  // 이 설정이 한글 입력을 방해할 수 있음
      
      // 입력 포맷터 제거 - 모든 문자 허용
      inputFormatters: const [],
      
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.all(20),
      ),
    );
  }
}