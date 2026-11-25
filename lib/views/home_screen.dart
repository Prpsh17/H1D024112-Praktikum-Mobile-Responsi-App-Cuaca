import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/location_model.dart';
import '../models/weather_model.dart';
import '../theme/app_theme.dart';
import '../utils/date_formatter.dart';
import '../utils/weather_code_mapper.dart';
import '../viewmodels/location_viewmodel.dart';
import '../viewmodels/weather_viewmodel.dart';
import '../widgets/circular_outline_button.dart';
import '../widgets/daily_forecast_strip.dart';
import '../widgets/hairline_divider.dart';
import '../widgets/state_views.dart';
import '../widgets/weather_details_section.dart';
import 'menu_drawer.dart';
import 'search_location_screen.dart';

/// Screen 1: Home / Weather Screen
/// Menggunakan desain minimalis sesuai template UI referensi:
/// - Bar atas dengan tombol melingkar `+` (pencarian) dan `≡` (menu favorit/pengaturan)
/// - Nama kota berjarak huruf lebar + garis pemisah halus
/// - Angka suhu utama berukuran besar dengan tipografi tipis + simbol derajat melingkar
/// - Kondisi cuaca terkini + garis pemisah halus
/// - Prakiraan cuaca 3 hari terlihat (geser horizontal hingga 7 hari)
/// - Detail informasi tambahan (terasa seperti, kelembapan, angin, curah hujan, peluang hujan)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<LocationViewModel>().loadSavedLocations();
      context.read<WeatherViewModel>().initialize();
    });
  }

  Future<void> _openSearchScreen() async {
    final selectedLocation = await Navigator.of(context).push<LocationModel>(
      MaterialPageRoute(
        builder: (_) => const SearchLocationScreen(),
      ),
    );
    if (!mounted) return;
    if (selectedLocation != null) {
      await context.read<WeatherViewModel>().selectLocation(selectedLocation);
    }
  }

  @override
  Widget build(BuildContext context) {
    final weatherVm = context.watch<WeatherViewModel>();
    final locationVm = context.watch<LocationViewModel>();
    final isFav = locationVm.isFavorite(weatherVm.selectedLocation);

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: WeatherMenuDrawer(onOpenSearch: _openSearchScreen),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Bar navigasi atas sesuai template UI (`+` kiri, `≡` kanan)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircularOutlineButton(
                      icon: Icons.add,
                      tooltip: 'Cari & Tambah Lokasi',
                      onPressed: _openSearchScreen,
                    ),
                    CircularOutlineButton(
                      icon: Icons.menu,
                      tooltip: 'Menu Favorit & Pengaturan',
                      onPressed: () =>
                          _scaffoldKey.currentState?.openEndDrawer(),
                    ),
                  ],
                ),
              ),

              // Konten utama (responsif + pull-to-refresh)
              Expanded(
                child: _buildBody(weatherVm, locationVm, isFav),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    WeatherViewModel weatherVm,
    LocationViewModel locationVm,
    bool isFavorite,
  ) {
    switch (weatherVm.status) {
      case WeatherStatus.initial:
      case WeatherStatus.loading:
        return const MinimalLoadingView();

      case WeatherStatus.error:
        return MinimalErrorView(
          message:
              weatherVm.errorMessage ?? 'Gagal memuat data cuaca dari server.',
          onRetry: weatherVm.fetchWeather,
        );

      case WeatherStatus.empty:
        return const MinimalEmptyView(
          icon: Icons.cloud_queue_outlined,
          title: 'DATA CUACA KOSONG',
          subtitle: 'Tidak ada informasi cuaca untuk lokasi ini.',
        );

      case WeatherStatus.loaded:
        final weather = weatherVm.weather!;
        return RefreshIndicator(
          color: AppTheme.inkPrimary,
          backgroundColor: AppTheme.surfaceSolid,
          onRefresh: weatherVm.fetchWeather,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: _WeatherHeroContent(
              cityName: weatherVm.selectedLocation.name,
              isFavorite: isFavorite,
              onToggleFavorite: () =>
                  locationVm.toggleFavorite(weatherVm.selectedLocation),
              weather: weather,
              useFahrenheit: weatherVm.useFahrenheit,
            ),
          ),
        );
    }
  }
}

class _WeatherHeroContent extends StatelessWidget {
  final String cityName;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final WeatherResponse weather;
  final bool useFahrenheit;

  const _WeatherHeroContent({
    required this.cityName,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.weather,
    required this.useFahrenheit,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final tempText = DateFormatter.formatTemperatureValue(
      weather.current.temperature,
      useFahrenheit: useFahrenheit,
    );
    final conditionText = WeatherCodeMapper.description(
      weather.current.weatherCode,
    );

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: screenHeight - 110,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Blok utama (Nama Kota, Suhu Utama, Kondisi Cuaca, dan Prakiraan 3 Hari)
          Column(
            children: [
              const SizedBox(height: 28),

              // Nama kota + tombol simpan favorit tipis di sampingnya
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        cityName.toUpperCase(),
                        style: textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 28,
                        minHeight: 28,
                      ),
                      icon: Icon(
                        isFavorite ? Icons.star : Icons.star_border,
                        size: 18,
                        color: isFavorite
                            ? AppTheme.inkPrimary
                            : AppTheme.inkMuted,
                      ),
                      tooltip: isFavorite
                          ? 'Hapus dari favorit'
                          : 'Simpan ke favorit',
                      onPressed: onToggleFavorite,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),
              const HairlineDivider(width: 72),
              const SizedBox(height: 30),

              // Tampilan suhu hero besar tipis + lingkaran derajat halus sesuai template UI
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tempText,
                        style: textTheme.displayLarge,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 12, left: 6),
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.inkPrimary,
                              width: 1.4,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 26),

              // Kondisi cuaca terkini (uppercase berjarak huruf lebar)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  conditionText,
                  style: textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 36),
              const HairlineDivider(width: 72),
              const SizedBox(height: 34),

              // Prakiraan cuaca harian (3 kolom terlihat sesuai template UI, geser untuk 7 hari)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DailyForecastStrip(
                  forecasts: weather.daily,
                  useFahrenheit: useFahrenheit,
                ),
              ),
            ],
          ),

          // Informasi cuaca tambahan (terasa seperti, kelembapan, angin, curah hujan, peluang hujan)
          Column(
            children: [
              const SizedBox(height: 32),
              const HairlineDivider(width: 72),
              const SizedBox(height: 24),
              Text(
                'DETAIL CUACA',
                style: textTheme.bodySmall?.copyWith(
                  letterSpacing: 2.4,
                  color: AppTheme.inkMuted,
                ),
              ),
              const SizedBox(height: 16),
              WeatherDetailsSection(
                weather: weather,
                useFahrenheit: useFahrenheit,
              ),
              const SizedBox(height: 36),
            ],
          ),
        ],
      ),
    );
  }
}
