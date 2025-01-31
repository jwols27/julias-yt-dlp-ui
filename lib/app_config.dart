class AppConfig {
  AppConfig._();

  static final AppConfig _instance = AppConfig._();

  static AppConfig get instance => _instance;

  bool mtime = false;
}