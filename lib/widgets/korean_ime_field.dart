import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 한글 IME를 강제로 활성화하는 TextField
class KoreanIMEField extends StatefulWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const KoreanIMEField({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
  });

  @override
  State<KoreanIMEField> createState() => _KoreanIMEFieldState();
}

class _KoreanIMEFieldState extends State<KoreanIMEField> {
  final FocusNode _focusNode = FocusNode();
  
  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }
  
  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      // 포커스를 받으면 한글 IME 활성화 시도
      _activateKoreanIME();
    }
  }
  
  Future<void> _activateKoreanIME() async {
    // 플랫폼 채널을 통해 네이티브 코드에서 한글 IME 활성화
    try {
      const platform = MethodChannel('com.studymate/korean_input');
      await platform.invokeMethod('enableKoreanInput');
    } catch (e) {
      debugPrint('한글 IME 활성화 실패: $e');
    }
  }
  
  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      obscureText: widget.obscureText,
      validator: widget.validator,
      
      // 키보드 타입 설정
      keyboardType: widget.keyboardType ?? TextInputType.text,
      
      // IME 설정
      enableIMEPersonalizedLearning: false,
      enableSuggestions: false,
      autocorrect: false,
      
      // 텍스트 입력 액션
      textInputAction: TextInputAction.next,
      
      // 한글 입력을 위한 추가 설정
      inputFormatters: [
        // 한글 입력 허용
        FilteringTextInputFormatter.allow(
          RegExp(r'[a-zA-Z0-9ㄱ-ㅎㅏ-ㅣ가-힣@._\-\s]'),
        ),
      ],
      
      // 장식
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
      ),
      
      // 텍스트 변경 콜백
      onChanged: (text) {
        // 한글 조합 중인지 체크
        if (text.isNotEmpty) {
          final lastChar = text[text.length - 1];
          if (_isKoreanConsonant(lastChar) || _isKoreanVowel(lastChar)) {
            debugPrint('한글 조합 중: $lastChar');
          }
        }
      },
    );
  }
  
  // 한글 자음 체크
  bool _isKoreanConsonant(String char) {
    final code = char.codeUnitAt(0);
    return (code >= 0x3131 && code <= 0x314E) || // ㄱ-ㅎ
           (code >= 0x1100 && code <= 0x1112); // 초성
  }
  
  // 한글 모음 체크  
  bool _isKoreanVowel(String char) {
    final code = char.codeUnitAt(0);
    return (code >= 0x314F && code <= 0x3163) || // ㅏ-ㅣ
           (code >= 0x1161 && code <= 0x1175); // 중성
  }
}