import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../view_models/auth_view_model.dart';
import '../widgets/movielog_button.dart';
import '../widgets/movielog_text_form_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  late final AuthViewModel _auth;

  @override
  void initState() {
    super.initState();
    _auth = context.read<AuthViewModel>();
    _auth.addListener(_showSessionExpired);
    WidgetsBinding.instance.addPostFrameCallback((_) => _showSessionExpired());
  }

  void _showSessionExpired() {
    if (!mounted || !_auth.sessionExpired) return;
    _auth.consumeSessionExpired();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('로그인이 만료됐어요. 다시 로그인해 주세요.')),
      );
  }

  @override
  void dispose() {
    _auth.removeListener(_showSessionExpired);
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final loading = auth.status == AuthStatus.authenticating;
    final enabled = !loading && !auth.storageCleanupInProgress;

    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.warmWhite,
        title: const Text('로그인', style: AppTextStyles.appBarTitle),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 56),
              SvgPicture.asset(
                'assets/logos/movielog_logo.svg',
                width: 64,
                height: 64,
              ),
              const SizedBox(height: 20),
              const Text(
                'MovieLog에 로그인',
                style: TextStyle(
                  color: AppColors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 28),
              MovieLogTextFormField(
                label: '이메일',
                controller: _email,
                enabled: enabled,
                keyboardType: TextInputType.emailAddress,
                validator: (value) => (value?.trim().isEmpty ?? true)
                    ? '이메일을 입력해 주세요.'
                    : null,
              ),
              const SizedBox(height: 18),
              MovieLogTextFormField(
                label: '비밀번호',
                controller: _password,
                enabled: enabled,
                obscureText: true,
                errorText: auth.message,
                validator: (value) => (value?.isEmpty ?? true)
                    ? '비밀번호를 입력해 주세요.'
                    : null,
              ),
              const SizedBox(height: 84),
              MovieLogButton(
                label: '로그인',
                width: double.infinity,
                isLoading: loading,
                onPressed: enabled
                    ? () {
                        if (_formKey.currentState!.validate()) {
                          _auth.login(_email.text.trim(), _password.text);
                        }
                      }
                    : null,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '계정이 없나요?',
                    style: TextStyle(color: AppColors.gray, fontSize: 12),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      minimumSize: const Size(0, 36),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: enabled
                        ? () => context.push('/register')
                        : null,
                    child: const Text(
                      '회원가입',
                      style: TextStyle(fontSize: 12),
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
