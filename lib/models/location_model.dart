/// Model data lokasi kota yang diperoleh dari Open-Meteo Geocoding API
/// dan disimpan secara lokal pada SharedPreferences.
class LocationModel {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String country;
  final String? admin1;
  final String? timezone;

  const LocationModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.country,
    this.admin1,
    this.timezone,
  });

  /// Lokasi awal default sebelum pengguna memilih kota lain.
  /// Data cuacanya tetap diambil secara langsung (live) dari Open-Meteo API.
  static const LocationModel defaultLocation = LocationModel(
    id: 2673730,
    name: 'Stockholm',
    latitude: 59.3293,
    longitude: 18.0686,
    country: 'Sweden',
    admin1: 'Stockholm',
    timezone: 'Europe/Stockholm',
  );

  /// Label wilayah lengkap, misalnya `Central Java, Indonesia`.
  String get subtitle {
    if (admin1 != null && admin1!.trim().isNotEmpty && admin1 != name) {
      return '$admin1, $country';
    }
    return country;
  }

  factory LocationModel.fromGeocodingJson(Map<String, dynamic> json) {
    return LocationModel(
      id: (json['id'] as num?)?.toInt() ??
          Object.hash(json['name'], json['latitude'], json['longitude']),
      name: (json['name'] as String?) ?? 'Unknown',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      country: (json['country'] as String?) ?? '',
      admin1: json['admin1'] as String?,
      timezone: json['timezone'] as String?,
    );
  }

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? 'Unknown',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      country: (json['country'] as String?) ?? '',
      admin1: json['admin1'] as String?,
      timezone: json['timezone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'country': country,
      'admin1': admin1,
      'timezone': timezone,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationModel &&
        other.id == id &&
        other.name == name &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode => Object.hash(id, name, latitude, longitude);
}
