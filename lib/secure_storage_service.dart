import 'mpin_storage_interface.dart';
import 'mpin_storage_mobile.dart'
    if (dart.library.html) 'mpin_storage_web.dart';

class SecureStorageService {
  static final MPINStorageInterface _storage = MPINStorageMobile();

  static Future<void> saveMPIN(String mpin) => _storage.saveMPIN(mpin);
  static Future<String?> getMPIN() => _storage.getMPIN();
  static Future<void> clearMPIN() => _storage.clearMPIN();
}
