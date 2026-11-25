/// Utility pemformatan tanggal dan suhu tanpa dependensi eksternal tambahan.
class DateFormatter {
  DateFormatter._();

  static const List<String> _shortDays = [
    'SEN',
    'SEL',
    'RAB',
    'KAM',
    'JUM',
    'SAB',
    'MIN',
  ];

  /// Mengubah tanggal ISO (`YYYY-MM-DD`) menjadi label pendek (`HARI INI`, `SEN`, `SEL`, dst.).
  static String formatDayLabel(DateTime date, {required int index}) {
    if (index == 0) {
      return 'HARI INI';
    }
    return _shortDays[date.weekday - 1];
  }

  /// Konversi suhu Celsius ke Fahrenheit bila pengguna memilih satuan Fahrenheit.
  static double convertTemperature(double celsius, {required bool useFahrenheit}) {
    if (!useFahrenheit) return celsius;
    return (celsius * 9 / 5) + 32;
  }

  /// Format angka suhu bulat (misal: `29`).
  static String formatTemperatureValue(
    double celsius, {
    required bool useFahrenheit,
  }) {
    final value = convertTemperature(celsius, useFahrenheit: useFahrenheit);
    return value.round().toString();
  }
}
