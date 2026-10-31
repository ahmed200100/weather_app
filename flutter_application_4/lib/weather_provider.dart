import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import 'weather_model.dart';
import 'weather_service.dart';

class WeatherProvider extends ChangeNotifier {
  WeatherProvider({WeatherService? service})
    : _service = service ?? WeatherService();

  final WeatherService _service;

  Weather? _weather;
  String? _errorMessage;
  bool _isLoading = false;

  Weather? get weather => _weather;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  Future<void> searchWeather(String city) async {
    final trimmedCity = city.trim();
    if (trimmedCity.isEmpty || _isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _weather = await _service.fetchWeather(trimmedCity);
    } on WeatherException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Something went wrong. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchWeatherByCurrentLocation() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final position = await _getCurrentPosition();
      _weather = await _service.fetchWeatherByCoordinates(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } on WeatherException catch (error) {
      _errorMessage = error.message;
    } on LocationServiceDisabledException {
      _errorMessage = 'Location services are disabled.';
    } on PermissionDeniedException {
      _errorMessage = 'Location permission was denied.';
    } on TimeoutException {
      _errorMessage = 'Unable to determine your location in time.';
    } catch (_) {
      _errorMessage = 'Unable to get your current location.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Position> _getCurrentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationServiceDisabledException();
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw const PermissionDeniedException('Location permission was denied.');
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}
