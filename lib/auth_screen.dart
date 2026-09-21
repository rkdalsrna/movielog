import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'theme/app_colors.dart';
import 'theme/app_text_styles.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nicknameController = TextEditingController();

  // Required Mission에서 사용할 입력 상태
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  // ignore: unused_field, prefer_final_fields
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '환영합니다!\n간단한 정보만 입력하고 시작해보세요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 44),
                AuthTextFormField(
                  label: '닉네임',
                  hintText: '닉네임을 입력해주세요',
                  controller: _nicknameController,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    final nickname = value?.trim() ?? '';

                    if (nickname.isNotEmpty && nickname.length < 2) {
                      return '닉네임은 2자 이상이어야 합니다.';
                    }

                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AuthTextFormField extends StatefulWidget {
  const AuthTextFormField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    required this.validator,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.onFieldSubmitted,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final FormFieldValidator<String> validator;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  State<AuthTextFormField> createState() => _AuthTextFormFieldState();
}

class _AuthTextFormFieldState extends State<AuthTextFormField> {
  static const _errorColor = Color(0xFFBA1A1A);
  static const _errorContainerColor = Color(0xFFFFDAD6);

  bool _wasEdited = false;

  String get _value => widget.controller.text.trim();

  bool get _hasError {
    return _wasEdited && widget.validator(_value) != null;
  }

  bool get _isValid {
    return _wasEdited && _value.isNotEmpty && widget.validator(_value) == null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            color: AppColors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          obscureText: widget.obscureText,
          onFieldSubmitted: widget.onFieldSubmitted,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: (_) {
            setState(() {
              _wasEdited = true;
            });
          },
          validator: widget.validator,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: const TextStyle(
              color: AppColors.gray,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: _hasError
                ? _errorContainerColor
                : AppColors.statCardBackground,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 11,
            ),
            enabledBorder: _outlineBorder(AppColors.statCardBorder),
            focusedBorder: _outlineBorder(AppColors.primary),
            errorBorder: _outlineBorder(_errorColor),
            focusedErrorBorder: _outlineBorder(_errorColor),
            errorStyle: const TextStyle(
              color: _errorColor,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 1.2,
            ),
            suffixIcon: _buildStatusIcon(),
            suffixIconConstraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget? _buildStatusIcon() {
    if (!_hasError && !_isValid) return null;

    final assetName = _isValid ? 'check_circle.svg' : 'error.svg';
    final color = _isValid ? AppColors.primary : _errorColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: SvgPicture.asset(
        'assets/icons/$assetName',
        width: 20,
        height: 20,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      ),
    );
  }

  OutlineInputBorder _outlineBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: color),
    );
  }
}
