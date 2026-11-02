import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../theme/app_text_styles.dart';
import '../../../view_models/sign_up_view_model.dart';
import '../../../widgets/movielog_button.dart';
import 'auth_text_form_field.dart';

// 닉네임 입력과 중복 확인 버튼, 확인 결과를 함께 표시
class NicknameCheckField extends StatelessWidget {
  const NicknameCheckField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Consumer<SignUpViewModel>(
      builder: (context, viewModel, child) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AuthTextFormField(
                  label: '닉네임',
                  hintText: '닉네임을 입력해주세요',
                  controller: controller,
                  errorText: viewModel.nicknameErrorText,
                  onChanged: viewModel.onNicknameChanged,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  validator: (value) {
                    // 닉네임 조건 확인
                    final nickname = value?.trim() ?? '';

                    if (nickname.isEmpty) return '닉네임을 입력해 주세요.';
                    if (nickname.isNotEmpty && nickname.length < 2) {
                      return '닉네임은 2자 이상이어야 합니다.';
                    }

                    return null;
                  },
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 27),
                child: MovieLogButton(
                  label: '중복 확인',
                  isLoading:
                      viewModel.nicknameCheckStatus == CheckStatus.checking,
                  onPressed: viewModel.canCheckNickname
                      ? () => viewModel.checkNickname(controller.text)
                      : null,
                ),
              ),
            ],
          ),
          if (viewModel.nicknameCheckStatus == CheckStatus.available)
            const Text('사용할 수 있는 닉네임입니다.', style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}
