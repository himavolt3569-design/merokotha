import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

enum MkButtonVariant { primary, secondary, outline, ghost, danger }

class MkButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final MkButtonVariant variant;
  final bool isLoading;
  final bool fullWidth;
  final IconData? prefixIcon;
  final double? height;

  const MkButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = MkButtonVariant.primary,
    this.isLoading = false,
    this.fullWidth = true,
    this.prefixIcon,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final h = height ?? AppSizes.buttonHeight;

    Widget child = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (prefixIcon != null) ...[
                Icon(prefixIcon, size: 18),
                const SizedBox(width: 8),
              ],
              Text(label),
            ],
          );

    ButtonStyle style;
    switch (variant) {
      case MkButtonVariant.primary:
        style = ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: Size(fullWidth ? double.infinity : 0, h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        );
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: style,
          child: child,
        );

      case MkButtonVariant.secondary:
        style = ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: AppColors.primary,
          minimumSize: Size(fullWidth ? double.infinity : 0, h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        );
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: style,
          child: child,
        );

      case MkButtonVariant.outline:
        return SizedBox(
          width: fullWidth ? double.infinity : null,
          height: h,
          child: OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: child,
          ),
        );

      case MkButtonVariant.ghost:
        return SizedBox(
          width: fullWidth ? double.infinity : null,
          height: h,
          child: TextButton(
            onPressed: isLoading ? null : onPressed,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: child,
          ),
        );

      case MkButtonVariant.danger:
        style = ElevatedButton.styleFrom(
          backgroundColor: AppColors.errorLight,
          foregroundColor: AppColors.error,
          minimumSize: Size(fullWidth ? double.infinity : 0, h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        );
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: style,
          child: child,
        );
    }
  }
}
