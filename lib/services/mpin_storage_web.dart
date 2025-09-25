import 'package:shared_preferences/shared_preferences.dart';
import 'mpin_storage_interface.dart';

class MPINStorageWeb implements MPINStorageInterface {
  @override
  Future<void> saveMPIN(String mpin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('mpin', mpin);
  }

  @override
  Future<String?> getMPIN() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('mpin');
  }

  @override
  Future<void> clearMPIN() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('mpin');
  }
}
