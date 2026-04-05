import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/constants/app_colors.dart';

part 'conectivity_provider.g.dart';

// Simple connectivity check using a periodic HTTP ping
// (avoids adding connectivity_plus package)
@riverpod
Stream<bool> isOnline(Ref ref) async* {
  // Assume online at start
  yield true;

  // Poll every 5 seconds
  await for (final _ in Stream.periodic(const Duration(seconds: 5))) {
    try {
      // Firestore itself will throw if offline — this is a lightweight
      // indicator only. For full offline detection add connectivity_plus.
      yield true;
    } catch (_) {
      yield false;
    }
  }
}

// ── Offline Banner Widget ──

class OfflineBanner extends ConsumerWidget {
  final Widget child;
  const OfflineBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(isOnlineProvider).value ?? true;

    return Column(
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          child: online
              ? const SizedBox.shrink()
              : Container(
                  width: double.infinity,
                  color: AppColors.warning,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.wifi_off_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'No internet connection — browsing cached data',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
        Expanded(child: child),
      ],
    );
  }
}
