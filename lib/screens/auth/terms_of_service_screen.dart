import 'package:flutter/material.dart';
import 'privacy_policy_screen.dart';

class TermsOfServiceScreen extends StatefulWidget {
  final VoidCallback? onAgreementComplete;
  const TermsOfServiceScreen({super.key, this.onAgreementComplete});

  @override
  State<TermsOfServiceScreen> createState() => _TermsOfServiceScreenState();
}

class _TermsOfServiceScreenState extends State<TermsOfServiceScreen> {
  bool _isAgreed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '이용약관',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'StudyMate 서비스 이용약관',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '제1조 (목적)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '이 약관은 StudyMate(이하 "회사")가 제공하는 학습 플래너 서비스(이하 "서비스")의 이용과 관련하여 회사와 이용자 간의 권리, 의무 및 책임사항을 규정함을 목적으로 합니다.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Color(0xFF555555),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '제2조 (정의)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '1. "서비스"란 회사가 제공하는 모든 학습 관련 서비스를 의미합니다.\n'
                    '2. "이용자"란 이 약관에 따라 회사가 제공하는 서비스를 받는 회원 및 비회원을 말합니다.\n'
                    '3. "회원"이란 회사와 서비스 이용계약을 체결하고 이용자 아이디를 부여받은 이용자를 말합니다.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Color(0xFF555555),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '제3조 (약관의 게시와 개정)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '1. 회사는 이 약관의 내용을 이용자가 쉽게 알 수 있도록 서비스 내에 게시합니다.\n'
                    '2. 회사는 관련 법령에 위배되지 않는 범위에서 이 약관을 개정할 수 있습니다.\n'
                    '3. 개정된 약관은 서비스 내에 공지하며, 공지 후 7일이 경과한 후부터 적용됩니다.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Color(0xFF555555),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '제4조 (서비스의 제공)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '1. 회사는 다음과 같은 서비스를 제공합니다:\n'
                    '   - AI 기반 학습 플래너\n'
                    '   - 퀴즈 및 문제 생성\n'
                    '   - 학습 진도 관리\n'
                    '   - 포모도로 타이머\n'
                    '   - 학습 통계 분석\n'
                    '2. 서비스는 연중무휴, 1일 24시간 제공함을 원칙으로 합니다.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Color(0xFF555555),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '제5조 (회원가입)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '1. 이용자는 회사가 정한 가입 양식에 따라 회원정보를 기입한 후 이 약관에 동의한다는 의사표시를 함으로써 회원가입을 신청합니다.\n'
                    '2. 회사는 제1항과 같이 회원으로 가입할 것을 신청한 이용자 중 다음 각 호에 해당하지 않는 한 회원으로 등록합니다.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Color(0xFF555555),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, -2),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: _isAgreed,
                      onChanged: (value) {
                        setState(() {
                          _isAgreed = value ?? false;
                        });
                      },
                      activeColor: const Color(0xFF70C4DE),
                    ),
                    const Expanded(
                      child: Text(
                        '위 이용약관에 동의합니다',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF1E1E1E),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isAgreed
                        ? () async {
                            if (widget.onAgreementComplete != null) {
                              // 콜백이 있으면 콜백용 화면으로 이동
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PrivacyPolicyScreen(
                                    onAgreementComplete: widget.onAgreementComplete,
                                  ),
                                ),
                              );
                            } else {
                              // 콜백이 없으면 결과 반환용 화면으로 이동
                              final result = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PrivacyPolicyScreen(),
                                ),
                              );
                              if (result == true && mounted) {
                                Navigator.pop(context, true);
                              }
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF70C4DE),
                      disabledBackgroundColor: const Color(0xFFE0E0E0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      '다음',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}