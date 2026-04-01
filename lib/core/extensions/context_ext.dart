import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

extension ContextExt on BuildContext {
  // Theme shortcuts
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;

  // Screen size
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
  EdgeInsets get padding => MediaQuery.paddingOf(this);

  // ✅ Fixed: delegate to GoRouter's own extension (via go_router package)
  // These shadow go_router's extension, so we must call GoRouter directly
  void pushRoute(String route, {Object? extra}) =>
      GoRouter.of(this).push(route, extra: extra);
  void goRoute(String route, {Object? extra}) =>
      GoRouter.of(this).go(route, extra: extra);
  void popRoute([Object? result]) => GoRouter.of(this).pop(result);

  // Snackbar
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colors.error : colors.primary,
      ),
    );
  }

  // Dismiss keyboard
  void dismissKeyboard() => FocusScope.of(this).unfocus();
}
