import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  AppConfig._();

  static final AppConfig _instance = AppConfig._();

  static AppConfig get instance => _instance;

  late SharedPreferences _prefs;

  bool mtime = false;
  String destino = '';

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();

    mtime = _prefs.getBool("mtime") ?? false;
    destino = _prefs.getString("destino") ?? '';

    if(destino.isEmpty) {
      final directory = await getDownloadsDirectory();
      destino = directory?.path ?? '';
    }
  }

  Future<void> setMtime(bool value) async {
    mtime = value;
    _prefs.setBool("mtime", value);
  }

  Future<void> setDestino(String value) async {
    destino = value;
    _prefs.setString("destino", value);
  }
}