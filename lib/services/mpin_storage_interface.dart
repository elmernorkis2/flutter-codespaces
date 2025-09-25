abstract class MPINStorageInterface {
  Future<void> saveMPIN(String mpin);
  Future<String?> getMPIN();
  Future<void> clearMPIN();
}
