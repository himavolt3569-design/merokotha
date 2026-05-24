import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:merokotha/core/constants/app_colors.dart';
import 'package:merokotha/core/constants/app_sizes.dart';

class UserAvatar extends StatelessWidget {
  final String? photoUrl;
  final String name;
  final double size;
  final Color? backgroundColor;

  const UserAvatar({
    super.key,
    this.photoUrl,
    required this.name,
    this.size = AppSizes.avatarMd,
    this.backgroundColor,
  });

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: backgroundColor ?? AppColors.primaryLight,
      child: photoUrl != null && photoUrl!.isNotEmpty
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: photoUrl!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                placeholder: (_, _) => _initialsWidget,
                errorWidget: (_, _, _) => _initialsWidget,
              ),
            )
          : _initialsWidget,
    );
  }

  Widget get _initialsWidget => Text(
    _initials,
    style: TextStyle(
      fontSize: size * 0.35,
      fontWeight: FontWeight.w600,
      color: AppColors.primary,
    ),
  );
}
