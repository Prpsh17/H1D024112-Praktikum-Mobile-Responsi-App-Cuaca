import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/location_model.dart';

/// Service penyimpanan lokal menggunakan SharedPreferences untuk menyimpan:
/// 1. Daftar lokasi favorit
/// 2. Riwayat pencarian kota
/// 3. Lokasi terakhir yang dipilih
/// 4. Preferensi satuan suhu (°C / °F)
class LocalStorageService {
  static const String _favoritesKey = 'favorite_locations_v1';
  static const String _historyKey = 'search_history_v1';
  static const String _selectedLocationKey = 'selected_location_v1';
  static const String _useFahrenheitKey = 'use_fahrenheit_v1';
  static const int _maxHistoryItems = 10;

  Future<List<LocationModel>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_favoritesKey) ?? [];
    return _decodeLocationList(rawList);
  }

  Future<void> saveFavorites(List<LocationModel> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = favorites.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_favoritesKey, encoded);
  }

  Future<List<LocationModel>> getSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_historyKey) ?? [];
    return _decodeLocationList(rawList);
  }

  Future<void> saveSearchHistory(List<LocationModel> history) async {
    final prefs = await SharedPreferences.getInstance();
    final trimmed = history.take(_maxHistoryItems).toList();
    final encoded = trimmed.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_historyKey, encoded);
  }

  Future<LocationModel?> getSelectedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_selectedLocationKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw);
      if (map is Map<String, dynamic>) {
        return LocationModel.fromJson(map);
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  Future<void> saveSelectedLocation(LocationModel location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedLocationKey, jsonEncode(location.toJson()));
  }

  Future<bool> getUseFahrenheit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_useFahrenheitKey) ?? false;
  }

  Future<void> saveUseFahrenheit(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_useFahrenheitKey, value);
  }

  List<LocationModel> _decodeLocationList(List<String> rawList) {
    final locations = <LocationModel>[];
    for (final item in rawList) {
      try {
        final decoded = jsonDecode(item);
        if (decoded is Map<String, dynamic>) {
          locations.add(LocationModel.fromJson(decoded));
        }
      } catch (_) {
        // Lewati entri rusak tanpa menghentikan pemuatan data lain.
      }
    }
    return locations;
  }
}
