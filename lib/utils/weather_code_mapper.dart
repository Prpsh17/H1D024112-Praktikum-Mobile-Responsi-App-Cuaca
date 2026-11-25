/// Kategori visual ikon cuaca minimalis berdasarkan kode WMO Open-Meteo.
enum WeatherIconType {
  sunny,
  partlyCloudy,
  cloudy,
  fog,
  drizzle,
  rain,
  snow,
  thunderstorm,
}

/// Memetakan WMO Weather Interpretation Code dari Open-Meteo
/// menjadi label kondisi cuaca yang mudah dibaca dan tipe ikon minimalis.
class WeatherCodeMapper {
  WeatherCodeMapper._();

  static String description(int code) {
    switch (code) {
      case 0:
        return 'CERAH';
      case 1:
        return 'SEBAGIAN BESAR CERAH';
      case 2:
        return 'CERAH BERAWAN';
      case 3:
        return 'BERAWAN';
      case 45:
      case 48:
        return 'BERKABUT';
      case 51:
        return 'GERIMIS RINGAN';
      case 53:
        return 'GERIMIS SEDANG';
      case 55:
        return 'GERIMIS LEBAT';
      case 56:
      case 57:
        return 'GERIMIS BEKU';
      case 61:
        return 'HUJAN RINGAN';
      case 63:
        return 'HUJAN SEDANG';
      case 65:
        return 'HUJAN LEBAT';
      case 66:
      case 67:
        return 'HUJAN BEKU';
      case 71:
      case 73:
      case 75:
      case 77:
        return 'BERSALJU';
      case 80:
        return 'HUJAN LOKAL RINGAN';
      case 81:
        return 'HUJAN LOKAL SEDANG';
      case 82:
        return 'HUJAN LOKAL DERAS';
      case 85:
      case 86:
        return 'HUJAN SALJU';
      case 95:
        return 'BADAI PETIR';
      case 96:
      case 99:
        return 'BADAI PETIR & ES';
      default:
        return 'CUACA TIDAK DIKETAHUI';
    }
  }

  static WeatherIconType iconType(int code) {
    if (code == 0 || code == 1) {
      return WeatherIconType.sunny;
    } else if (code == 2) {
      return WeatherIconType.partlyCloudy;
    } else if (code == 3) {
      return WeatherIconType.cloudy;
    } else if (code == 45 || code == 48) {
      return WeatherIconType.fog;
    } else if (code >= 51 && code <= 57) {
      return WeatherIconType.drizzle;
    } else if ((code >= 61 && code <= 67) || (code >= 80 && code <= 82)) {
      return WeatherIconType.rain;
    } else if ((code >= 71 && code <= 77) || (code >= 85 && code <= 86)) {
      return WeatherIconType.snow;
    } else if (code >= 95 && code <= 99) {
      return WeatherIconType.thunderstorm;
    }
    return WeatherIconType.partlyCloudy;
  }
}
