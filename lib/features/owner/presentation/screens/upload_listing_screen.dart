import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:merokotha/core/constants/app_colors.dart';
import 'package:merokotha/core/constants/app_sizes.dart';
import 'package:merokotha/core/constants/app_strings.dart';
import 'package:merokotha/core/router/app_routes.dart';
import 'package:merokotha/core/utils/validators.dart';
import 'package:merokotha/features/auth/providers/auth_provider.dart';
import 'package:merokotha/features/owner/data/owner_repository.dart';
import 'package:merokotha/features/owner/presentation/widgets/owner_widgets.dart';
import 'package:merokotha/features/owner/providers/owner_providers.dart';
import 'package:merokotha/shared/models/listing_model.dart';
import 'package:merokotha/shared/widgets/mk_app_bar.dart';
import 'package:merokotha/shared/widgets/mk_button.dart';
import 'package:merokotha/shared/widgets/mk_text_field.dart';

const _roomTypes = [
  ('room', 'Room'),
  ('flat', 'Flat'),
  ('apartment', 'Apartment'),
  ('house', 'House'),
  ('office', 'Office'),
  ('shop', 'Shop'),
  ('land', 'Land'),
  ('other', 'Other'),
];

class UploadListingScreen extends ConsumerStatefulWidget {
  const UploadListingScreen({super.key});

  @override
  ConsumerState<UploadListingScreen> createState() =>
      _UploadListingScreenState();
}

class _UploadListingScreenState extends ConsumerState<UploadListingScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleCtrl = TextEditingController();
  final _rentCtrl = TextEditingController();
  final _depositCtrl = TextEditingController();
  final _floorCtrl = TextEditingController();
  final _totalFloorsCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _landmarksCtrl = TextEditingController();

  String _roomType = 'room';
  FurnishingType _furnishing = FurnishingType.unfurnished;
  List<String> _facilities = [];
  DateTime _availableFrom = DateTime.now();
  LatLng? _pickedLocation;
  final List<File> _pickedImages = [];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _rentCtrl.dispose();
    _depositCtrl.dispose();
    _floorCtrl.dispose();
    _totalFloorsCtrl.dispose();
    _descCtrl.dispose();
    _addressCtrl.dispose();
    _landmarksCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _availableFrom,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _availableFrom = picked);
  }

  Future<void> _openMapPicker() async {
    LatLng initial = const LatLng(27.7172, 85.3240);
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.whileInUse ||
          perm == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
        );
        initial = LatLng(pos.latitude, pos.longitude);
      }
    } catch (_) {}

    if (!mounted) return;
    final result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (_) => MapPickerScreen(initialLocation: initial),
      ),
    );
    if (result != null) setState(() => _pickedLocation = result);
  }

  Future<List<String>> _uploadImages(String listingId) async {
    final storage = FirebaseStorage.instance;
    final urls = <String>[];
    for (var i = 0; i < _pickedImages.length; i++) {
      final ref = storage.ref().child('listings/$listingId/image_$i.jpg');
      final task = await ref.putFile(
        _pickedImages[i],
        SettableMetadata(contentType: 'image/jpeg'),
      );
      urls.add(await task.ref.getDownloadURL());
    }
    return urls;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_pickedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please pin your room location on the map'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    FocusScope.of(context).unfocus();

    final user = await ref.read(currentUserProvider.future);
    if (user == null) return;

    final id = await ref
        .read(uploadListingProvider.notifier)
        .uploadListing(
          ownerId: user.id,
          ownerName: user.name,
          ownerPhotoUrl: user.photoUrl,
          title: _titleCtrl.text.trim(),
          roomType: _roomType,
          rentPerMonth: double.parse(_rentCtrl.text.trim()),
          depositAmount: double.tryParse(_depositCtrl.text.trim()) ?? 0,
          floor: int.tryParse(_floorCtrl.text.trim()) ?? 0,
          totalFloors: int.tryParse(_totalFloorsCtrl.text.trim()) ?? 1,
          furnishing: _furnishing,
          facilities: _facilities,
          description: _descCtrl.text.trim(),
          availableFrom: _availableFrom,
          geoPoint: GeoPoint(
            _pickedLocation!.latitude,
            _pickedLocation!.longitude,
          ),
          address: _addressCtrl.text.trim(),
          nearbyLandmarks: _landmarksCtrl.text.trim(),
        );

    if (!mounted) return;
    if (id != null) {
      if (_pickedImages.isNotEmpty) {
        try {
          final photoUrls = await _uploadImages(id);
          await ref.read(ownerRepositoryProvider).updateListing(id, {
            'photoUrls': photoUrls,
          });
        } catch (_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Listing saved, but photo upload failed.'),
              backgroundColor: AppColors.error,
            ),
          );
          context.go(AppRoutes.myListings);
          return;
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Listing published!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.go(AppRoutes.myListings);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(uploadListingProvider);

    ref.listen(uploadListingProvider, (_, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: MkAppBar(
        title: 'Add listing',
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: AppColors.grey800,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListingPhotoPicker(
                images: _pickedImages,
                onChanged: (imgs) => setState(() {
                  _pickedImages
                    ..clear()
                    ..addAll(imgs);
                }),
              ),
              const SizedBox(height: 20),

              UploadFormCard(
                title: 'Basic information',
                children: [
                  MkTextField(
                    label: AppStrings.listingTitle,
                    hint: AppStrings.listingTitleHint,
                    controller: _titleCtrl,
                    validator: Validators.required,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: AppSizes.md),

                  const UploadFormLabel('Room type'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _roomType,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        borderSide: const BorderSide(color: AppColors.grey100),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        borderSide: const BorderSide(color: AppColors.grey100),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                    items: _roomTypes
                        .map(
                          (t) => DropdownMenuItem(
                            value: t.$1,
                            child: Text(
                              t.$2,
                              style: const TextStyle(
                                fontSize: 15,
                                color: AppColors.grey900,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _roomType = v ?? 'room'),
                  ),

                  const SizedBox(height: AppSizes.md),
                  const UploadFormLabel('Furnishing'),
                  const SizedBox(height: 8),
                  SegmentSelector<FurnishingType>(
                    values: FurnishingType.values,
                    selected: _furnishing,
                    label: (t) {
                      switch (t) {
                        case FurnishingType.furnished:
                          return 'Furnished';
                        case FurnishingType.semiFurnished:
                          return 'Semi';
                        case FurnishingType.unfurnished:
                          return 'Unfurnished';
                      }
                    },
                    onChanged: (v) => setState(() => _furnishing = v),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              UploadFormCard(
                title: 'Pricing',
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: MkPriceField(
                          label: 'Rent / month',
                          hint: '8000',
                          controller: _rentCtrl,
                          validator: Validators.price,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: MkPriceField(
                          label: 'Deposit',
                          hint: '0',
                          controller: _depositCtrl,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              UploadFormCard(
                title: 'Building details',
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: MkTextField(
                          label: 'Floor no.',
                          hint: '2',
                          controller: _floorCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: MkTextField(
                          label: 'Total floors',
                          hint: '4',
                          controller: _totalFloorsCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.md),
                  const UploadFormLabel('Available from'),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        border: Border.all(color: AppColors.grey100),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 18,
                            color: AppColors.grey400,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${_availableFrom.day}/${_availableFrom.month}/${_availableFrom.year}',
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppColors.grey900,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                            color: AppColors.grey400,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              UploadFormCard(
                title: 'Facilities',
                children: [
                  FacilitiesSelector(
                    selected: _facilities,
                    onChanged: (v) => setState(() => _facilities = v),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              UploadFormCard(
                title: 'Description',
                children: [
                  MkTextField(
                    label: 'About this room',
                    hint:
                        'Describe the room, neighbourhood, transport access...',
                    controller: _descCtrl,
                    validator: Validators.description,
                    maxLines: 4,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              UploadFormCard(
                title: 'Location',
                children: [
                  MkTextField(
                    label: 'Address / area',
                    hint: 'e.g. Baneshwor, Kathmandu',
                    controller: _addressCtrl,
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: AppSizes.md),
                  MkTextField(
                    label: 'Nearby landmarks (optional)',
                    hint: 'e.g. Near Tribhuvan University gate',
                    controller: _landmarksCtrl,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: AppSizes.md),
                  GestureDetector(
                    onTap: _openMapPicker,
                    child: Container(
                      padding: const EdgeInsets.all(AppSizes.md),
                      decoration: BoxDecoration(
                        color: _pickedLocation != null
                            ? AppColors.primaryLight
                            : AppColors.grey50,
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        border: Border.all(
                          color: _pickedLocation != null
                              ? AppColors.primary
                              : AppColors.grey100,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _pickedLocation != null
                                ? Icons.location_on_rounded
                                : Icons.add_location_alt_outlined,
                            color: _pickedLocation != null
                                ? AppColors.primary
                                : AppColors.grey400,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _pickedLocation != null
                                  ? 'Pinned: ${_pickedLocation!.latitude.toStringAsFixed(4)}, ${_pickedLocation!.longitude.toStringAsFixed(4)}'
                                  : AppStrings.pinLocation,
                              style: TextStyle(
                                fontSize: 14,
                                color: _pickedLocation != null
                                    ? AppColors.primary
                                    : AppColors.grey600,
                                fontWeight: _pickedLocation != null
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                            color: _pickedLocation != null
                                ? AppColors.primary
                                : AppColors.grey400,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              MkButton(
                label: AppStrings.publishListing,
                onPressed: _submit,
                isLoading: uploadState.isLoading,
                prefixIcon: Icons.publish_rounded,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
