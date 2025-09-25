import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:local_auth/local_auth.dart';

class BiometricService {
  static Future<bool> authenticate() async {
    if (kIsWeb) return false; // Web doesn't support biometrics

    final auth = LocalAuthentication();
    final isAvailable = await auth.canCheckBiometrics;
    final isDeviceSupported = await auth.isDeviceSupported();

    if (!isAvailable || !isDeviceSupported) return false;

    return await auth.authenticate(
      localizedReason: 'Please authenticate to access PHCash',
      options: const AuthenticationOptions(
        biometricOnly: true,
        stickyAuth: true,
      ),
    );
  }
}
