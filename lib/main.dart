// ignore_for_file: deprecated_member_use

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merokotha/features/notification/notification_service.dart';

import 'package:merokotha/app.dart';
import 'package:merokotha/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Firebase App Check
  await FirebaseAppCheck.instance.activate(
    androidProvider:
        AndroidProvider.playIntegrity, // 🔁 Change to .debug for testing
    appleProvider: AppleProvider.appAttest, // 🔁 Change to .debug for testing
  );

  // Initialize local notifications
  await NotificationService().init();

  runApp(const ProviderScope(child: MeroKothaApp()));
}
