import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/theme/app_text_styles.dart';
import 'package:provider/provider.dart';

import '../../view_models/auth_view_model.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final member = auth.member;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('내 프로필', style: AppTextStyles.appBarTitle),
        actions: [
          TextButton(
            onPressed: auth.storageCleanupInProgress ? null : auth.logout,
            child: const Text(
              '로그아웃',
              style: TextStyle(
                color: AppColors.primary,
                fontFamily: 'Manrope',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                height: 1.25,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          _ProfileSection(
            nickname: member?.nickname,
            email: member?.email,
            onEdit: member == null
                ? null
                : () => context.push('/my/profile/edit'),
          ),
          const _StatsSection(),
          ListTile(
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: AppColors.statCardBorder),
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text('내가 등록한 평점'),
            trailing: const Icon(
              Icons.chevron_right,
              color: AppColors.primary,
            ),
            onTap: () => context.push('/my/ratings'),
          ),
          const SizedBox(height: 8),
          ListTile(
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: AppColors.statCardBorder),
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text('내 즐겨찾기'),
            trailing: const Icon(
              Icons.chevron_right,
              color: AppColors.primary,
            ),
            onTap: () => context.push('/my/favorites'),
          ),
          const SizedBox(height: 28),
          const _GenreSection(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({
    required this.nickname,
    required this.email,
    required this.onEdit,
  });

  final String? nickname;
  final String? email;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
            // 프로필 이미지를 원형으로 표시
            child: ClipOval(
              child: Image.asset(
                'assets/images/profile/profile_movielog.jpg',
                fit: BoxFit.cover,
                alignment: const Alignment(0, -0.8),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            nickname ?? '내 정보를 불러오는 중이에요',
            style: AppTextStyles.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            email ?? '',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 16),
          // 프로필 수정 버튼 모양 설정
          TextButton(
            onPressed: onEdit,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              minimumSize: const Size(127, 42),
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
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        // 통계 카드 3개를 같은 너비로 배치
        child: const Row(
          children: [
            Expanded(
              child: _StatCard(label: '본 영화', value: '342'),
            ),
            SizedBox(width: 8),
            // 평점 카드만 다른 테두리 색상 적용
            Expanded(
              child: _StatCard(
                label: '평점',
                value: '4.2',
                borderColor: AppColors.lavender,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _StatCard(label: '즐겨찾기', value: '58'),
            ),
          ],
        ),
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
      // 통계 카드 공통 배경과 테두리
      decoration: BoxDecoration(
        color: AppColors.profileStatCardBackground,
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
    return SizedBox(
      width: double.infinity,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('선호하는 장르', style: AppTextStyles.titleMedium),
          SizedBox(height: 16),
          // 칩이 넘치면 다음 줄로 배치
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
