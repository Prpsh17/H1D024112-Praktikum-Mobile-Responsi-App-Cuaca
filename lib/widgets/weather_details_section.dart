import 'package:flutter/material.dart';

import '../models/weather_model.dart';
import '../theme/app_theme.dart';
import '../utils/date_formatter.dart';

/// Bagian informasi cuaca tambahan yang menampilkan seluruh field wajib Open-Meteo:
/// - Suhu yang dirasakan (`current.apparent_temperature`)
/// - Kelembapan (`current.relative_humidity_2m`)
/// - Kecepatan angin (`current.wind_speed_10m`)
/// - Curah hujan (`current.precipitation`)
/// - Peluang hujan maksimum (`daily.precipitation_probability_max`)
class WeatherDetailsSection extends StatelessWidget {
  final WeatherResponse weather;
  final bool useFahrenheit;

  const WeatherDetailsSection({
    super.key,
    required this.weather,
    required this.useFahrenheit,
  });

  @override
  Widget build(BuildContext context) {
    final current = weather.current;
    final feelsLike = DateFormatter.formatTemperatureValue(
      current.apparentTemperature,
      useFahrenheit: useFahrenheit,
    );
    final unitSymbol = useFahrenheit ? '°F' : '°C';

    final items = [
      _MetricData(
        label: 'TERASA SEPERTI',
        value: '$feelsLike$unitSymbol',
        icon: Icons.thermostat_outlined,
      ),
      _MetricData(
        label: 'KELEMBAPAN',
        value: '${current.relativeHumidity}%',
        icon: Icons.water_drop_outlined,
      ),
      _MetricData(
        label: 'KECEPATAN ANGIN',
        value: '${current.windSpeed.toStringAsFixed(1)} km/j',
        icon: Icons.air_outlined,
      ),
      _MetricData(
        label: 'CURAH HUJAN',
        value: '${current.precipitation.toStringAsFixed(1)} mm',
        icon: Icons.grain_outlined,
      ),
      _MetricData(
        label: 'PELUANG HUJAN',
        value: '${weather.todayPrecipitationProbability}%',
        icon: Icons.umbrella_outlined,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: items.map((item) => _MinimalMetricTile(data: item)).toList(),
      ),
    );
  }
}

class _MetricData {
  final String label;
  final String value;
  final IconData icon;

  const _MetricData({
    required this.label,
    required this.value,
    required this.icon,
  });
}

class _MinimalMetricTile extends StatelessWidget {
  final _MetricData data;

  const _MinimalMetricTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: 152,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.hairline,
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                data.icon,
                size: 15,
                color: AppTheme.inkMuted,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  data.label,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    letterSpacing: 1.4,
                    color: AppTheme.inkMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            data.value,
            style: textTheme.bodyLarge?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: AppTheme.inkPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
