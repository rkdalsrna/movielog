import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/models/create_member_request.dart';
import '../../data/services/sign_up_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../view_models/learning_member_session.dart';
import '../../view_models/sign_up_view_model.dart';
import 'widgets/auth_text_form_field.dart';
import 'widgets/email_check_field.dart';
import 'widgets/nickname_check_field.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // 입력창 전체 검사
  final _formKey = GlobalKey<FormState>();

  // 입력값 관리
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // 비밀번호 입력칸 포커스 관리
  final _passwordFocusNode = FocusNode();
  bool _agreedToTerms = false;

  // 모든 가입 조건 확인
  bool get _canSubmit {
    return _nicknameController.text.trim().length >= 2 &&
        _nicknameController.text.trim().length <= 12 &&
        _isValidEmail(_emailController.text.trim()) &&
        _validatePasswordFormat(_passwordController.text) == null &&
        _agreedToTerms;
  }

  @override
  void initState() {
    super.initState();
    // 입력값 변경 감지
    _nicknameController.addListener(_refreshFormState);
    _emailController.addListener(_refreshFormState);
    _passwordController.addListener(_refreshFormState);
  }

  @override
  void dispose() {
    // 입력창 관련 자원 정리
    _nicknameController
      ..removeListener(_refreshFormState)
      ..dispose();
    _emailController
      ..removeListener(_refreshFormState)
      ..dispose();
    _passwordController
      ..removeListener(_refreshFormState)
      ..dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _refreshFormState() {
    // 가입 버튼 상태 새로 그리기
    setState(() {});
  }

  bool _isValidEmail(String email) {
    // 이메일 형식 확인
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
  }

  String? _validatePasswordFormat(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return '비밀번호를 입력해 주세요.';
    if (password.length < 8) return '비밀번호는 8자 이상이어야 합니다.';
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return '비밀번호에 소문자를 포함해 주세요.';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return '비밀번호에 대문자를 포함해 주세요.';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return '비밀번호에 숫자를 포함해 주세요.';
    }
    if (!RegExp(r'[!@#$%^&*]').hasMatch(password)) {
      return '비밀번호에 특수문자 !@#\$%^&* 중 하나를 포함해 주세요.';
    }
    return null;
  }

  Future<void> _submit(BuildContext context) async {
    // 제출 전 전체 입력값 검사
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid || !_agreedToTerms) return;

    FocusScope.of(context).unfocus();

    final viewModel = context.read<SignUpViewModel>();
    await viewModel.submit(
      CreateMemberRequest(
        email: _emailController.text,
        password: _passwordController.text,
        nickname: _nicknameController.text,
      ),
    );

    if (!context.mounted) return;

    if (viewModel.submitStatus == SubmitStatus.success &&
        viewModel.createdMemberId != null) {
      context.read<LearningMemberSession>().setMemberId(
        viewModel.createdMemberId!,
      );
      context.go('/movies');
      return;
    }

    final message = viewModel.snackbarMessage;
    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SignUpViewModel>(
      create: (_) => SignUpViewModel(
        SignUpService(
          Dio(
            BaseOptions(
              baseUrl: dotenv.env['MEMBER_API_BASE_URL'] ?? '',
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ),
          ),
        ),
      ),
      child: Consumer<SignUpViewModel>(
        builder: (context, viewModel, child) {
          return PopScope(
            canPop: viewModel.submitStatus != SubmitStatus.submitting,
            child: Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  onPressed: () => Navigator.maybePop(context),
                  tooltip: '뒤로가기',
                  icon: SvgPicture.asset(
                    'assets/icons/arrow_back.svg',
                    width: 24,
                    height: 24,
                  ),
                ),
                title: const Text(
                  '회원가입',
                  style: AppTextStyles.appBarTitle,
                ),
              ),
              body: SafeArea(
                top: false,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // 키보드가 열려도 화면 스크롤
                    return SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight - 44,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildInputSection(context),
                              const SizedBox(height: 178),
                              _buildActionSection(context),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 356,
            height: 64,
            alignment: Alignment.center,
            child: const Text(
              '환영합니다!\n간단한 정보만 입력하고 시작해보세요.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.black,
                fontFamily: 'Manrope',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 356, minHeight: 242),
            child: Column(
              children: [
                NicknameCheckField(controller: _nicknameController),
                const SizedBox(height: 16),
                EmailCheckField(
                  controller: _emailController,
                  onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
                  validator: (value) {
                    // 이메일 조건 확인
                    final email = value?.trim() ?? '';

                    if (email.isEmpty) return '이메일을 입력해 주세요.';
                    if (!_isValidEmail(email)) {
                      return '올바른 이메일 형식이 아닙니다.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Consumer<SignUpViewModel>(
                  builder: (context, viewModel, child) {
                    return AuthTextFormField(
                      label: '비밀번호',
                      hintText: '비밀번호를 입력해주세요',
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      textInputAction: TextInputAction.done,
                      obscureText: true,
                      errorText: viewModel.passwordErrorText,
                      onChanged: (_) => viewModel.onPasswordChanged(),
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).unfocus(),
                      validator: _validatePasswordFormat,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionSection(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 356),
        child: SizedBox(
          height: 216,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              SizedBox(
                height: 24,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _agreedToTerms = !_agreedToTerms;
                    });
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _agreedToTerms,
                          onChanged: (value) {
                            // 약관 동의 상태 변경
                            setState(() {
                              _agreedToTerms = value ?? false;
                            });
                          },
                          activeColor: AppColors.primary,
                          checkColor: AppColors.white,
                          side: const BorderSide(
                            color: AppColors.statCardBorder,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          '필수 약관에 동의합니다',
                          style: TextStyle(
                            color: AppColors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Consumer<SignUpViewModel>(
                builder: (context, viewModel, child) {
                  final isSubmitting =
                      viewModel.submitStatus == SubmitStatus.submitting;
                  final checksPassed =
                      viewModel.nicknameCheckStatus == CheckStatus.available &&
                      viewModel.emailCheckStatus == CheckStatus.available;
                  final canSubmit =
                      _canSubmit && checksPassed && !isSubmitting;

                  return ElevatedButton(
                    onPressed: canSubmit ? () => _submit(context) : null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      elevation: 0,
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      disabledBackgroundColor: AppColors.disabledButton,
                      disabledForegroundColor: AppColors.disabledButtonText,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : const Text(
                            '가입하기',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  );
                },
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '이미 계정이 있나요?',
                    style: TextStyle(
                      color: AppColors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.only(left: 4),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      '로그인',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
