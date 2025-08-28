import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 한글 입력을 완벽하게 지원하는 범용 텍스트 필드
/// 모든 앱 내 텍스트 필드에서 이 위젯을 사용하면 한글 입력이 가능합니다
class KoreanEnabledTextField extends StatefulWidget {
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
  final int? minLines;
  final bool enabled;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final TextStyle? style;
  final InputDecoration? decoration;
  final TextAlign textAlign;
  final bool readOnly;
  final int? maxLength;
  final MaxLengthEnforcement? maxLengthEnforcement;
  final TextCapitalization textCapitalization;

  const KoreanEnabledTextField({
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
    this.minLines,
    this.enabled = true,
    this.keyboardType,
    this.inputFormatters,
    this.focusNode,
    this.style,
    this.decoration,
    this.textAlign = TextAlign.start,
    this.readOnly = false,
    this.maxLength,
    this.maxLengthEnforcement,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  State<KoreanEnabledTextField> createState() => _KoreanEnabledTextFieldState();
}

class _KoreanEnabledTextFieldState extends State<KoreanEnabledTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  String _composingText = '';

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  InputDecoration _getDecoration() {
    if (widget.decoration != null) {
      return widget.decoration!;
    }
    
    return InputDecoration(
      labelText: widget.labelText,
      hintText: widget.hintText,
      prefixIcon: widget.prefixIcon,
      suffixIcon: widget.suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 비밀번호 필드인 경우 기본 TextFormField 사용
    if (widget.obscureText) {
      return TextFormField(
        controller: _controller,
        focusNode: _focusNode,
        obscureText: true,
        validator: widget.validator,
        textInputAction: widget.textInputAction,
        onEditingComplete: widget.onEditingComplete,
        onFieldSubmitted: widget.onFieldSubmitted,
        onChanged: widget.onChanged,
        autofocus: widget.autofocus,
        enabled: widget.enabled,
        style: widget.style,
        decoration: _getDecoration(),
        textAlign: widget.textAlign,
        readOnly: widget.readOnly,
        maxLength: widget.maxLength,
        maxLengthEnforcement: widget.maxLengthEnforcement,
        inputFormatters: widget.inputFormatters,
      );
    }

    // 한글 입력을 위한 설정
    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      obscureText: false,
      validator: widget.validator,
      textInputAction: widget.textInputAction,
      onEditingComplete: widget.onEditingComplete,
      onFieldSubmitted: widget.onFieldSubmitted,
      onChanged: (value) {
        // 한글 조합 중 상태 처리
        setState(() {
          _composingText = value;
        });
        widget.onChanged?.call(value);
      },
      autofocus: widget.autofocus,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      enabled: widget.enabled,
      style: widget.style ?? const TextStyle(fontSize: 16),
      decoration: _getDecoration(),
      textAlign: widget.textAlign,
      readOnly: widget.readOnly,
      maxLength: widget.maxLength,
      maxLengthEnforcement: widget.maxLengthEnforcement,
      textCapitalization: widget.textCapitalization,
      
      // 한글 입력을 위한 핵심 설정
      keyboardType: widget.keyboardType ?? TextInputType.text,
      
      // IME 설정 - 한글 입력에 최적화
      enableSuggestions: false, // 자동 제안 비활성화 (한글 입력 방해 방지)
      autocorrect: false, // 자동 수정 비활성화
      enableIMEPersonalizedLearning: false, // IME 학습 비활성화
      
      // 입력 포맷터 - 기본적으로 모든 문자 허용
      inputFormatters: widget.inputFormatters ?? [],
      
      // 텍스트 입력 연결 설정
      enableInteractiveSelection: true,
      
      // 커서 설정
      cursorColor: Theme.of(context).primaryColor,
      cursorWidth: 2.0,
      cursorHeight: 20.0,
      
      // 추가 설정
      strutStyle: const StrutStyle(
        fontSize: 16,
        height: 1.3,
      ),
    );
  }
}

/// 간단한 한글 입력 텍스트 필드 (기본 설정만 제공)
class SimpleKoreanTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final bool obscureText;

  const SimpleKoreanTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.onChanged,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return KoreanEnabledTextField(
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      onChanged: onChanged,
      obscureText: obscureText,
    );
  }
}