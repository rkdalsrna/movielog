import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import '../../data/services/member_check_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
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
        _isValidEmail(_emailController.text.trim()) &&
        _passwordController.text.length >= 8 &&
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

  void _submit() {
    // 제출 전 전체 입력값 검사
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid || !_agreedToTerms) return;

    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SignUpViewModel>(
      create: (_) => SignUpViewModel(
        MemberCheckService(
          Dio(
            BaseOptions(
              baseUrl: dotenv.env['MEMBER_API_BASE_URL'] ?? '',
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ),
          ),
        ),
      ),
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
          title: const Text('회원가입', style: AppTextStyles.appBarTitle),
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
                        _buildActionSection(),
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

                    if (email.isNotEmpty && !_isValidEmail(email)) {
                      return '올바른 이메일 형식이 아닙니다.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AuthTextFormField(
                  label: '비밀번호',
                  hintText: '비밀번호를 입력해주세요',
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  textInputAction: TextInputAction.done,
                  obscureText: true,
                  onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                  validator: (value) {
                    // 비밀번호 조건 확인
                    final password = value ?? '';

                    if (password.isNotEmpty && password.length < 8) {
                      return '비밀번호는 8자 이상이어야 합니다.';
                    }

                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionSection() {
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
              ElevatedButton(
                onPressed: _canSubmit ? _submit : null,
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
                child: const Text(
                  '가입하기',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
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
