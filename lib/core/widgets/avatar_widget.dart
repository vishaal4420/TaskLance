import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class AvatarWidget extends StatelessWidget {
  final String? url;
  final String name;
  final double size;
  final bool showBorder;
  final VoidCallback? onTap;

  const AvatarWidget({
    super.key,
    this.url,
    required this.name,
    this.size = 40,
    this.showBorder = false,
    this.onTap,
  });

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  Color get _bgColor {
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      const Color(0xFF9B59B6),
      const Color(0xFFE67E22),
      const Color(0xFF16A085),
      const Color(0xFF2980B9),
    ];
    final hash = name.codeUnits.fold(0, (sum, c) => sum + c);
    return colors[hash % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    Widget avatar;
    if (url != null && url!.isNotEmpty) {
      avatar = CircleAvatar(
        radius: size / 2,
        backgroundImage: NetworkImage(url!),
        backgroundColor: _bgColor,
      );
    } else {
      avatar = CircleAvatar(
        radius: size / 2,
        backgroundColor: _bgColor,
        child: Text(
          _initials,
          style: AppTextStyles.labelMedium.copyWith(
            color: Colors.white,
            fontSize: size * 0.35,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    Widget result = avatar;
    if (showBorder) {
      result = Container(
        width: size + 4,
        height: size + 4,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary, width: 2),
        ),
        child: avatar,
      );
    }

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: result);
    }
    return result;
  }
}
