import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class MovieLogTextFormField extends StatelessWidget {
  const MovieLogTextFormField({
    super.key,
    required this.label,
    this.controller,
    this.initialValue,
    this.enabled = true,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.errorText,
    this.maxLength,
    this.showCounter = false,
  });

  final String label;
  final TextEditingController? controller;
  final String? initialValue;
  final bool enabled;
  final bool obscureText;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;
  final String? errorText;
  final int? maxLength;
  final bool showCounter;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.black,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            initialValue: initialValue,
            enabled: enabled,
            keyboardType: keyboardType,
            obscureText: obscureText,
            maxLength: maxLength,
            buildCounter: showCounter && maxLength != null
                ? (
                    context, {
                    required currentLength,
                    required isFocused,
                    required maxLength,
                  }) => Text(
                    '$currentLength / $maxLength',
                    style: const TextStyle(
                      color: AppColors.gray,
                      fontSize: 10,
                    ),
                  )
                : null,
            style: TextStyle(
              color: enabled ? AppColors.black : AppColors.gray,
              fontSize: 13,
            ),
            decoration: InputDecoration(
              errorText: errorText,
              errorMaxLines: 2,
              errorStyle: const TextStyle(
                color: AppColors.error,
                fontSize: 12,
                height: 1.3,
              ),
              isDense: true,
              filled: true,
              fillColor: enabled
                  ? AppColors.white
                  : AppColors.profileStatCardBackground,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.statCardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.statCardBorder),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.error),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppColors.error,
                  width: 1.5,
                ),
              ),
            ),
            validator: validator,
          ),
        ],
      ),
    );
  }
}
