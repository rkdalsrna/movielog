import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../theme/app_colors.dart';

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
    this.onChanged,
    this.errorText,
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
  final ValueChanged<String>? onChanged;
  final String? errorText;

  @override
  State<AuthTextFormField> createState() => _AuthTextFormFieldState();
}

class _AuthTextFormFieldState extends State<AuthTextFormField> {
  late FocusNode _focusNode;
  late bool _ownsFocusNode;
  String? _validationError;
  bool _isValid = false;

  bool get _hasError => widget.errorText != null || _validationError != null;

  @override
  void initState() {
    super.initState();
    _setUpFocusNode();
  }

  @override
  void didUpdateWidget(covariant AuthTextFormField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.focusNode != widget.focusNode) {
      _removeFocusNode();
      _setUpFocusNode();
    }
  }

  @override
  void dispose() {
    _removeFocusNode();
    super.dispose();
  }

  void _setUpFocusNode() {
    // 전달받은 포커스가 없으면 직접 생성
    _ownsFocusNode = widget.focusNode == null;
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  void _removeFocusNode() {
    // 직접 만든 포커스만 정리
    _focusNode.removeListener(_handleFocusChange);
    if (_ownsFocusNode) _focusNode.dispose();
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      // 입력 중에는 검사 결과 숨기기
      setState(() {
        _validationError = null;
        _isValid = false;
      });
      return;
    }

    final value = widget.controller.text;
    // 커서가 빠지면 입력값 검사
    final error = widget.validator(value);

    setState(() {
      _validationError = error;
      _isValid = value.trim().isNotEmpty && error == null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 70),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: const TextStyle(
              color: AppColors.black,
              fontFamily: 'Manrope',
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            obscureText: widget.obscureText,
            onFieldSubmitted: widget.onFieldSubmitted,
            onChanged: widget.onChanged,
            autovalidateMode: AutovalidateMode.disabled,
            forceErrorText: widget.errorText ?? _validationError,
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
                  ? AppColors.errorContainer
                  : AppColors.statCardBackground,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 11,
              ),
              enabledBorder: _outlineBorder(AppColors.statCardBorder),
              focusedBorder: _outlineBorder(AppColors.primary),
              errorBorder: _outlineBorder(AppColors.error),
              focusedErrorBorder: _outlineBorder(AppColors.error),
              errorStyle: const TextStyle(
                color: AppColors.error,
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
      ),
    );
  }

  Widget? _buildStatusIcon() {
    if (!_hasError && !_isValid) return null;

    final assetName = _hasError ? 'error.svg' : 'check_circle.svg';
    final color = _hasError ? AppColors.error : AppColors.primary;

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
