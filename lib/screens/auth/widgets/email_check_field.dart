import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../theme/app_text_styles.dart';
import '../../../view_models/sign_up_view_model.dart';
import '../../../widgets/movielog_button.dart';
import 'auth_text_form_field.dart';

// 이메일 입력과 중복 확인 버튼, 확인 결과를 함께 표시
class EmailCheckField extends StatelessWidget {
  const EmailCheckField({
    super.key,
    required this.controller,
    required this.validator,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final FormFieldValidator<String> validator;
  final ValueChanged<String>? onFieldSubmitted;

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
                  label: '이메일',
                  hintText: '이메일 주소를 입력해주세요',
                  controller: controller,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: onFieldSubmitted,
                  validator: validator,
                  errorText: viewModel.emailErrorText,
                  onChanged: viewModel.onEmailChanged,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 27),
                child: MovieLogButton(
                  label: '중복 확인',
                  isLoading: viewModel.emailCheckStatus == CheckStatus.checking,
                  onPressed: viewModel.canCheckEmail
                      ? () => viewModel.checkEmail(controller.text)
                      : null,
                ),
              ),
            ],
          ),
          if (viewModel.emailCheckStatus == CheckStatus.available)
            const Text('사용할 수 있는 이메일입니다.', style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}
