class Weather {
  const Weather({
    required this.cityName,
    required this.temperature,
    required this.weatherCode,
  });

  final String cityName;
  final double temperature;
  final int weatherCode;

  factory Weather.fromJson(Map<String, dynamic> json) {
    final current = json['current'];
    if (current is! Map) {
      throw const FormatException('Missing current weather data.');
    }
    final currentData = Map<String, dynamic>.from(current);
    final temperature = currentData['temperature_2m'];
    final weatherCode = currentData['weather_code'];
    if (temperature is! num || weatherCode is! num) {
      throw const FormatException('Invalid weather values.');
    }

    return Weather(
      cityName: json['cityName'] as String? ?? 'Unknown city',
      temperature: temperature.toDouble(),
      weatherCode: weatherCode.toInt(),
    );
  }

  String get description {
    switch (weatherCode) {
      case 0:
        return 'Clear sky';
      case 1:
      case 2:
      case 3:
        return 'Partly cloudy';
      case 45:
      case 48:
        return 'Foggy';
      case 51:
      case 53:
      case 55:
      case 56:
      case 57:
        return 'Drizzle';
      case 61:
      case 63:
      case 65:
      case 66:
      case 67:
        return 'Rain';
      case 71:
      case 73:
      case 75:
      case 77:
      case 79:
        return 'Snow';
      case 80:
      case 81:
      case 82:
        return 'Heavy rain';
      case 85:
      case 86:
        return 'Heavy snow';
      case 95:
      case 96:
      case 99:
        return 'Thunderstorm';
      default:
        return 'Current weather';
    }
  }
}
