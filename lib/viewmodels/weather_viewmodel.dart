import 'package:flutter/foundation.dart';

import '../models/location_model.dart';
import '../models/weather_model.dart';
import '../repositories/weather_repository.dart';

/// Status pemuatan data cuaca pada Home Screen.
enum WeatherStatus {
  initial,
  loading,
  loaded,
  empty,
  error,
}

/// ViewModel (MVVM) untuk mengelola state layar utama cuaca (Home Screen).
class WeatherViewModel extends ChangeNotifier {
  final WeatherRepository _repository;

  WeatherViewModel({required WeatherRepository repository})
      : _repository = repository;

  WeatherStatus _status = WeatherStatus.initial;
  LocationModel _selectedLocation = LocationModel.defaultLocation;
  WeatherResponse? _weather;
  String? _errorMessage;
  bool _useFahrenheit = false;

  WeatherStatus get status => _status;
  LocationModel get selectedLocation => _selectedLocation;
  WeatherResponse? get weather => _weather;
  String? get errorMessage => _errorMessage;
  bool get useFahrenheit => _useFahrenheit;

  /// Memuat lokasi terakhir & preferensi satuan dari penyimpanan lokal,
  /// lalu mengambil data cuaca terkini dari Open-Meteo API.
  Future<void> initialize() async {
    _useFahrenheit = await _repository.loadUseFahrenheit();
    final savedLocation = await _repository.loadSelectedLocation();
    if (savedLocation != null) {
      _selectedLocation = savedLocation;
    }
    notifyListeners();
    await fetchWeather();
  }

  /// Mengganti kota aktif, menyimpannya ke Local Storage, dan memuat cuacanya.
  Future<void> selectLocation(LocationModel location) async {
    _selectedLocation = location;
    await _repository.persistSelectedLocation(location);
    notifyListeners();
    await fetchWeather();
  }

  /// Mengambil ulang data cuaca kota yang sedang aktif dari Open-Meteo API.
  Future<void> fetchWeather() async {
    _status = WeatherStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getWeatherForLocation(_selectedLocation);
      if (result.daily.isEmpty) {
        _weather = null;
        _status = WeatherStatus.empty;
      } else {
        _weather = result;
        _status = WeatherStatus.loaded;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _status = WeatherStatus.error;
    }

    notifyListeners();
  }

  /// Mengubah satuan suhu antara Celsius (°C) dan Fahrenheit (°F).
  Future<void> toggleTemperatureUnit() async {
    _useFahrenheit = !_useFahrenheit;
    await _repository.persistUseFahrenheit(_useFahrenheit);
    notifyListeners();
  }
}
