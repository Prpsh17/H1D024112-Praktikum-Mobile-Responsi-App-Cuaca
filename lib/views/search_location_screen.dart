import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/location_model.dart';
import '../theme/app_theme.dart';
import '../viewmodels/location_viewmodel.dart';
import '../widgets/circular_outline_button.dart';
import '../widgets/hairline_divider.dart';
import '../widgets/state_views.dart';

/// Screen 2: Search / Location Screen
/// - Input pencarian nama kota (melakukan HTTP GET ke Open-Meteo Geocoding API)
/// - Menampilkan daftar hasil pencarian lokasi
/// - Memilih lokasi untuk menampilkan informasi cuacanya di Home Screen
/// - Menyimpan/menghapus lokasi favorit & menampilkan riwayat pencarian (Local Storage)
class SearchLocationScreen extends StatefulWidget {
  const SearchLocationScreen({super.key});

  @override
  State<SearchLocationScreen> createState() => _SearchLocationScreenState();
}

class _SearchLocationScreenState extends State<SearchLocationScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final vm = context.read<LocationViewModel>();
      vm.clearSearch();
      vm.loadSavedLocations();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      context.read<LocationViewModel>().searchCities(value);
    });
  }

  void _onSubmitted(String value) {
    _debounce?.cancel();
    context.read<LocationViewModel>().searchCities(value);
  }

  Future<void> _selectCity(LocationModel city) async {
    await context.read<LocationViewModel>().addToHistory(city);
    if (!mounted) return;
    Navigator.of(context).pop(city);
  }

  @override
  Widget build(BuildContext context) {
    final locationVm = context.watch<LocationViewModel>();
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header minimalis konsisten dengan HomeScreen
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Row(
                  children: [
                    CircularOutlineButton(
                      icon: Icons.arrow_back,
                      tooltip: 'Kembali',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Text(
                        'LOKASI',
                        style: textTheme.headlineMedium?.copyWith(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 42),
                  ],
                ),
              ),

              // Kolom input pencarian kota
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onChanged: (value) {
                    setState(() {});
                    _onSearchChanged(value);
                  },
                  onSubmitted: _onSubmitted,
                  style: textTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'Cari nama kota (misal: Semarang, Tokyo)...',
                    prefixIcon: const Icon(
                      Icons.search,
                      size: 20,
                      color: AppTheme.inkMuted,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.close,
                              size: 18,
                              color: AppTheme.inkMuted,
                            ),
                            tooltip: 'Hapus pencarian',
                            onPressed: () {
                              _debounce?.cancel();
                              _searchController.clear();
                              setState(() {});
                              context.read<LocationViewModel>().clearSearch();
                            },
                          )
                        : null,
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const HairlineDivider(width: 72),
              const SizedBox(height: 12),

              // Area hasil pencarian atau daftar favorit & riwayat pencarian
              Expanded(
                child: _buildContent(locationVm),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(LocationViewModel vm) {
    switch (vm.searchStatus) {
      case SearchStatus.loading:
        return const MinimalLoadingView(message: 'MENCARI KOTA...');

      case SearchStatus.error:
        return MinimalErrorView(
          message: vm.errorMessage ?? 'Gagal mengambil data lokasi.',
          onRetry: () => vm.searchCities(_searchController.text),
        );

      case SearchStatus.empty:
        return MinimalEmptyView(
          icon: Icons.location_off_outlined,
          title: 'KOTA TIDAK DITEMUKAN',
          subtitle:
              'Tidak ada hasil untuk "${vm.lastQuery}". Coba kata kunci lain.',
        );

      case SearchStatus.loaded:
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          physics: const BouncingScrollPhysics(),
          itemCount: vm.searchResults.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final city = vm.searchResults[index];
            return _LocationCard(
              location: city,
              isFavorite: vm.isFavorite(city),
              onTap: () => _selectCity(city),
              onToggleFavorite: () => vm.toggleFavorite(city),
            );
          },
        );

      case SearchStatus.idle:
        return _SavedLocationsSection(
          favorites: vm.favorites,
          history: vm.searchHistory,
          isFavorite: vm.isFavorite,
          onSelect: _selectCity,
          onToggleFavorite: vm.toggleFavorite,
          onRemoveHistory: vm.removeFromHistory,
          onClearHistory: vm.clearHistory,
        );
    }
  }
}

class _SavedLocationsSection extends StatelessWidget {
  final List<LocationModel> favorites;
  final List<LocationModel> history;
  final bool Function(LocationModel) isFavorite;
  final ValueChanged<LocationModel> onSelect;
  final ValueChanged<LocationModel> onToggleFavorite;
  final ValueChanged<LocationModel> onRemoveHistory;
  final VoidCallback onClearHistory;

  const _SavedLocationsSection({
    required this.favorites,
    required this.history,
    required this.isFavorite,
    required this.onSelect,
    required this.onToggleFavorite,
    required this.onRemoveHistory,
    required this.onClearHistory,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (favorites.isEmpty && history.isEmpty) {
      return const MinimalEmptyView(
        icon: Icons.travel_explore_outlined,
        title: 'CARI KOTA',
        subtitle:
            'Ketik nama kota di atas untuk melihat cuaca, menyimpan favorit, atau mencatat riwayat pencarian.',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      physics: const BouncingScrollPhysics(),
      children: [
        if (favorites.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 4),
            child: Text(
              'LOKASI FAVORIT',
              style: textTheme.bodySmall?.copyWith(
                letterSpacing: 2.2,
                color: AppTheme.inkMuted,
              ),
            ),
          ),
          ...favorites.map(
            (city) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _LocationCard(
                location: city,
                isFavorite: true,
                onTap: () => onSelect(city),
                onToggleFavorite: () => onToggleFavorite(city),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (history.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 6, left: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'RIWAYAT PENCARIAN',
                  style: textTheme.bodySmall?.copyWith(
                    letterSpacing: 2.2,
                    color: AppTheme.inkMuted,
                  ),
                ),
                TextButton(
                  onPressed: onClearHistory,
                  child: Text(
                    'HAPUS SEMUA',
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      letterSpacing: 1.4,
                      color: AppTheme.inkSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...history.map(
            (city) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _LocationCard(
                location: city,
                isFavorite: isFavorite(city),
                onTap: () => onSelect(city),
                onToggleFavorite: () => onToggleFavorite(city),
                onRemoveHistory: () => onRemoveHistory(city),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _LocationCard extends StatelessWidget {
  final LocationModel location;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final VoidCallback? onRemoveHistory;

  const _LocationCard({
    required this.location,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFavorite,
    this.onRemoveHistory,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: AppTheme.surfaceCard,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.hairline,
              width: 0.8,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 20,
                color: AppTheme.inkSecondary,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location.name.toUpperCase(),
                      style: textTheme.labelLarge?.copyWith(
                        letterSpacing: 2.0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${location.subtitle}  •  ${location.latitude.toStringAsFixed(2)}, ${location.longitude.toStringAsFixed(2)}',
                      style: textTheme.bodySmall?.copyWith(fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.star : Icons.star_border,
                  size: 20,
                  color: isFavorite ? AppTheme.inkPrimary : AppTheme.inkMuted,
                ),
                tooltip: isFavorite
                    ? 'Hapus dari favorit'
                    : 'Simpan sebagai favorit',
                onPressed: onToggleFavorite,
              ),
              if (onRemoveHistory != null)
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    size: 18,
                    color: AppTheme.inkMuted,
                  ),
                  tooltip: 'Hapus dari riwayat',
                  onPressed: onRemoveHistory,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
