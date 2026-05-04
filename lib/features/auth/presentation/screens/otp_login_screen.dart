import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:merokotha/core/constants/app_colors.dart';
import 'package:merokotha/core/constants/app_sizes.dart';
import 'package:merokotha/core/constants/app_strings.dart';
import 'package:merokotha/core/router/app_routes.dart';
import 'package:merokotha/core/utils/validators.dart';
import 'package:merokotha/features/auth/data/user_repository.dart';
import 'package:merokotha/features/auth/presentation/widgets/otp_input_field.dart';
import 'package:merokotha/features/auth/providers/auth_provider.dart';

class OtpLoginScreen extends ConsumerStatefulWidget {
  const OtpLoginScreen({super.key});

  @override
  ConsumerState<OtpLoginScreen> createState() => _OtpLoginScreenState();
}

class _OtpLoginScreenState extends ConsumerState<OtpLoginScreen> {
  final _phoneFormKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpKey = GlobalKey();

  String _otpValue = '';
  bool _showOtpField = false;
  int _resendCountdown = 60;
  Timer? _timer;

  @override
  void dispose() {
    _phoneController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendCountdown = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendCountdown == 0) {
        t.cancel();
      } else {
        setState(() => _resendCountdown--);
      }
    });
  }

  Future<void> _sendOtp() async {
    if (!_phoneFormKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    await ref.read(otpProvider.notifier).sendOtp(_phoneController.text.trim());
  }

  Future<void> _verifyOtp() async {
    if (_otpValue.length != 6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppStrings.invalidOtp)));
      return;
    }
    FocusScope.of(context).unfocus();

    final success = await ref.read(otpProvider.notifier).verifyOtp(_otpValue);

    if (!success || !mounted) return;

    final firebaseUser = ref.read(authStateProvider).value;
    if (firebaseUser == null) return;

    final userExists = await ref
        .read(userRepositoryProvider)
        .userExists(firebaseUser.uid);

    if (!mounted) return;
    if (!userExists) {
      context.go(AppRoutes.roleSelect);
    } else {
      final user = await ref
          .read(userRepositoryProvider)
          .getUser(firebaseUser.uid);
      if (!mounted) return;
      context.go(
        user?.isOwner == true ? AppRoutes.ownerHome : AppRoutes.customerHome,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final otpState = ref.watch(otpProvider);

    ref.listen(otpProvider, (prev, next) {
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
      }
      if (next.codeSent && !(prev?.codeSent ?? false) && mounted) {
        setState(() => _showOtpField = true);
        _startResendTimer();
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/merokotha.png',
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    AppStrings.appName,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.grey900,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 60),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _showOtpField
                    ? _OtpHeading(phone: _phoneController.text.trim())
                    : const _PhoneHeading(),
              ),

              const SizedBox(height: 32),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: _showOtpField
                    ? _buildOtpSection(otpState)
                    : _buildPhoneSection(otpState),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneSection(OtpState otpState) {
    return Form(
      key: _phoneFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            validator: Validators.phone,
            style: const TextStyle(fontSize: 16, color: AppColors.grey900),
            decoration: InputDecoration(
              hintText: AppStrings.phoneHint,
              prefixIcon: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.grey50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '🇳🇵 +977',
                  style: TextStyle(fontSize: 14, color: AppColors.grey800),
                ),
              ),
              prefixIconConstraints: const BoxConstraints(),
            ),
          ),

          const SizedBox(height: AppSizes.lg),

          SizedBox(
            width: double.infinity,
            height: AppSizes.buttonHeight,
            child: ElevatedButton(
              onPressed: otpState.isSending ? null : _sendOtp,
              child: otpState.isSending
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(AppStrings.sendOtp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpSection(OtpState otpState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OtpInputField(
          key: _otpKey,
          onCompleted: (otp) => setState(() => _otpValue = otp),
          onChanged: (otp) => setState(() => _otpValue = otp),
        ),

        const SizedBox(height: AppSizes.lg),

        SizedBox(
          width: double.infinity,
          height: AppSizes.buttonHeight,
          child: ElevatedButton(
            onPressed: otpState.isVerifying ? null : _verifyOtp,
            child: otpState.isVerifying
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(AppStrings.verifyOtp),
          ),
        ),

        const SizedBox(height: AppSizes.md),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _resendCountdown > 0
                ? Text(
                    '${AppStrings.resendIn} $_resendCountdown${AppStrings.seconds}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.grey400,
                    ),
                  )
                : GestureDetector(
                    onTap: otpState.isSending ? null : _sendOtp,
                    child: const Text(
                      AppStrings.resendOtp,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

            GestureDetector(
              onTap: () {
                ref.read(otpProvider.notifier).resetAll();
                setState(() {
                  _showOtpField = false;
                  _otpValue = '';
                });
                _timer?.cancel();
              },
              child: const Text(
                'Change number',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.grey600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PhoneHeading extends StatelessWidget {
  const _PhoneHeading();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Welcome!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.grey900,
          ),
        ),
        SizedBox(height: 8),
        Text(
          AppStrings.enterPhone,
          style: TextStyle(fontSize: 15, color: AppColors.grey600, height: 1.5),
        ),
      ],
    );
  }
}

class _OtpHeading extends StatelessWidget {
  final String phone;
  const _OtpHeading({required this.phone});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enter OTP',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.grey900,
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.grey600,
              height: 1.5,
            ),
            children: [
              const TextSpan(text: '${AppStrings.otpSentTo} '),
              TextSpan(
                text: '+977 $phone',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
