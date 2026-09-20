import 'package:flutter/material.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/theme/app_text_styles.dart';

class Week1Screen01 extends StatelessWidget {
  const Week1Screen01({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text(
          '내 프로필',
          style: AppTextStyles.appBarTitle,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 24,
        ),
        children: [ //의미 있는 위젯 분리
          const _ProfileSection(),
          const _StatsSection(),
          const _GenreSection(),
        ],
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        children: [
          Container(
            width: 128,
            height: 128,
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: AppColors.profileImageBorder,
              shape: BoxShape.circle,
            ),
            //프로필 이미지를 원형으로 표시
            child: ClipOval(
              child: Image.asset(
                'assets/images/profile/profile_movielog.jpg',
                fit: BoxFit.cover,
                alignment: const Alignment(0, -0.8),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('무비러버', style: AppTextStyles.titleLarge),
          const SizedBox(height: 8),
          const Text(
            '매주 주말엔 영화관으로 출근하는 프로 관람객. 좋은 영화를 보고 기록하는 것을 좋아합니다.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 16),
          //프로필 수정 버튼 모양 설정
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              minimumSize: const Size(127, 50),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              '프로필 수정',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}


class _StatsSection extends StatelessWidget {
  const _StatsSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 32), //위 아래 32 여백
      //통계 카드 3개를 같은 너비로 배치
      child: const Row(
        children: [
          Expanded(child: _StatCard(label: '본 영화', value: '342')),
          SizedBox(width: 8),
          //평점 카드만 다른 테두리 색상 적용
          Expanded(
            child: _StatCard(
              label: '평점',
              value: '4.2',
              borderColor: AppColors.lavender,
            ),
          ),
          SizedBox(width: 8),
          Expanded(child: _StatCard(label: '즐겨찾기', value: '58')),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    this.borderColor = AppColors.statCardBorder,
  });

  final String label;
  final String value;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      //통계 카드 공통 배경과 테두리
      decoration: BoxDecoration(
        color: AppColors.statCardBackground,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _GenreSection extends StatelessWidget {
  const _GenreSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('선호하는 장르', style: AppTextStyles.titleMedium),
          SizedBox(height: 16),
          //칩이 넘치면 다음 줄로 배치
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _GenreChip(label: '드라마'),
              _GenreChip(label: 'SF'),
              _GenreChip(label: '애니메이션'),
            ],
          ),
        ],
      ),
    );
  }
}

class _GenreChip extends StatelessWidget {
  const _GenreChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: AppColors.lavender,
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
