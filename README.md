# Minimalist Weather App — Responsi Flutter

Aplikasi cuaca berbasis **Flutter (Dart)** dengan pola arsitektur **MVVM (Model–View–ViewModel)**, state management **Provider**, penyimpanan lokal **SharedPreferences**, dan data cuaca *real-time* dari **Open-Meteo REST API**. Antarmuka dirancang mengikuti gaya minimalis berlatar gradasi hangat, tipografi sans-serif tipis, garis pemisah halus, serta ikon cuaca *line-art* kustom.

---

## Fitur Utama

1. **Home / Weather Screen**
   - Menampilkan nama kota terpilih beserta tombol simpan favorit (`★`).
   - Menampilkan suhu terkini berukuran besar dengan simbol derajat melingkar halus dan kondisi cuaca hasil pemetaan kode WMO.
   - Menampilkan prakiraan cuaca harian (3 kolom terlihat sesuai template UI, dapat digeser horizontal hingga 7 hari ke depan) lengkap dengan ikon garis minimalis serta suhu maksimum dan minimum (`max° | min°`).
   - Menampilkan detail informasi tambahan: **Suhu yang Dirasakan**, **Kelembapan**, **Kecepatan Angin**, **Curah Hujan**, dan **Peluang Hujan Maksimum**.
   - Mendukung *pull-to-refresh* serta penanganan kondisi *loading*, *data kosong*, dan *error* (dengan tombol **Coba Lagi**).
   - Drawer menu (`≡`) untuk berpindah cepat antar lokasi favorit dan mengganti satuan suhu (`°C` / `°F`).

2. **Search / Location Screen**
   - Pencarian kota secara langsung melalui **Open-Meteo Geocoding API** dengan *debounce* 450 ms.
   - Memilih hasil pencarian untuk menampilkan cuacanya di Home Screen.
   - Menyimpan dan menghapus lokasi favorit serta menampilkan **Riwayat Pencarian** yang tersimpan permanen di **SharedPreferences** (tetap tersedia saat aplikasi dibuka kembali).

---

## Struktur Aplikasi (MVVM)

```text
lib/
├── main.dart                         # Entry point & inisialisasi MultiProvider
├── theme/
│   └── app_theme.dart                # Material 3 Theme, palet gradasi, & Typography
├── models/
│   ├── location_model.dart           # Model data lokasi (Geocoding & Local Storage)
│   └── weather_model.dart            # Model data cuaca terkini & prakiraan harian
├── services/
│   ├── open_meteo_service.dart       # HTTP GET ke Open-Meteo Forecast & Geocoding API
│   └── local_storage_service.dart    # Persistensi favorit, riwayat, lokasi aktif, & unit
├── repositories/
│   └── weather_repository.dart       # Penghubung tunggal antara ViewModel & Services
├── viewmodels/
│   ├── weather_viewmodel.dart        # ChangeNotifier untuk state Home Screen
│   └── location_viewmodel.dart       # ChangeNotifier untuk pencarian, favorit, & riwayat
├── utils/
│   ├── weather_code_mapper.dart      # Pemetaan WMO weather_code ke deskripsi & tipe ikon
│   └── date_formatter.dart           # Format nama hari & konversi °C/°F
├── widgets/
│   ├── circular_outline_button.dart  # Tombol lingkaran bergaris tipis (`+` dan `≡`)
│   ├── hairline_divider.dart         # Garis pemisah horizontal halus
│   ├── minimal_weather_icon.dart     # Ikon cuaca line-art kustom (CustomPainter)
│   ├── daily_forecast_strip.dart     # Prakiraan harian 3 kolom + scroll 7 hari
│   ├── weather_details_section.dart  # Grid detail kelembapan, angin, hujan, terasa seperti
│   └── state_views.dart              # Tampilan Loading, Empty, dan Error + Retry
└── views/
    ├── home_screen.dart              # Screen 1: Home / Weather Screen (StatefulWidget)
    ├── search_location_screen.dart   # Screen 2: Search / Location Screen (StatefulWidget)
    └── menu_drawer.dart              # Drawer lokasi favorit & pengaturan satuan suhu
```

---

## Penerapan Arsitektur MVVM

- **Model (`lib/models/`)**: Merepresentasikan struktur data JSON dari API (`WeatherResponse`, `CurrentWeather`, `DailyForecast`, `LocationModel`) lengkap dengan `fromJson` dan `toJson`.
- **Service & Repository (`lib/services/`, `lib/repositories/`)**: Menangani permintaan HTTP GET (`OpenMeteoService`) dan penyimpanan lokal (`LocalStorageService`), lalu disatukan di `WeatherRepository` agar ViewModel tidak bergantung langsung pada detail implementasi jaringan atau penyimpanan.
- **ViewModel (`lib/viewmodels/`)**: `WeatherViewModel` dan `LocationViewModel` mewarisi `ChangeNotifier` (menggunakan `Provider`). Seluruh logika bisnis, transisi state (`loading`, `loaded`, `empty`, `error`), dan pemanggilan repository dikelola di sini, lalu memicu pembaruan UI melalui `notifyListeners()`.
- **View (`lib/views/`, `lib/widgets/`)**: Hanya bertugas merender tampilan berdasarkan state dari ViewModel (`context.watch<...>()`), dan meneruskan aksi pengguna ke method ViewModel (`context.read<...>()`).

---

## Implementasi API Open-Meteo

Seluruh data cuaca dan pencarian kota diambil secara langsung menggunakan `package:http` (metode **HTTP GET**):

1. **Weather Forecast API**
   ```text
   GET https://api.open-meteo.com/v1/forecast
     ?latitude={lat}
     &longitude={lon}
     &current=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m
     &daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max
     &timezone=auto
     &forecast_days=7
   ```
2. **Geocoding API**
   ```text
   GET https://geocoding-api.open-meteo.com/v1/search
     ?name={query}
     &count=10
     &language=id
     &format=json
   ```

| Data Ditampilkan | Field API Open-Meteo |
| :--- | :--- |
| Suhu saat ini | `current.temperature_2m` |
| Kelembapan | `current.relative_humidity_2m` |
| Suhu yang dirasakan | `current.apparent_temperature` |
| Curah hujan | `current.precipitation` |
| Kode kondisi cuaca | `current.weather_code` |
| Kecepatan angin | `current.wind_speed_10m` |
| Suhu maksimum harian | `daily.temperature_2m_max` |
| Suhu minimum harian | `daily.temperature_2m_min` |
| Peluang hujan maksimum | `daily.precipitation_probability_max` |

---

## Cara Menjalankan Proyek

1. Pastikan Flutter SDK (`>= 3.2.0`) sudah terpasang di perangkat Anda.
2. Ekstrak folder proyek ini, lalu buka terminal di dalam folder `flutter_weather_responsi`.
3. Jika folder platform (`android/`, `ios/`, `web/`) belum tersedia, jalankan perintah berikut untuk membuatnya tanpa menimpa folder `lib/` dan `pubspec.yaml`:
   ```bash
   flutter create .
   ```
   > **Catatan Android (Release Build):** Pastikan izin internet sudah ada di `android/app/src/main/AndroidManifest.xml`:
   > ```xml
   > <uses-permission android:name="android.permission.INTERNET" />
   > ```
4. Unduh seluruh dependensi dan jalankan aplikasi:
   ```bash
   flutter pub get
   flutter run
   ```
5. Jalankan unit test untuk memverifikasi parsing JSON:
   ```bash
   flutter test
   ```

---

## Screenshot Aplikasi

> Tambahkan hasil tangkapan layar dari emulator/perangkat Anda ke folder `screenshots/` lalu sesuaikan nama file di bawah ini sebelum dikumpulkan.

| Home / Weather Screen | Search / Location Screen | Menu Favorit & Pengaturan |
| :---: | :---: | :---: |
| ![Home Screen](screenshots/home_screen.png) | ![Search Screen](screenshots/search_screen.png) | ![Menu Drawer](screenshots/menu_drawer.png) |
