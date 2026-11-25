import '../models/location_model.dart';
import '../models/weather_model.dart';
import '../services/local_storage_service.dart';
import '../services/open_meteo_service.dart';

/// Repository sebagai penghubung antara ViewModel dengan sumber data
/// remote (OpenMeteoService) dan lokal (LocalStorageService).
class WeatherRepository {
  final OpenMeteoService _apiService;
  final LocalStorageService _storageService;

  WeatherRepository({
    required OpenMeteoService apiService,
    required LocalStorageService storageService,
  })  : _apiService = apiService,
        _storageService = storageService;

  Future<WeatherResponse> getWeatherForLocation(LocationModel location) {
    return _apiService.fetchWeather(
      latitude: location.latitude,
      longitude: location.longitude,
    );
  }

  Future<List<LocationModel>> searchCities(String query) {
    return _apiService.searchCities(query);
  }

  Future<List<LocationModel>> loadFavorites() => _storageService.getFavorites();

  Future<void> persistFavorites(List<LocationModel> favorites) =>
      _storageService.saveFavorites(favorites);

  Future<List<LocationModel>> loadSearchHistory() =>
      _storageService.getSearchHistory();

  Future<void> persistSearchHistory(List<LocationModel> history) =>
      _storageService.saveSearchHistory(history);

  Future<LocationModel?> loadSelectedLocation() =>
      _storageService.getSelectedLocation();

  Future<void> persistSelectedLocation(LocationModel location) =>
      _storageService.saveSelectedLocation(location);

  Future<bool> loadUseFahrenheit() => _storageService.getUseFahrenheit();

  Future<void> persistUseFahrenheit(bool value) =>
      _storageService.saveUseFahrenheit(value);
}
