import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:merokotha/core/constants/app_colors.dart';
import 'package:merokotha/core/constants/app_sizes.dart';

class ListingPhotoPicker extends StatelessWidget {
  final List<File> images;
  final ValueChanged<List<File>> onChanged;

  const ListingPhotoPicker({
    super.key,
    required this.images,
    required this.onChanged,
  });

  Future<void> _pick(BuildContext context) async {
    try {
      final picked = await ImagePicker().pickMultiImage(imageQuality: 75);
      if (picked.isEmpty) return;
      onChanged(picked.map((f) => File(f.path)).toList());
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to pick images')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pick(context),
      child: Container(
        width: double.infinity,
        height: 140,
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.grey50,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: AppColors.grey100),
        ),
        child: images.isEmpty
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 36,
                    color: AppColors.grey400,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add photos',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Tap to select images',
                    style: TextStyle(fontSize: 11, color: AppColors.grey400),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: images.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (_, i) => ClipRRect(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        child: Image.file(
                          images[i],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${images.length} photo${images.length == 1 ? '' : 's'} selected. Tap to change.',
                    style: const TextStyle(fontSize: 12, color: AppColors.grey400),
                  ),
                ],
              ),
      ),
    );
  }
}
