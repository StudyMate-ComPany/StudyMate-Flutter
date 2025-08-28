import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// IME (Input Method Editor) 지원 텍스트 필드
/// 한글, 일본어, 중국어 등 조합형 문자 입력을 지원
class IMETextField extends StatefulWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;

  const IMETextField({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.focusNode,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  State<IMETextField> createState() => _IMETextFieldState();
}

class _IMETextFieldState extends State<IMETextField> {
  late FocusNode _focusNode;
  late TextEditingController _controller;
  String _composingText = '';

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _controller = widget.controller;
    
    // 컨트롤러 리스너 추가
    _controller.addListener(_handleTextChange);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _handleTextChange() {
    if (widget.onChanged != null) {
      widget.onChanged!(_controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return EditableText(
      controller: _controller,
      focusNode: _focusNode,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 16,
      ),
      cursorColor: Theme.of(context).primaryColor,
      backgroundCursorColor: Colors.grey,
      keyboardType: widget.keyboardType ?? TextInputType.text,
      textInputAction: widget.textInputAction ?? TextInputAction.next,
      obscureText: widget.obscureText,
      autocorrect: false,
      enableSuggestions: false,
      onSubmitted: widget.onSubmitted,
      // IME 관련 설정
      enableIMEPersonalizedLearning: false,
      enableInteractiveSelection: true,
      minLines: 1,
      maxLines: 1,
      // 입력 포맷터 - 모든 문자 허용
      inputFormatters: const <TextInputFormatter>[],
      // 선택 컨트롤 빌더
      selectionControls: MaterialTextSelectionControls(),
      // 커서 너비
      cursorWidth: 2.0,
      // 스크롤 설정
      scrollPhysics: const NeverScrollableScrollPhysics(),
      rendererIgnoresPointer: false,
    );
  }
}

/// 간단한 래퍼 위젯
class SimpleIMETextField extends StatelessWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputAction? textInputAction;
  final void Function(String)? onSubmitted;

  const SimpleIMETextField({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          if (prefixIcon != null) prefixIcon!,
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (labelText != null)
                    Text(
                      labelText!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  IMETextField(
                    controller: controller,
                    obscureText: obscureText,
                    keyboardType: keyboardType,
                    textInputAction: textInputAction,
                    onSubmitted: onSubmitted,
                  ),
                  if (hintText != null && controller.text.isEmpty)
                    Text(
                      hintText!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (suffixIcon != null) suffixIcon!,
        ],
      ),
    );
  }
}