import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

/// Configuration and environment settings for RentBD application.
/// Allows instant toggling between realistic Mock Data and live Django REST Framework API.
class AppEnvironment {
  AppEnvironment._();

  /// When [useMockData] is true, repositories will route calls through
  /// MockDataSources with realistic simulated latency and rich Dhaka real estate data.
  /// When false, repositories interact directly with the Django REST Framework backend.
  static bool useMockData = false;

  /// Optional custom base URL override (e.g. for testing on physical devices via LAN)
  static String? customBaseUrl;

  /// Default Django REST API Base URL
  /// For Android Emulator: 10.0.2.2:8000
  /// For iOS Simulator / Web / Real Device: 127.0.0.1:8000 or custom host
  static String get baseUrl {
    if (customBaseUrl != null && customBaseUrl!.isNotEmpty) {
      return customBaseUrl!;
    }
    if (kIsWeb) return 'http://127.0.0.1:8000/api/v1';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8000/api/v1';
    } catch (_) {}
    return 'http://127.0.0.1:8000/api/v1';
  }

  /// Network timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  /// Simulated network latency for mock data sources
  static Duration mockDelay = const Duration(milliseconds: 650);

  /// Default currency code and symbol for Bangladesh
  static const String currencyCode = 'BDT';
  static const String currencySymbol = '৳';

  /// Standard Dhaka center coordinates
  static const double defaultDhakaLat = 23.8103;
  static const double defaultDhakaLng = 90.4125;
}
