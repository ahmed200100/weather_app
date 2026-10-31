# 🌤️ Flutter Weather App

A professional, clean-architecture weather application built with Flutter, utilizing real-time data from the Open-Meteo API.

## 🚀 Features
- **Clean Architecture & Separation of Concerns:** Organized into distinct layers (`Models`, `Services`, `Providers`, and `UI`).
- **State Management:** Powered by the `Provider` package (`ChangeNotifier`) for reactive and clean state handling.
- **Dynamic Weather Icons:** Automatically maps weather codes to descriptive icons and descriptions.
- **Location-Based Weather:** Supports fetching weather data via GPS coordinates (`geolocator`) as well as manual city search.
- **Robust Error Handling:** Handles network failures, empty inputs, and missing location permissions gracefully.

## 📂 Project Structure
```text
lib/
│
├── models/
│   └── weather_model.dart        # Data model and JSON parsing
│
├── services/
│   └── weather_service.dart      # API integration (Open-Meteo & Geocoding)
│
├── providers/
│   └── weather_provider.dart     # State management using Provider
│
└── main.dart                     # UI screens and entry point

ech Stack & Packages
Framework: Flutter (Dart)

State Management: provider

Networking: http

Location Services: geolocator

API: Open-Meteo API (Free & No API Key required)
git clone [https://github.com/YOUR_USERNAME/weather-app.git](https://github.com/YOUR_USERNAME/weather-app.git)