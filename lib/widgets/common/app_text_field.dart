import 'package:flutter/material.dart';
import '../korean_enabled_text_field.dart';

/// 앱 전체에서 사용하는 통합 텍스트 필드
/// 자동으로 한글 입력을 지원합니다
class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onFieldSubmitted;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final int? maxLines;
  final bool enabled;
  final TextInputType? keyboardType;
  final FocusNode? focusNode;
  final TextStyle? style;
  final bool readOnly;

  const AppTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.validator,
    this.textInputAction,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.onChanged,
    this.autofocus = false,
    this.maxLines = 1,
    this.enabled = true,
    this.keyboardType,
    this.focusNode,
    this.style,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return KoreanEnabledTextField(
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      obscureText: obscureText,
      validator: validator,
      textInputAction: textInputAction,
      onEditingComplete: onEditingComplete,
      onFieldSubmitted: onFieldSubmitted,
      onChanged: onChanged,
      autofocus: autofocus,
      maxLines: maxLines,
      enabled: enabled,
      keyboardType: keyboardType,
      focusNode: focusNode,
      style: style,
      readOnly: readOnly,
    );
  }
}