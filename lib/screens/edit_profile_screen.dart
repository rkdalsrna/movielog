import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../view_models/auth_view_model.dart';
import '../view_models/edit_profile_view_model.dart';
import '../widgets/movielog_button.dart';
import '../widgets/movielog_text_form_field.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final member = context.read<AuthViewModel>().member;
    _controller = TextEditingController(text: member?.nickname ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final viewModel = context.read<EditProfileViewModel>();
    final messenger = ScaffoldMessenger.of(context);

    final success = await viewModel.save(_controller.text);
    if (!mounted) return;

    if (success) {
      messenger.showSnackBar(
        const SnackBar(content: Text('프로필을 수정했어요.')),
      );
      // 회원 정보 변경으로 Router가 갱신된 다음 현재 수정 화면을 닫습니다.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && context.canPop()) context.pop();
      });
    } else if (viewModel.message != null) {
      messenger.showSnackBar(SnackBar(content: Text(viewModel.message!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = context.select<AuthViewModel, String?>(
      (auth) => auth.member?.email,
    );

    return Consumer<EditProfileViewModel>(
      builder: (context, viewModel, child) {
        final saving = viewModel.status == EditProfileStatus.saving;
        return PopScope(
          canPop: !saving,
          child: Scaffold(
            backgroundColor: AppColors.warmWhite,
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: AppColors.warmWhite,
              title: const Text(
                '프로필 수정',
                style: AppTextStyles.appBarTitle,
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 52),
              child: Column(
                children: [
                  MovieLogTextFormField(
                    label: '이메일 (변경할 수 없습니다)',
                    initialValue: email,
                    enabled: false,
                  ),
                  const SizedBox(height: 26),
                  MovieLogTextFormField(
                    label: '닉네임',
                    controller: _controller,
                    enabled: !saving,
                    maxLength: 12,
                    showCounter: true,
                    errorText: viewModel.nicknameError,
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: MovieLogButton(
                      label: '저장',
                      isLoading: saving,
                      onPressed: saving ? null : _submit,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
