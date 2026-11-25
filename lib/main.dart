import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'repositories/weather_repository.dart';
import 'services/local_storage_service.dart';
import 'services/open_meteo_service.dart';
import 'theme/app_theme.dart';
import 'viewmodels/location_viewmodel.dart';
import 'viewmodels/weather_viewmodel.dart';
import 'views/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  final repository = WeatherRepository(
    apiService: OpenMeteoService(),
    storageService: LocalStorageService(),
  );

  runApp(WeatherResponsiApp(repository: repository));
}

class WeatherResponsiApp extends StatelessWidget {
  final WeatherRepository repository;

  const WeatherResponsiApp({
    super.key,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<WeatherViewModel>(
          create: (_) => WeatherViewModel(repository: repository),
        ),
        ChangeNotifierProvider<LocationViewModel>(
          create: (_) => LocationViewModel(repository: repository),
        ),
      ],
      child: MaterialApp(
        title: 'Minimalist Weather',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
