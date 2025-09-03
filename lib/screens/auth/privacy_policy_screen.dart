import 'package:flutter/material.dart';
import 'studymate_ready_screen.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  final VoidCallback? onAgreementComplete;
  const PrivacyPolicyScreen({super.key, this.onAgreementComplete});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
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
          '개인정보처리방침',
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
                    'StudyMate 개인정보처리방침',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '제1조 (개인정보의 수집 및 이용목적)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'StudyMate는 다음의 목적을 위하여 개인정보를 처리합니다. 처리하고 있는 개인정보는 다음의 목적 이외의 용도로는 이용되지 않으며, 이용 목적이 변경되는 경우에는 별도의 동의를 받는 등 필요한 조치를 이행할 예정입니다.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Color(0xFF555555),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '제2조 (수집하는 개인정보 항목)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '1. 필수 수집 항목\n'
                    '   - 이메일 주소\n'
                    '   - 닉네임\n'
                    '   - 소셜 로그인 정보 (카카오, 구글, 네이버)\n'
                    '2. 자동 수집 항목\n'
                    '   - 서비스 이용 기록\n'
                    '   - 접속 로그\n'
                    '   - 학습 데이터 및 진도',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Color(0xFF555555),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '제3조 (개인정보의 보유 및 이용기간)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '회사는 법령에 따른 개인정보 보유·이용기간 또는 이용자로부터 개인정보를 수집 시에 동의받은 개인정보 보유·이용기간 내에서 개인정보를 처리·보유합니다.\n\n'
                    '1. 회원 정보: 회원 탈퇴 시까지\n'
                    '2. 관련 법령에 따른 보유 정보\n'
                    '   - 계약 또는 청약철회 등에 관한 기록: 5년\n'
                    '   - 대금결제 및 재화 등의 공급에 관한 기록: 5년',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Color(0xFF555555),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '제4조 (개인정보의 파기)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '회사는 개인정보 보유기간의 경과, 처리목적 달성 등 개인정보가 불필요하게 되었을 때에는 지체없이 해당 개인정보를 파기합니다.\n\n'
                    '파기 절차 및 방법은 다음과 같습니다:\n'
                    '1. 파기절차: 이용자의 개인정보는 목적이 달성된 후 즉시 파기됩니다.\n'
                    '2. 파기방법: 전자적 파일 형태의 정보는 기록을 재생할 수 없는 기술적 방법을 사용합니다.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Color(0xFF555555),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '제5조 (이용자의 권리와 의무)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '이용자는 개인정보주체로서 다음과 같은 권리를 행사할 수 있습니다:\n\n'
                    '1. 개인정보 열람요구\n'
                    '2. 오류 등이 있을 경우 정정 요구\n'
                    '3. 삭제요구\n'
                    '4. 처리정지 요구',
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
                        '위 개인정보처리방침에 동의합니다',
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
                        ? () {
                            if (widget.onAgreementComplete != null) {
                              // 콜백이 있으면 약관 동의만 완료하고 콜백 실행
                              Navigator.popUntil(context, (route) => route.isFirst);
                              widget.onAgreementComplete!();
                            } else {
                              // 콜백이 없으면 기존처럼 준비 화면으로 이동
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const StudyMateReadyScreen(),
                                ),
                              );
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

