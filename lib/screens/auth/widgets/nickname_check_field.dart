import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../view_models/sign_up_view_model.dart';
import '../../../widgets/movielog_button.dart';
import 'auth_text_form_field.dart';

// 닉네임 입력과 중복 확인 버튼, 확인 결과를 함께 표시
class NicknameCheckField extends StatefulWidget {
  const NicknameCheckField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  State<NicknameCheckField> createState() => _NicknameCheckFieldState();
}

class _NicknameCheckFieldState extends State<NicknameCheckField> {
  String? _formatError;

  // 입력란과 중복 확인 버튼에서 같은 조건을 사용
  String? _validateNickname(String? value) {
    final nickname = value?.trim() ?? '';
    if (nickname.isEmpty) return '닉네임을 입력해 주세요.';
    if (nickname.length < 2) return '닉네임은 2자 이상이어야 합니다.';
    if (nickname.length > 12) return '닉네임은 12자 이하여야 합니다.';
    return null;
  }

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
                  controller: widget.controller,
                  errorText: _formatError ?? viewModel.nicknameErrorText,
                  onChanged: (value) {
                    setState(() => _formatError = null);
                    viewModel.onNicknameChanged(value);
                  },
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  validator: _validateNickname,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 27),
                child: MovieLogButton(
                  label: '중복 확인',
                  width: 102,
                  isLoading:
                      viewModel.nicknameCheckStatus == CheckStatus.checking,
                  onPressed: viewModel.canCheckNickname
                      ? () {
                          final nickname = widget.controller.text.trim();
                          final error = _validateNickname(nickname);
                          setState(() => _formatError = error);
                          // 형식 검사를 통과한 경우에만 서버 중복 확인 요청
                          if (error != null) return;
                          viewModel.checkNickname(nickname);
                        }
                      : null,
                ),
              ),
            ],
          ),
          if (_formatError == null &&
              _validateNickname(widget.controller.text) == null &&
              viewModel.nicknameCheckStatus == CheckStatus.checking)
            Text(
              '닉네임 사용 가능 여부를 확인 중입니다.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.checking,
                fontWeight: FontWeight.w600,
              ),
            )
          else if (_formatError == null &&
              _validateNickname(widget.controller.text) == null &&
              viewModel.nicknameCheckStatus == CheckStatus.available)
            Text(
              '사용 가능한 닉네임입니다.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}
