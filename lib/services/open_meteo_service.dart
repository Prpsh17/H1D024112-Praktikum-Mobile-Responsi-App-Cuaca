import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/location_model.dart';
import '../models/weather_model.dart';

/// Exception khusus untuk kesalahan jaringan atau respons API.
class ApiException implements Exception {
  final String message;

  const ApiException(this.message);

  @override
  String toString() => message;
}

/// Service networking HTTP GET untuk mengakses REST API Open-Meteo
/// (Weather Forecast API dan Geocoding API).
class OpenMeteoService {
  static const String _forecastHost = 'api.open-meteo.com';
  static const String _geocodingHost = 'geocoding-api.open-meteo.com';
  static const Duration _timeout = Duration(seconds: 15);

  final http.Client _client;

  OpenMeteoService({http.Client? client}) : _client = client ?? http.Client();

  /// Mengambil data cuaca terkini dan prakiraan harian 7 hari ke depan.
  Future<WeatherResponse> fetchWeather({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.https(_forecastHost, '/v1/forecast', {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'current':
          'temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m',
      'daily':
          'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max',
      'timezone': 'auto',
      'forecast_days': '7',
    });

    try {
      final response = await _client.get(uri).timeout(_timeout);

      if (response.statusCode != 200) {
        throw ApiException(
          'Gagal memuat data cuaca (HTTP ${response.statusCode}).',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const ApiException('Format respons data cuaca tidak valid.');
      }

      return WeatherResponse.fromJson(decoded);
    } on SocketException {
      throw const ApiException(
        'Tidak ada koneksi internet. Periksa jaringan Anda lalu coba lagi.',
      );
    } on TimeoutException {
      throw const ApiException(
        'Permintaan ke server cuaca melebihi batas waktu. Coba lagi.',
      );
    } on FormatException {
      throw const ApiException('Gagal memproses data JSON dari server cuaca.');
    }
  }

  /// Mencari daftar kota berdasarkan nama melalui Open-Meteo Geocoding API.
  Future<List<LocationModel>> searchCities(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return [];
    }

    final uri = Uri.https(_geocodingHost, '/v1/search', {
      'name': trimmed,
      'count': '10',
      'language': 'id',
      'format': 'json',
    });

    try {
      final response = await _client.get(uri).timeout(_timeout);

      if (response.statusCode != 200) {
        throw ApiException(
          'Gagal mencari lokasi (HTTP ${response.statusCode}).',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const ApiException('Format respons pencarian lokasi tidak valid.');
      }

      final results = decoded['results'] as List<dynamic>?;
      if (results == null || results.isEmpty) {
        return [];
      }

      return results
          .whereType<Map<String, dynamic>>()
          .map(LocationModel.fromGeocodingJson)
          .toList();
    } on SocketException {
      throw const ApiException(
        'Tidak ada koneksi internet. Periksa jaringan Anda lalu coba lagi.',
      );
    } on TimeoutException {
      throw const ApiException(
        'Permintaan pencarian lokasi melebihi batas waktu. Coba lagi.',
      );
    } on FormatException {
      throw const ApiException('Gagal memproses data lokasi dari server.');
    }
  }
}
