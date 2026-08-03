import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:merokotha/core/constants/app_colors.dart';
import 'package:merokotha/core/constants/app_sizes.dart';

class OtpInputField extends StatefulWidget {
  final void Function(String otp) onCompleted;
  final void Function(String otp)? onChanged;

  const OtpInputField({super.key, required this.onCompleted, this.onChanged});

  @override
  State<OtpInputField> createState() => _OtpInputFieldState();
}

class _OtpInputFieldState extends State<OtpInputField> {
  static const _length = 6;
  final _controllers = List.generate(_length, (_) => TextEditingController());
  final _focusNodes = List.generate(_length, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _currentOtp => _controllers.map((c) => c.text).join();

  void _onChanged(int index, String value) {
    if (value.length > 1) {
      // Handle paste — distribute across boxes
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < _length && i < digits.length; i++) {
        _controllers[i].text = digits[i];
      }
      final nextFocus = digits.length < _length ? digits.length : _length - 1;
      _focusNodes[nextFocus].requestFocus();
      widget.onChanged?.call(_currentOtp);
      if (_currentOtp.length == _length) widget.onCompleted(_currentOtp);
      return;
    }

    if (value.isNotEmpty && index < _length - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    widget.onChanged?.call(_currentOtp);
    if (_currentOtp.length == _length) widget.onCompleted(_currentOtp);
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
    }
  }

  void clear() {
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_length, (index) {
        return KeyboardListener(
          focusNode: FocusNode(),
          onKeyEvent: (e) => _onKeyEvent(index, e),
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _focusNodes[index],
              _controllers[index],
            ]),
            builder: (context, _) {
              final focused = _focusNodes[index].hasFocus;
              final filled = _controllers[index].text.isNotEmpty;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOut,
                width: 48,
                height: 56,
                decoration: BoxDecoration(
                  color: focused || filled
                      ? AppColors.primaryLight
                      : AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(
                    color: focused ? AppColors.primary : AppColors.border,
                    width: focused ? 1.6 : 1,
                  ),
                  boxShadow: focused
                      ? const [
                          BoxShadow(
                            color: Color(0x1D1D9E75),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: TextFormField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.grey900,
                  ),
                  decoration: const InputDecoration(
                    counterText: '',
                    contentPadding: EdgeInsets.zero,
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  onChanged: (v) => _onChanged(index, v),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
