import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 한글 입력을 처리하는 헬퍼 클래스
class KoreanInputHandler {
  // 한글 자음
  static const List<String> consonants = [
    'ㄱ', 'ㄲ', 'ㄴ', 'ㄷ', 'ㄸ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅃ',
    'ㅅ', 'ㅆ', 'ㅇ', 'ㅈ', 'ㅉ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ'
  ];
  
  // 한글 모음
  static const List<String> vowels = [
    'ㅏ', 'ㅐ', 'ㅑ', 'ㅒ', 'ㅓ', 'ㅔ', 'ㅕ', 'ㅖ', 'ㅗ', 'ㅘ',
    'ㅙ', 'ㅚ', 'ㅛ', 'ㅜ', 'ㅝ', 'ㅞ', 'ㅟ', 'ㅠ', 'ㅡ', 'ㅢ', 'ㅣ'
  ];
  
  // 한글 종성
  static const List<String?> finalConsonants = [
    null, 'ㄱ', 'ㄲ', 'ㄳ', 'ㄴ', 'ㄵ', 'ㄶ', 'ㄷ', 'ㄹ', 'ㄺ',
    'ㄻ', 'ㄼ', 'ㄽ', 'ㄾ', 'ㄿ', 'ㅀ', 'ㅁ', 'ㅂ', 'ㅄ', 'ㅅ',
    'ㅆ', 'ㅇ', 'ㅈ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ'
  ];
  
  // 영문 키보드 매핑 (QWERTY to 한글)
  static const Map<String, String> qwertyToKorean = {
    // 자음
    'r': 'ㄱ', 'R': 'ㄲ',
    's': 'ㄴ',
    'e': 'ㄷ', 'E': 'ㄸ',
    'f': 'ㄹ',
    'a': 'ㅁ',
    'q': 'ㅂ', 'Q': 'ㅃ',
    't': 'ㅅ', 'T': 'ㅆ',
    'd': 'ㅇ',
    'w': 'ㅈ', 'W': 'ㅉ',
    'c': 'ㅊ',
    'z': 'ㅋ',
    'x': 'ㅌ',
    'v': 'ㅍ',
    'g': 'ㅎ',
    // 모음
    'k': 'ㅏ',
    'o': 'ㅐ',
    'i': 'ㅑ',
    'O': 'ㅒ',
    'j': 'ㅓ',
    'p': 'ㅔ',
    'u': 'ㅕ',
    'P': 'ㅖ',
    'h': 'ㅗ',
    'hk': 'ㅘ',
    'ho': 'ㅙ',
    'hl': 'ㅚ',
    'y': 'ㅛ',
    'n': 'ㅜ',
    'nj': 'ㅝ',
    'np': 'ㅞ',
    'nl': 'ㅟ',
    'b': 'ㅠ',
    'm': 'ㅡ',
    'ml': 'ㅢ',
    'l': 'ㅣ',
  };
  
  /// 한글 조합을 위한 버퍼
  String _buffer = '';
  
  /// 영문 입력을 한글로 변환
  String convertToKorean(String input) {
    if (qwertyToKorean.containsKey(input)) {
      return qwertyToKorean[input]!;
    }
    return input;
  }
  
  /// 한글 조합 (자음 + 모음 = 글자)
  String? combineKorean(String consonant, String vowel, String? finalConsonant) {
    final choIndex = consonants.indexOf(consonant);
    final jungIndex = vowels.indexOf(vowel);
    final jongIndex = finalConsonant != null ? 
        finalConsonants.indexOf(finalConsonant) : 0;
    
    if (choIndex == -1 || jungIndex == -1) return null;
    
    // 한글 유니코드 계산 공식
    final unicode = 0xAC00 + (choIndex * 21 * 28) + (jungIndex * 28) + jongIndex;
    return String.fromCharCode(unicode);
  }
  
  /// 텍스트 필드에서 한글 입력 처리
  String processKoreanInput(String currentText, String newChar) {
    // 영문을 한글로 변환
    final koreanChar = convertToKorean(newChar);
    
    // 버퍼에 추가
    _buffer += koreanChar;
    
    // 조합 시도
    if (_buffer.length >= 2) {
      final lastTwo = _buffer.substring(_buffer.length - 2);
      // 자음 + 모음 조합 체크
      if (consonants.contains(lastTwo[0]) && vowels.contains(lastTwo[1])) {
        final combined = combineKorean(lastTwo[0], lastTwo[1], null);
        if (combined != null) {
          _buffer = _buffer.substring(0, _buffer.length - 2) + combined;
        }
      }
    }
    
    return currentText + _buffer;
  }
  
  /// 버퍼 초기화
  void clearBuffer() {
    _buffer = '';
  }
}

/// 한글 입력을 지원하는 TextField 위젯
class KoreanEnabledTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final bool enableKoreanInput;

  const KoreanEnabledTextField({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.enableKoreanInput = true,
  });

  @override
  State<KoreanEnabledTextField> createState() => _KoreanEnabledTextFieldState();
}

class _KoreanEnabledTextFieldState extends State<KoreanEnabledTextField> {
  final KoreanInputHandler _koreanHandler = KoreanInputHandler();
  bool _isKoreanMode = false;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.enableKoreanInput)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                _isKoreanMode ? '한글' : 'ENG',
                style: TextStyle(
                  fontSize: 12,
                  color: _isKoreanMode ? Colors.blue : Colors.grey,
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                value: _isKoreanMode,
                onChanged: (value) {
                  setState(() {
                    _isKoreanMode = value;
                    if (!value) {
                      _koreanHandler.clearBuffer();
                    }
                  });
                },
                activeColor: Colors.blue,
              ),
            ],
          ),
        TextFormField(
          controller: widget.controller,
          obscureText: widget.obscureText,
          validator: widget.validator,
          
          decoration: InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.suffixIcon ?? (_isKoreanMode ? 
              Icon(Icons.language, color: Colors.blue) : null),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            filled: true,
            fillColor: Theme.of(context).inputDecorationTheme.fillColor,
          ),
          
          onChanged: (text) {
            if (_isKoreanMode && text.isNotEmpty) {
              // 한글 모드일 때 입력 처리
              final lastChar = text[text.length - 1];
              if (RegExp(r'[a-zA-Z]').hasMatch(lastChar)) {
                // 영문자가 입력되면 한글로 변환
                final processed = _koreanHandler.processKoreanInput(
                  text.substring(0, text.length - 1),
                  lastChar,
                );
                widget.controller.text = processed;
                widget.controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: processed.length),
                );
              }
            }
          },
        ),
      ],
    );
  }
}