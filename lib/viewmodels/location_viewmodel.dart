import 'package:flutter/foundation.dart';

import '../models/location_model.dart';
import '../repositories/weather_repository.dart';

/// Status pencarian kota pada Search / Location Screen.
enum SearchStatus {
  idle,
  loading,
  loaded,
  empty,
  error,
}

/// ViewModel (MVVM) untuk mengelola pencarian kota, daftar lokasi favorit,
/// serta riwayat pencarian yang tersimpan di SharedPreferences.
class LocationViewModel extends ChangeNotifier {
  final WeatherRepository _repository;

  LocationViewModel({required WeatherRepository repository})
      : _repository = repository;

  SearchStatus _searchStatus = SearchStatus.idle;
  String _lastQuery = '';
  List<LocationModel> _searchResults = [];
  List<LocationModel> _favorites = [];
  List<LocationModel> _searchHistory = [];
  String? _errorMessage;

  SearchStatus get searchStatus => _searchStatus;
  String get lastQuery => _lastQuery;
  List<LocationModel> get searchResults => List.unmodifiable(_searchResults);
  List<LocationModel> get favorites => List.unmodifiable(_favorites);
  List<LocationModel> get searchHistory => List.unmodifiable(_searchHistory);
  String? get errorMessage => _errorMessage;

  /// Memuat daftar favorit dan riwayat pencarian dari Local Storage saat aplikasi dibuka.
  Future<void> loadSavedLocations() async {
    _favorites = await _repository.loadFavorites();
    _searchHistory = await _repository.loadSearchHistory();
    notifyListeners();
  }

  /// Melakukan pencarian kota ke Open-Meteo Geocoding API.
  Future<void> searchCities(String query) async {
    final trimmed = query.trim();
    _lastQuery = trimmed;

    if (trimmed.isEmpty) {
      _searchResults = [];
      _searchStatus = SearchStatus.idle;
      _errorMessage = null;
      notifyListeners();
      return;
    }

    _searchStatus = SearchStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _repository.searchCities(trimmed);
      // Pastikan hasil masih sesuai dengan query terbaru.
      if (_lastQuery != trimmed) return;

      _searchResults = results;
      _searchStatus =
          results.isEmpty ? SearchStatus.empty : SearchStatus.loaded;
    } catch (e) {
      if (_lastQuery != trimmed) return;
      _errorMessage = e.toString();
      _searchStatus = SearchStatus.error;
    }

    notifyListeners();
  }

  /// Mengosongkan hasil pencarian dan mengembalikan layar ke mode favorit/riwayat.
  void clearSearch() {
    _lastQuery = '';
    _searchResults = [];
    _searchStatus = SearchStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }

  /// Mengecek apakah suatu lokasi sudah disimpan sebagai favorit.
  bool isFavorite(LocationModel location) {
    return _favorites.any((item) => item == location);
  }

  /// Menambah atau menghapus lokasi dari daftar favorit (Local Storage).
  Future<void> toggleFavorite(LocationModel location) async {
    final exists = isFavorite(location);
    if (exists) {
      _favorites = _favorites.where((item) => item != location).toList();
    } else {
      _favorites = [location, ..._favorites];
    }
    notifyListeners();
    await _repository.persistFavorites(_favorites);
  }

  /// Mencatat lokasi yang dipilih ke dalam riwayat pencarian (maksimal 10 kota terbaru).
  Future<void> addToHistory(LocationModel location) async {
    final filtered = _searchHistory.where((item) => item != location).toList();
    _searchHistory = [location, ...filtered].take(10).toList();
    notifyListeners();
    await _repository.persistSearchHistory(_searchHistory);
  }

  /// Menghapus satu item dari riwayat pencarian.
  Future<void> removeFromHistory(LocationModel location) async {
    _searchHistory = _searchHistory.where((item) => item != location).toList();
    notifyListeners();
    await _repository.persistSearchHistory(_searchHistory);
  }

  /// Menghapus seluruh riwayat pencarian.
  Future<void> clearHistory() async {
    _searchHistory = [];
    notifyListeners();
    await _repository.persistSearchHistory(_searchHistory);
  }
}
