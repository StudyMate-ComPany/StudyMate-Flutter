import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/modern_theme.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  int _selectedPlanIndex = 1; // 기본으로 3개월 플랜 선택

  final List<SubscriptionPlan> _plans = [
    SubscriptionPlan(
      name: '월간 플랜',
      duration: '1개월',
      price: 9900,
      originalPrice: 9900,
      discount: 0,
      features: [
        '✨ AI 맞춤 학습 플랜',
        '📚 무제한 학습 콘텐츠',
        '🎯 일일 퀴즈 & 복습',
        '📊 학습 분석 리포트',
        '⏰ 맞춤 알림 설정',
      ],
      isPopular: false,
    ),
    SubscriptionPlan(
      name: '3개월 플랜',
      duration: '3개월',
      price: 24900,
      originalPrice: 29700,
      discount: 16,
      features: [
        '✨ AI 맞춤 학습 플랜',
        '📚 무제한 학습 콘텐츠',
        '🎯 일일 퀴즈 & 복습',
        '📊 학습 분석 리포트',
        '⏰ 맞춤 알림 설정',
        '🎁 프리미엄 학습 자료',
      ],
      isPopular: true,
    ),
    SubscriptionPlan(
      name: '연간 플랜',
      duration: '12개월',
      price: 79900,
      originalPrice: 118800,
      discount: 33,
      features: [
        '✨ AI 맞춤 학습 플랜',
        '📚 무제한 학습 콘텐츠',
        '🎯 일일 퀴즈 & 복습',
        '📊 학습 분석 리포트',
        '⏰ 맞춤 알림 설정',
        '🎁 프리미엄 학습 자료',
        '💎 1:1 AI 튜터링',
        '🏆 수료증 발급',
      ],
      isPopular: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ModernTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'StudyMate Premium',
          style: TextStyle(
            color: ModernTheme.textPrimary,
            fontWeight: FontWeight.w700,
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
                  // 헤더 섹션
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: ModernTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: ModernTheme.primaryColor.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.workspace_premium,
                            size: 40,
                            color: Colors.white,
                          ),
                        ).animate()
                          .fadeIn(duration: 600.ms)
                          .scale(),
                        const SizedBox(height: 20),
                        const Text(
                          '프리미엄으로 업그레이드',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: ModernTheme.textPrimary,
                          ),
                        ).animate()
                          .fadeIn(delay: 200.ms),
                        const SizedBox(height: 10),
                        Text(
                          'AI와 함께 더 효과적으로 학습하세요',
                          style: TextStyle(
                            fontSize: 14,
                            color: ModernTheme.textSecondary,
                          ),
                        ).animate()
                          .fadeIn(delay: 400.ms),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 플랜 선택 섹션
                  const Text(
                    '플랜 선택',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ModernTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // 플랜 카드들
                  ...List.generate(_plans.length, (index) {
                    final plan = _plans[index];
                    final isSelected = _selectedPlanIndex == index;
                    
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          _selectedPlanIndex = index;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isSelected ? ModernTheme.primaryLight.withOpacity(0.1) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? ModernTheme.primaryColor : Colors.grey.shade200,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: ModernTheme.primaryColor.withOpacity(0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ]
                              : [],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            plan.name,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: isSelected 
                                                  ? ModernTheme.primaryColor 
                                                  : ModernTheme.textPrimary,
                                            ),
                                          ),
                                          if (plan.isPopular) ...[
                                            const SizedBox(width: 10),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                gradient: ModernTheme.primaryGradient,
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: const Text(
                                                '인기',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        plan.duration,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: ModernTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (plan.discount > 0) ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: ModernTheme.errorColor,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '${plan.discount}% 할인',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                    ],
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        if (plan.originalPrice != plan.price)
                                          Text(
                                            '₩${_formatPrice(plan.originalPrice)}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade400,
                                              decoration: TextDecoration.lineThrough,
                                            ),
                                          ),
                                        const SizedBox(width: 5),
                                        Text(
                                          '₩${_formatPrice(plan.price)}',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected 
                                                ? ModernTheme.primaryColor 
                                                : ModernTheme.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: 24,
                                  height: 24,
                                  margin: const EdgeInsets.only(left: 15),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected 
                                          ? ModernTheme.primaryColor 
                                          : Colors.grey.shade300,
                                      width: 2,
                                    ),
                                    color: isSelected 
                                        ? ModernTheme.primaryColor 
                                        : Colors.transparent,
                                  ),
                                  child: isSelected
                                      ? const Icon(
                                          Icons.check,
                                          size: 14,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                              ],
                            ),
                            if (isSelected) ...[
                              const SizedBox(height: 15),
                              const Divider(),
                              const SizedBox(height: 15),
                              ...plan.features.map((feature) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  feature,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: ModernTheme.textSecondary,
                                  ),
                                ),
                              )),
                            ],
                          ],
                        ),
                      ),
                    ).animate(delay: Duration(milliseconds: 100 * index))
                      .fadeIn()
                      .slideY(begin: 0.2, end: 0);
                  }),

                  const SizedBox(height: 20),

                  // 혜택 섹션
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ModernTheme.accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: ModernTheme.accentColor,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '7일 무료 체험',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: ModernTheme.textPrimary,
                                ),
                              ),
                              Text(
                                '언제든지 취소 가능 • 자동 갱신',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: ModernTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate()
                    .fadeIn(delay: 600.ms),
                ],
              ),
            ),
          ),

          // 하단 구매 버튼
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '선택한 플랜',
                            style: TextStyle(
                              fontSize: 12,
                              color: ModernTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _plans[_selectedPlanIndex].name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: ModernTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '₩${_formatPrice(_plans[_selectedPlanIndex].price)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: ModernTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: _handleSubscribe,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ModernTheme.primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      '7일 무료 체험 시작하기',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  void _handleSubscribe() {
    HapticFeedback.mediumImpact();
    
    // 구독 처리 로직
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('구독 확인'),
        content: Text(
          '${_plans[_selectedPlanIndex].name}을 구독하시겠습니까?\n7일 무료 체험 후 ₩${_formatPrice(_plans[_selectedPlanIndex].price)}가 결제됩니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processSubscription();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ModernTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _processSubscription() {
    // 실제 결제 처리 로직
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('무료 체험이 시작되었습니다! 🎉'),
        backgroundColor: ModernTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
    
    Navigator.pop(context, true);
  }
}

class SubscriptionPlan {
  final String name;
  final String duration;
  final int price;
  final int originalPrice;
  final int discount;
  final List<String> features;
  final bool isPopular;

  SubscriptionPlan({
    required this.name,
    required this.duration,
    required this.price,
    required this.originalPrice,
    required this.discount,
    required this.features,
    required this.isPopular,
  });
}