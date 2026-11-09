import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class DeleteRatingDialog extends StatefulWidget {
  const DeleteRatingDialog({
    super.key,
    this.title = '평점을 삭제할까요?',
    this.onConfirm,
  });

  final String title;
  final Future<void> Function()? onConfirm;

  @override
  State<DeleteRatingDialog> createState() => _DeleteRatingDialogState();
}

class _DeleteRatingDialogState extends State<DeleteRatingDialog> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isDeleting,
      child: Dialog(
        backgroundColor: AppColors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: SizedBox(
          width: 328,
          height: 240,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 30, 16, 28),
            child: Column(
              children: [
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.black,
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 19),
                const Text(
                  '삭제한 평점은 복구할 수 없습니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.gray, fontSize: 14),
                ),
                const SizedBox(height: 56),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: FilledButton(
                          onPressed: _isDeleting
                              ? null
                              : () => Navigator.pop(context, false),
                          style: FilledButton.styleFrom(
                            backgroundColor:
                                AppColors.profileStatCardBackground,
                            foregroundColor: AppColors.primary,
                            disabledBackgroundColor: AppColors.disabledButton,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('취소'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: FilledButton(
                          onPressed: _isDeleting ? null : _onConfirm,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            disabledBackgroundColor: AppColors.disabledButton,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isDeleting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.white,
                                  ),
                                )
                              : const Text('삭제'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onConfirm() async {
    final action = widget.onConfirm;
    if (action == null) {
      Navigator.pop(context, true);
      return;
    }

    setState(() => _isDeleting = true);
    try {
      await action();
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      final message = error is StateError
          ? error.message.toString()
          : '삭제하지 못했습니다. 잠시 후 다시 시도해 주세요.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}
