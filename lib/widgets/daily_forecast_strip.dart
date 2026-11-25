import 'package:flutter/material.dart';

import '../models/weather_model.dart';
import '../theme/app_theme.dart';
import '../utils/date_formatter.dart';
import 'minimal_weather_icon.dart';

/// Deretan prakiraan cuaca harian yang menampilkan 3 kolom rapi per layar
/// (seperti `TODAY | MON | TUES` pada template UI) dan dapat digeser horizontal
/// untuk melihat prakiraan hingga 7 hari ke depan.
class DailyForecastStrip extends StatelessWidget {
  final List<DailyForecast> forecasts;
  final bool useFahrenheit;

  const DailyForecastStrip({
    super.key,
    required this.forecasts,
    required this.useFahrenheit,
  });

  @override
  Widget build(BuildContext context) {
    if (forecasts.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Menampilkan tepat 3 kolom seimbang per lebar viewport seperti di template UI
        final itemWidth = (constraints.maxWidth / 3).clamp(96.0, 140.0);

        return SizedBox(
          height: 146,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: forecasts.length,
            itemBuilder: (context, index) {
              final item = forecasts[index];
              return SizedBox(
                width: itemWidth,
                child: _DailyForecastColumn(
                  forecast: item,
                  dayLabel: DateFormatter.formatDayLabel(
                    item.date,
                    index: index,
                  ),
                  useFahrenheit: useFahrenheit,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _DailyForecastColumn extends StatelessWidget {
  final DailyForecast forecast;
  final String dayLabel;
  final bool useFahrenheit;

  const _DailyForecastColumn({
    required this.forecast,
    required this.dayLabel,
    required this.useFahrenheit,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final maxTemp = DateFormatter.formatTemperatureValue(
      forecast.maxTemperature,
      useFahrenheit: useFahrenheit,
    );
    final minTemp = DateFormatter.formatTemperatureValue(
      forecast.minTemperature,
      useFahrenheit: useFahrenheit,
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          dayLabel,
          style: textTheme.labelLarge,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 16),
        MinimalWeatherIcon(
          weatherCode: forecast.weatherCode,
          size: 46,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$maxTemp°',
              style: textTheme.bodyLarge,
            ),
            Container(
              width: 1,
              height: 18,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              color: AppTheme.hairline,
            ),
            Text(
              '$minTemp°',
              style: textTheme.bodyLarge?.copyWith(
                color: AppTheme.inkSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
