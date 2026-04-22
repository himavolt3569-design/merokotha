// ignore_for_file: deprecated_member_use

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FirebaseAppCheck.instance.activate(
    // Use debug provider in debug mode, Play Integrity in release
    androidProvider:
        AndroidProvider.debug, // 🔁 Change to .playIntegrity for production
    appleProvider:
        AppleProvider.debug, // 🔁 Change to .appAttest for production
  );

  runApp(const ProviderScope(child: MeroKothaApp()));
}
