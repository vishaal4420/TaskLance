import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class AppTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final bool showPasswordToggle;
  final TextInputType keyboardType;
  final int? maxLines;
  final IconData? prefixIcon;
  final Widget? prefixWidget;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextInputAction? textInputAction;
  final String? initialValue;
  final bool enabled;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.obscureText = false,
    this.showPasswordToggle = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.prefixIcon,
    this.prefixWidget,
    this.suffixIcon,
    this.onChanged,
    this.onFieldSubmitted,
    this.readOnly = false,
    this.onTap,
    this.textInputAction,
    this.initialValue,
    this.enabled = true,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final fillColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    Widget? resolvedPrefix;
    if (widget.prefixWidget != null) {
      resolvedPrefix = widget.prefixWidget;
    } else if (widget.prefixIcon != null) {
      resolvedPrefix = Icon(
        widget.prefixIcon,
        size: 20,
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty) ...[
          Text(
            widget.label,
            style: AppTextStyles.labelLarge.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          obscureText: widget.showPasswordToggle ? _obscureText : widget.obscureText,
          keyboardType: widget.keyboardType,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onFieldSubmitted,
          textInputAction: widget.textInputAction,
          enabled: widget.enabled,
          focusNode: widget.focusNode,
          textCapitalization: widget.textCapitalization,
          style: AppTextStyles.bodyLarge.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
            filled: true,
            fillColor: fillColor,
            prefixIcon: resolvedPrefix,
            suffixIcon: widget.showPasswordToggle
                ? IconButton(
                    icon: Icon(
                      _obscureText
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                    onPressed: () => setState(() => _obscureText = !_obscureText),
                  )
                : widget.suffixIcon,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
          ),
          validator: widget.validator,
        ),
      ],
    );
  }
}
