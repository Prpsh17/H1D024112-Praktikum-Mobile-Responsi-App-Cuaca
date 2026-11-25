import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_weather_responsi/models/location_model.dart';
import 'package:flutter_weather_responsi/models/weather_model.dart';
import 'package:flutter_weather_responsi/utils/weather_code_mapper.dart';

void main() {
  group('WeatherResponse.fromJson', () {
    test('memproses seluruh field wajib Open-Meteo Forecast API dengan benar',
        () {
      final sampleJson = {
        'latitude': -6.99,
        'longitude': 110.42,
        'timezone': 'Asia/Jakarta',
        'current': {
          'time': '2026-11-25T15:00',
          'temperature_2m': 31.4,
          'relative_humidity_2m': 68,
          'apparent_temperature': 35.1,
          'precipitation': 0.2,
          'weather_code': 2,
          'wind_speed_10m': 12.6,
        },
        'daily': {
          'time': ['2026-11-25', '2026-11-26', '2026-11-27'],
          'weather_code': [2, 3, 61],
          'temperature_2m_max': [32.5, 31.0, 29.5],
          'temperature_2m_min': [24.2, 23.8, 23.1],
          'precipitation_probability_max': [45, 60, 85],
        },
      };

      final response = WeatherResponse.fromJson(sampleJson);

      expect(response.current.temperature, 31.4);
      expect(response.current.relativeHumidity, 68);
      expect(response.current.apparentTemperature, 35.1);
      expect(response.current.precipitation, 0.2);
      expect(response.current.weatherCode, 2);
      expect(response.current.windSpeed, 12.6);
      expect(response.todayPrecipitationProbability, 45);
      expect(response.daily.length, 3);
      expect(response.daily[2].maxTemperature, 29.5);
      expect(response.daily[2].minTemperature, 23.1);
    });
  });

  group('LocationModel', () {
    test('memproses respons Open-Meteo Geocoding API dan serialisasi JSON', () {
      final geoJson = {
        'id': 1627896,
        'name': 'Semarang',
        'latitude': -6.9932,
        'longitude': 110.4203,
        'country': 'Indonesia',
        'admin1': 'Central Java',
        'timezone': 'Asia/Jakarta',
      };

      final location = LocationModel.fromGeocodingJson(geoJson);
      final restored = LocationModel.fromJson(location.toJson());

      expect(restored, location);
      expect(restored.subtitle, 'Central Java, Indonesia');
    });
  });

  group('WeatherCodeMapper', () {
    test('memetakan kode WMO ke deskripsi dan ikon', () {
      expect(WeatherCodeMapper.description(0), 'CERAH');
      expect(WeatherCodeMapper.iconType(0), WeatherIconType.sunny);
      expect(WeatherCodeMapper.iconType(2), WeatherIconType.partlyCloudy);
      expect(WeatherCodeMapper.iconType(63), WeatherIconType.rain);
    });
  });
}
