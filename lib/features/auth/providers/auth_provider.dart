import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/auth_repository.dart';
import '../data/user_repository.dart';
import '../../../shared/models/user_model.dart';

part 'auth_provider.g.dart';

// ── Raw Firebase auth state stream ──
@riverpod
Stream<User?> authState(Ref ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
}

// ── Current AppUser from Firestore ──
@riverpod
Future<UserModel?> currentUser(Ref ref) async {
  final firebaseUser = ref
      .watch(authStateProvider)
      .whenData((data) => data)
      .value;
  if (firebaseUser == null) return null;
  return ref.watch(userRepositoryProvider).getUser(firebaseUser.uid);
}

// ── OTP send/verify state ──
class OtpState {
  final bool isSending;
  final bool isVerifying;
  final String? verificationId;
  final int? resendToken;
  final String? errorMessage;
  final bool codeSent;

  const OtpState({
    this.isSending = false,
    this.isVerifying = false,
    this.verificationId,
    this.resendToken,
    this.errorMessage,
    this.codeSent = false,
  });

  OtpState copyWith({
    bool? isSending,
    bool? isVerifying,
    String? verificationId,
    int? resendToken,
    String? errorMessage,
    bool? codeSent,
    bool clearError = false,
  }) {
    return OtpState(
      isSending: isSending ?? this.isSending,
      isVerifying: isVerifying ?? this.isVerifying,
      verificationId: verificationId ?? this.verificationId,
      resendToken: resendToken ?? this.resendToken,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      codeSent: codeSent ?? this.codeSent,
    );
  }
}

@riverpod
class OtpNotifier extends _$OtpNotifier {
  @override
  OtpState build() => const OtpState();

  Future<void> sendOtp(String phoneNumber) async {
    state = state.copyWith(isSending: true, clearError: true);

    // Format phone number for Firebase (must include country code)
    final formatted = phoneNumber.startsWith('+')
        ? phoneNumber
        : '+977${phoneNumber.replaceAll(RegExp(r'^0'), '')}';

    await ref
        .read(authRepositoryProvider)
        .sendOtp(
          phoneNumber: formatted,
          onCodeSent: (verificationId, resendToken) {
            // print('✅ CODE SENT: $verificationId'); //
            state = state.copyWith(
              isSending: false,
              codeSent: true,
              verificationId: verificationId,
              resendToken: resendToken,
            );
          },
          onError: (e) {
            // print('❌ OTP ERROR: ${e.code}'); //
            // Map Firebase error codes to user-friendly messages
            // and update state with the error
            state = state.copyWith(
              isSending: false,
              errorMessage: _mapFirebaseError(e.code),
            );
          },
          onAutoVerified: (credential) async {
            state = state.copyWith(isVerifying: true);
            try {
              // ✅ Use repository, not FirebaseAuth.instance directly
              await FirebaseAuth.instance.signInWithCredential(credential);
            } catch (_) {}
            state = state.copyWith(isVerifying: false);
          },
        );
  }

  Future<bool> verifyOtp(String smsCode) async {
    if (state.verificationId == null) return false;
    state = state.copyWith(isVerifying: true, clearError: true);
    try {
      await ref
          .read(authRepositoryProvider)
          .verifyOtp(verificationId: state.verificationId!, smsCode: smsCode);
      state = state.copyWith(isVerifying: false);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isVerifying: false,
        errorMessage: _mapFirebaseError(e.code),
      );
      return false;
    }
  }

  void resetError() => state = state.copyWith(clearError: true);
  void resetAll() => state = const OtpState();

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'invalid-phone-number':
        return 'Invalid phone number format';
      case 'too-many-requests':
        return 'Too many attempts. Try again later';
      case 'invalid-verification-code':
        return 'Wrong OTP. Please try again';
      case 'session-expired':
        return 'OTP expired. Request a new one';
      case 'network-request-failed':
        return 'No internet connection';
      case 'sms-retriever-timeout':
        return 'Could not retrieve SMS automatically. Please enter OTP manually';
      case 'sms-retriever-error':
        return 'SMS retrieval failed. Please enter OTP manually';
      default:
        return 'Something went wrong. Please try again';
    }
  }
}
