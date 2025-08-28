import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

/// Raw 키보드 이벤트를 직접 처리하는 한글 입력 필드
class RawKoreanField extends StatefulWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const RawKoreanField({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  State<RawKoreanField> createState() => _RawKoreanFieldState();
}

class _RawKoreanFieldState extends State<RawKoreanField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        // 키 이벤트 디버깅
        if (event is RawKeyDownEvent) {
          debugPrint('Key pressed: ${event.logicalKey}');
          debugPrint('Character: ${event.character}');
        }
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: _isFocused ? Colors.blue : Colors.grey,
            width: _isFocused ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            if (widget.prefixIcon != null)
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: widget.prefixIcon!,
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  obscureText: widget.obscureText,
                  style: const TextStyle(fontSize: 16),
                  
                  // 기본 TextField 설정
                  decoration: InputDecoration(
                    labelText: widget.labelText,
                    hintText: widget.hintText,
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  
                  // 텍스트 입력 설정
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  
                  // IME 설정 - 최소한의 간섭
                  autocorrect: false,
                  enableSuggestions: false,
                  enableIMEPersonalizedLearning: false,
                  
                  // 입력 제한 없음
                  inputFormatters: const [],
                  maxLines: 1,
                  
                  // 텍스트 변경 콜백
                  onChanged: (text) {
                    debugPrint('Text changed: $text');
                    debugPrint('Text length: ${text.length}');
                    debugPrint('Text bytes: ${utf8.encode(text)}');
                  },
                ),
              ),
            ),
            if (widget.suffixIcon != null)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: widget.suffixIcon!,
              ),
          ],
        ),
      ),
    );
  }
}