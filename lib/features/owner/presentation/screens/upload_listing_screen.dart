import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/models/listing_model.dart';
import '../../../../shared/widgets/mk_app_bar.dart';
import '../../../../shared/widgets/mk_button.dart';
import '../../../../shared/widgets/mk_text_field.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/owner_providers.dart';
import '../widgets/owner_widgets.dart';

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

  RoomType _roomType = RoomType.single;
  FurnishingType _furnishing = FurnishingType.unfurnished;
  List<String> _facilities = [];
  DateTime _availableFrom = DateTime.now();
  LatLng? _pickedLocation;

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
    LatLng initial = const LatLng(27.7172, 85.3240); // Kathmandu
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
        builder: (_) => _MapPickerScreen(initialLocation: initial),
      ),
    );
    if (result != null) setState(() => _pickedLocation = result);
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

    final user = ref.read(currentUserProvider).asData?.value;
    if (user == null) return;

    final id = await ref
        .read(uploadListingProvider.notifier)
        .uploadListing(
          ownerId: user.id,
          ownerName: user.name,
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
      appBar: const MkAppBar(title: 'Add listing'),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo placeholder
              _PhotoPlaceholder(),
              const SizedBox(height: 20),

              // Basic info
              _Card(
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
                  const _Label('Room type'),
                  const SizedBox(height: 8),
                  _SegmentSelector<RoomType>(
                    values: RoomType.values,
                    selected: _roomType,
                    label: (t) => t.name[0].toUpperCase() + t.name.substring(1),
                    onChanged: (v) => setState(() => _roomType = v),
                  ),
                  const SizedBox(height: AppSizes.md),
                  const _Label('Furnishing'),
                  const SizedBox(height: 8),
                  _SegmentSelector<FurnishingType>(
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

              // Pricing
              _Card(
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

              // Building details
              _Card(
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
                  const _Label('Available from'),
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

              // Facilities
              _Card(
                title: 'Facilities',
                children: [
                  FacilitiesSelector(
                    selected: _facilities,
                    onChanged: (v) => setState(() => _facilities = v),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Description
              _Card(
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

              // Location
              _Card(
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

                  // Map pin button
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

// ── Map Picker Screen (flutter_map) ───────────────────────────────

class _MapPickerScreen extends StatefulWidget {
  final LatLng initialLocation;
  const _MapPickerScreen({required this.initialLocation});

  @override
  State<_MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<_MapPickerScreen> {
  late LatLng _currentPin;
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _currentPin = widget.initialLocation;
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.grey900,
        elevation: 0,
        title: const Text(
          'Pin your room location',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.grey900,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, _currentPin),
            child: const Text(
              'Confirm',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.grey50),
        ),
      ),
      body: Stack(
        children: [
          // flutter_map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.initialLocation,
              initialZoom: 15,
              onPositionChanged: (pos, _) {
                setState(() => _currentPin = pos.center);
                            },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.merokotha.app',
                maxZoom: 19,
              ),
            ],
          ),

          // Fixed center pin
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 40),
              child: Icon(
                Icons.location_on_rounded,
                size: 48,
                color: AppColors.error,
              ),
            ),
          ),

          // Coordinates display
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_currentPin.latitude.toStringAsFixed(5)},  ${_currentPin.longitude.toStringAsFixed(5)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: 'monospace',
                      color: AppColors.grey700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom hint
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: AppColors.grey400,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Drag the map so the pin sits on your room\'s exact location, then tap Confirm.',
                      style: TextStyle(fontSize: 12, color: AppColors.grey600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helper widgets ─────────────────────────────────────────────────

class _PhotoPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.grey100),
      ),
      child: const Column(
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
          Text(
            'Available after Firebase Storage is set up',
            style: TextStyle(fontSize: 11, color: AppColors.grey400),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Card({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.grey50),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.grey900,
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.grey50),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: AppColors.grey800,
    ),
  );
}

class _SegmentSelector<T> extends StatelessWidget {
  final List<T> values;
  final T selected;
  final String Function(T) label;
  final void Function(T) onChanged;

  const _SegmentSelector({
    required this.values,
    required this.selected,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: values.map((v) {
        final isSelected = selected == v;
        final isLast = v == values.last;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(v),
            child: Container(
              margin: EdgeInsets.only(right: isLast ? 0 : 8),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryLight : Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.grey100,
                ),
              ),
              child: Text(
                label(v),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? AppColors.primary : AppColors.grey600,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

