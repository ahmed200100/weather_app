import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'weather_provider.dart';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: ChangeNotifierProvider(
        create: (_) => WeatherProvider(),
        child: const WeatherHomeScreen(),
      ),
    );
  }
}

class WeatherHomeScreen extends StatefulWidget {
  const WeatherHomeScreen({super.key});

  @override
  State<WeatherHomeScreen> createState() => _WeatherHomeScreenState();
}

class _WeatherHomeScreenState extends State<WeatherHomeScreen> {
  final TextEditingController _cityController = TextEditingController();

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, provider, child) => Scaffold(
        appBar: AppBar(title: const Text('Weather App'), centerTitle: true),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: 'City',
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) =>
                          provider.searchWeather(_cityController.text),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: provider.isLoading
                        ? null
                        : () => provider.searchWeather(_cityController.text),
                    icon: const Icon(Icons.search),
                    tooltip: 'Search',
                  ),
                  IconButton(
                    onPressed: provider.isLoading
                        ? null
                        : provider.searchWeatherByCurrentLocation,
                    icon: const Icon(Icons.my_location),
                    tooltip: 'My Location',
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Expanded(child: _buildContent(context, provider)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WeatherProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.errorMessage != null) {
      return Center(
        child: Text(
          'Error: ${provider.errorMessage}',
          textAlign: TextAlign.center,
        ),
      );
    }
    if (provider.weather == null) {
      return const Center(child: Text('Search for a city to see its weather.'));
    }

    final weather = provider.weather!;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                weather.cityName,
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Icon(
                _iconForCode(weather.weatherCode),
                size: 72,
                color: Colors.orange,
              ),
              const SizedBox(height: 16),
              Text(
                '${weather.temperature.toStringAsFixed(1)}°C',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                weather.description,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForCode(int code) {
    if (code == 0) return Icons.wb_sunny;
    if (code <= 3) return Icons.cloud;
    if (code <= 48) return Icons.foggy;
    if (code <= 67 || (code >= 80 && code <= 82)) return Icons.umbrella;
    if (code <= 79 || (code >= 85 && code <= 86)) return Icons.ac_unit;
    return Icons.thunderstorm;
  }
}
