import 'dart:ui' show Brightness;

import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:flutter/scheduler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  AppConfig._();

  static final AppConfig _instance = AppConfig._();

  static AppConfig get instance => _instance;

  late SharedPreferences _prefs;

  bool mtime = false;
  String destino = '';
  bool h26x = false;
  bool temDeps = false;
  ValueNotifier<bool> modoEscuro = ValueNotifier(false);

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();

    var brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;

    mtime = _prefs.getBool("mtime") ?? false;
    destino = _prefs.getString("destino") ?? '';
    h26x = _prefs.getBool("h26x") ?? false;
    temDeps = _prefs.getBool("temDeps") ?? false;

    modoEscuro.value = _prefs.getBool("modoEscuro") ?? brightness == Brightness.dark;

    if (destino.isEmpty) {
      final directory = await getDownloadsDirectory();
      destino = directory?.path ?? './';
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

  Future<void> setH26x(bool value) async {
    h26x = value;
    _prefs.setBool("h26x", value);
  }

  Future<void> setTemDeps(bool value) async {
    temDeps = value;
    _prefs.setBool("temDeps", value);
  }

  Future<void> setModoEscuro(bool value) async {
    modoEscuro.value = value;
    _prefs.setBool("modoEscuro", value);
  }
}
