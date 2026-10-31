import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'weather_model.dart';

class WeatherException implements Exception {
  const WeatherException(this.message);
  final String message;
  @override
  String toString() => message;
}

class WeatherService {
  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  void dispose() => _client.close();

  Future<Weather> fetchWeather(String city) async {
    final trimmedCity = city.trim();
    if (trimmedCity.isEmpty) {
      throw const WeatherException('Please enter a city name.');
    }

    try {
      final geocodingUri = Uri.https(
        'geocoding-api.open-meteo.com',
        '/v1/search',
        {'name': trimmedCity, 'count': '1', 'language': 'en', 'format': 'json'},
      );
      final geocodingResponse = await _client
          .get(geocodingUri)
          .timeout(const Duration(seconds: 10));
      _ensureSuccessful(geocodingResponse, 'City search failed.');

      final geocodingData = _decodeObject(geocodingResponse.body);
      final results = geocodingData['results'];
      if (results is! List || results.isEmpty || results.first is! Map) {
        throw const WeatherException('City not found.');
      }
      final location = Map<String, dynamic>.from(results.first as Map);
      final latitude = _readDouble(location, 'latitude');
      final longitude = _readDouble(location, 'longitude');

      final weatherUri = Uri.https('api.open-meteo.com', '/v1/forecast', {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'current': 'temperature_2m,weather_code',
        'timezone': 'auto',
      });
      final weatherResponse = await _client
          .get(weatherUri)
          .timeout(const Duration(seconds: 10));
      _ensureSuccessful(weatherResponse, 'Weather fetch failed.');

      final weatherData = _decodeObject(weatherResponse.body)
        ..['cityName'] = location['name'] as String? ?? trimmedCity;
      return Weather.fromJson(weatherData);
    } on WeatherException {
      rethrow;
    } on http.ClientException {
      throw const WeatherException('Network error. Check your connection.');
    } on FormatException {
      throw const WeatherException('The server returned invalid data.');
    } on TimeoutException {
      throw const WeatherException('The request timed out. Please try again.');
    } on Exception {
      throw const WeatherException('Something went wrong. Please try again.');
    }
  }

  Future<Weather> fetchWeatherByCoordinates({
    required double latitude,
    required double longitude,
    String cityName = 'Current location',
  }) async {
    try {
      final weatherUri = Uri.https('api.open-meteo.com', '/v1/forecast', {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'current': 'temperature_2m,weather_code',
        'timezone': 'auto',
      });

      final response = await _client
          .get(weatherUri)
          .timeout(const Duration(seconds: 10));
      _ensureSuccessful(response, 'Weather fetch failed.');

      final weatherData = _decodeObject(response.body)..['cityName'] = cityName;
      return Weather.fromJson(weatherData);
    } on WeatherException {
      rethrow;
    } on http.ClientException {
      throw const WeatherException('Network error. Check your connection.');
    } on FormatException {
      throw const WeatherException('The server returned invalid data.');
    } on TimeoutException {
      throw const WeatherException('The request timed out. Please try again.');
    } on Exception {
      throw const WeatherException(
        'Unable to fetch weather for your location.',
      );
    }
  }

  void _ensureSuccessful(http.Response response, String message) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw WeatherException('$message (${response.statusCode})');
    }
  }

  Map<String, dynamic> _decodeObject(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map) throw const FormatException('Expected a JSON object.');
    return Map<String, dynamic>.from(decoded);
  }

  double _readDouble(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is num) return value.toDouble();
    throw const FormatException('Expected a numeric value.');
  }
}
