import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _key = 'sakhi_v1';
  final SharedPreferences _prefs;

  StorageService._(this._prefs);

  static Future<StorageService> init() async =>
      StorageService._(await SharedPreferences.getInstance());

  Map<String, dynamic>? load() {
    try {
      final raw = _prefs.getString(_key);
      if (raw == null) return null;
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic> && decoded['contacts'] != null) {
        return decoded;
      }
    } catch (_) {}
    return null;
  }

  Future<void> save(Map<String, dynamic> state) async {
    try {
      await _prefs.setString(_key, jsonEncode(state));
    } catch (_) {}
  }
}