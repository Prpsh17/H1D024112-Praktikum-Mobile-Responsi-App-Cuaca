/// Model data cuaca terkini dari field `current` pada Open-Meteo Forecast API.
class CurrentWeather {
  final DateTime time;
  final double temperature;
  final int relativeHumidity;
  final double apparentTemperature;
  final double precipitation;
  final int weatherCode;
  final double windSpeed;

  const CurrentWeather({
    required this.time,
    required this.temperature,
    required this.relativeHumidity,
    required this.apparentTemperature,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      time: DateTime.tryParse((json['time'] as String?) ?? '') ?? DateTime.now(),
      temperature: (json['temperature_2m'] as num?)?.toDouble() ?? 0.0,
      relativeHumidity: (json['relative_humidity_2m'] as num?)?.round() ?? 0,
      apparentTemperature:
          (json['apparent_temperature'] as num?)?.toDouble() ?? 0.0,
      precipitation: (json['precipitation'] as num?)?.toDouble() ?? 0.0,
      weatherCode: (json['weather_code'] as num?)?.toInt() ?? 0,
      windSpeed: (json['wind_speed_10m'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Model prakiraan cuaca harian dari field `daily` pada Open-Meteo Forecast API.
class DailyForecast {
  final DateTime date;
  final int weatherCode;
  final double maxTemperature;
  final double minTemperature;
  final int precipitationProbabilityMax;

  const DailyForecast({
    required this.date,
    required this.weatherCode,
    required this.maxTemperature,
    required this.minTemperature,
    required this.precipitationProbabilityMax,
  });
}

/// Model respons lengkap dari Open-Meteo Forecast API.
class WeatherResponse {
  final double latitude;
  final double longitude;
  final String timezone;
  final CurrentWeather current;
  final List<DailyForecast> daily;

  const WeatherResponse({
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.current,
    required this.daily,
  });

  /// Peluang hujan maksimum hari ini (diambil dari elemen pertama `daily`).
  int get todayPrecipitationProbability {
    if (daily.isEmpty) return 0;
    return daily.first.precipitationProbabilityMax;
  }

  factory WeatherResponse.fromJson(Map<String, dynamic> json) {
    final currentMap = (json['current'] as Map<String, dynamic>?) ?? {};
    final dailyMap = (json['daily'] as Map<String, dynamic>?) ?? {};

    final times = (dailyMap['time'] as List<dynamic>?) ?? [];
    final codes = (dailyMap['weather_code'] as List<dynamic>?) ?? [];
    final maxTemps = (dailyMap['temperature_2m_max'] as List<dynamic>?) ?? [];
    final minTemps = (dailyMap['temperature_2m_min'] as List<dynamic>?) ?? [];
    final rainProbs =
        (dailyMap['precipitation_probability_max'] as List<dynamic>?) ?? [];

    final count = [
      times.length,
      codes.length,
      maxTemps.length,
      minTemps.length,
      rainProbs.length,
    ].reduce((a, b) => a < b ? a : b);

    final dailyList = List<DailyForecast>.generate(count, (i) {
      return DailyForecast(
        date: DateTime.tryParse(times[i].toString()) ??
            DateTime.now().add(Duration(days: i)),
        weatherCode: (codes[i] as num?)?.toInt() ?? 0,
        maxTemperature: (maxTemps[i] as num?)?.toDouble() ?? 0.0,
        minTemperature: (minTemps[i] as num?)?.toDouble() ?? 0.0,
        precipitationProbabilityMax: (rainProbs[i] as num?)?.round() ?? 0,
      );
    });

    return WeatherResponse(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      timezone: (json['timezone'] as String?) ?? 'auto',
      current: CurrentWeather.fromJson(currentMap),
      daily: dailyList,
    );
  }
}
