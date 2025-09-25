import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'mpin_storage_interface.dart';

class MPINStorageMobile implements MPINStorageInterface {
  final FlutterSecureStorage _secure = const FlutterSecureStorage();

  @override
  Future<void> saveMPIN(String mpin) async {
    await _secure.write(key: 'user_mpin', value: mpin);
  }

  @override
  Future<String?> getMPIN() async {
    return await _secure.read(key: 'user_mpin');
  }

  @override
  Future<void> clearMPIN() async {
    await _secure.delete(key: 'user_mpin');
  }
}
