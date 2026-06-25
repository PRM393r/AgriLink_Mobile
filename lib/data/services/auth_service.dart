import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Storing confirmation result for Web OTP verification
  ConfirmationResult? _webConfirmationResult;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Triggers Firebase Phone OTP sending.
  /// On Web, uses [signInWithPhoneNumber]. On Mobile, uses [verifyPhoneNumber].
  Future<void> sendOtp({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    try {
      if (kIsWeb) {
        // Firebase Web Phone auth
        final confirmationResult = await _auth.signInWithPhoneNumber(phoneNumber);
        _webConfirmationResult = confirmationResult;
        // For web, confirmationResult verificationId is not strictly needed but we pass a mock/hash or empty string
        onCodeSent(confirmationResult.verificationId);
      } else {
        // Firebase Mobile Phone auth
        await _auth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            // Auto-signin (Android-only usually)
            await _auth.signInWithCredential(credential);
          },
          verificationFailed: (FirebaseAuthException e) {
            onError(e.message ?? 'Xác thực số điện thoại thất bại');
          },
          codeSent: (String verificationId, int? resendToken) {
            onCodeSent(verificationId);
          },
          codeAutoRetrievalTimeout: (String verificationId) {},
        );
      }
    } catch (e) {
      onError(e.toString());
    }
  }

  /// Verifies the OTP smsCode entered by the user.
  /// Returns [UserCredential] if successful.
  Future<UserCredential> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      if (kIsWeb) {
        if (_webConfirmationResult == null) {
          throw Exception('Mã xác thực không hợp lệ. Vui lòng gửi lại OTP.');
        }
        final credential = await _webConfirmationResult!.confirm(smsCode);
        return credential;
      } else {
        final credential = PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: smsCode,
        );
        return await _auth.signInWithCredential(credential);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Retrieves the current user's Firebase ID Token.
  Future<String?> getIdToken() async {
    if (currentUser == null) return null;
    return await currentUser!.getIdToken(true);
  }

  /// Signs out of Firebase.
  Future<void> signOut() async {
    await _auth.signOut();
    _webConfirmationResult = null;
  }
}
