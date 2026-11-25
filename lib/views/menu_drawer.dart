import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/location_model.dart';
import '../theme/app_theme.dart';
import '../viewmodels/location_viewmodel.dart';
import '../viewmodels/weather_viewmodel.dart';

/// Drawer samping kanan yang dibuka melalui tombol menu (`≡`) pada Home Screen.
/// Memungkinkan pengguna berpindah cepat antar lokasi favorit serta mengubah satuan suhu (°C / °F).
class WeatherMenuDrawer extends StatelessWidget {
  final VoidCallback onOpenSearch;

  const WeatherMenuDrawer({
    super.key,
    required this.onOpenSearch,
  });

  @override
  Widget build(BuildContext context) {
    final weatherVm = context.watch<WeatherViewModel>();
    final locationVm = context.watch<LocationViewModel>();
    final textTheme = Theme.of(context).textTheme;

    return Drawer(
      backgroundColor: AppTheme.surfaceSolid,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(left: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'PENGATURAN',
                    style: textTheme.labelLarge?.copyWith(
                      letterSpacing: 2.6,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 12),

              // Pilihan satuan suhu (°C / °F)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SATUAN SUHU',
                    style: textTheme.bodySmall?.copyWith(
                      letterSpacing: 1.8,
                      color: AppTheme.inkSecondary,
                    ),
                  ),
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment<bool>(value: false, label: Text('°C')),
                      ButtonSegment<bool>(value: true, label: Text('°F')),
                    ],
                    selected: {weatherVm.useFahrenheit},
                    onSelectionChanged: (selection) {
                      if (selection.first != weatherVm.useFahrenheit) {
                        weatherVm.toggleTemperatureUnit();
                      }
                    },
                    showSelectedIcon: false,
                    style: SegmentedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      side: const BorderSide(color: AppTheme.hairline),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'LOKASI FAVORIT',
                    style: textTheme.bodySmall?.copyWith(
                      letterSpacing: 1.8,
                      color: AppTheme.inkSecondary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onOpenSearch();
                    },
                    child: Text(
                      '+ TAMBAH',
                      style: textTheme.bodySmall?.copyWith(
                        letterSpacing: 1.5,
                        color: AppTheme.inkPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              Expanded(
                child: locationVm.favorites.isEmpty
                    ? Center(
                        child: Text(
                          'Belum ada lokasi favorit.\nTambahkan kota dari menu pencarian.',
                          style: textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.separated(
                        itemCount: locationVm.favorites.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final city = locationVm.favorites[index];
                          final isSelected =
                              city == weatherVm.selectedLocation;
                          return _FavoriteDrawerTile(
                            city: city,
                            isSelected: isSelected,
                            onTap: () {
                              Navigator.of(context).pop();
                              weatherVm.selectLocation(city);
                            },
                            onRemove: () => locationVm.toggleFavorite(city),
                          );
                        },
                      ),
              ),

              const Divider(),
              const SizedBox(height: 12),
              Text(
                'Sumber Data: Open-Meteo API',
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: AppTheme.inkMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavoriteDrawerTile extends StatelessWidget {
  final LocationModel city;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _FavoriteDrawerTile({
    required this.city,
    required this.isSelected,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      title: Text(
        city.name.toUpperCase(),
        style: textTheme.labelLarge?.copyWith(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          letterSpacing: 2.0,
        ),
      ),
      subtitle: Text(
        city.subtitle,
        style: textTheme.bodySmall?.copyWith(fontSize: 11),
      ),
      trailing: IconButton(
        icon: const Icon(
          Icons.bookmark_remove_outlined,
          size: 18,
          color: AppTheme.inkMuted,
        ),
        tooltip: 'Hapus dari favorit',
        onPressed: onRemove,
      ),
      onTap: onTap,
    );
  }
}
