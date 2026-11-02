import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../theme/app_text_styles.dart';
import '../../../view_models/sign_up_view_model.dart';
import '../../../widgets/movielog_button.dart';
import 'auth_text_form_field.dart';

// 이메일 입력과 중복 확인 버튼, 확인 결과를 함께 표시
class EmailCheckField extends StatefulWidget {
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
  State<EmailCheckField> createState() => _EmailCheckFieldState();
}

class _EmailCheckFieldState extends State<EmailCheckField> {
  String? _formatError;

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
                  controller: widget.controller,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: widget.onFieldSubmitted,
                  validator: widget.validator,
                  errorText: _formatError ?? viewModel.emailErrorText,
                  onChanged: (value) {
                    setState(() => _formatError = null);
                    viewModel.onEmailChanged(value);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 27),
                child: MovieLogButton(
                  label: '중복 확인',
                  width: 102,
                  isLoading: viewModel.emailCheckStatus == CheckStatus.checking,
                  onPressed: viewModel.canCheckEmail
                      ? () {
                          final email = widget.controller.text.trim();
                          final error = email.isEmpty
                              ? '이메일을 입력해 주세요.'
                              : widget.validator(email);
                          setState(() => _formatError = error);
                          // 형식 검사를 통과한 경우에만 서버 중복 확인 요청
                          if (error != null) return;
                          viewModel.checkEmail(email);
                        }
                      : null,
                ),
              ),
            ],
          ),
          if (_formatError == null &&
              widget.controller.text.trim().isNotEmpty &&
              widget.validator(widget.controller.text.trim()) == null &&
              viewModel.emailCheckStatus == CheckStatus.available)
            const Text('사용할 수 있는 이메일입니다.', style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}
