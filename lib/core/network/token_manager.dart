import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Notifier that alerts GoRouter and UI of authentication state mutations.
class AuthChangeNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

/// Centralized Token & Session Manager for RentBD.
/// Persists JWT Access, Refresh tokens, User ID, and User Role securely via FlutterSecureStorage
/// while caching them in-memory for zero-latency synchronous access across DioClient and UI.
class TokenManager {
  TokenManager._();

  static const String _keyAccessToken = 'rentbd_access_token';
  static const String _keyRefreshToken = 'rentbd_refresh_token';
  static const String _keyUserId = 'rentbd_user_id';
  static const String _keyUserRole = 'rentbd_user_role';
  static const String _keyUserProfile = 'rentbd_user_profile';

  static FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  /// Visible for testing to inject mock storage
  @visibleForTesting
  static void setStorage(FlutterSecureStorage storage) {
    _storage = storage;
  }

  static String? _accessToken;
  static String? _refreshToken;
  static String? _userId;
  static String? _userRole;
  static String? _cachedUserProfileJson;

  /// Reactive listenable for GoRouter refresh and auth changes
  static final AuthChangeNotifier authChangeNotifier = AuthChangeNotifier();

  /// Retrieves the active JWT Access Token
  static String? get accessToken => _accessToken;

  /// Retrieves the active JWT Refresh Token
  static String? get refreshToken => _refreshToken;

  /// Retrieves the active User ID
  static String? get userId => _userId;

  /// Retrieves the active User Role ('tenant', 'landlord', 'dual')
  static String? get userRole => _userRole;

  /// Retrieves cached raw user profile JSON string
  static String? get cachedUserProfileJson => _cachedUserProfileJson;

  /// Checks if an active token exists
  static bool get hasToken => _accessToken != null && _accessToken!.isNotEmpty;

  /// True if current user is Landlord or Dual
  static bool get isLandlord =>
      _userRole?.toLowerCase() == 'landlord' || _userRole?.toLowerCase() == 'dual';

  /// True if current user is Tenant
  static bool get isTenant =>
      _userRole?.toLowerCase() == 'tenant' || _userRole?.toLowerCase() == 'dual';

  static bool get _isBindingReady {
    try {
      if (Platform.environment.containsKey('FLUTTER_TEST')) {
        return false;
      }
      WidgetsBinding.instance;
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Initializes session tokens and user data from SecureStorage on app launch
  static Future<void> init() async {
    if (!_isBindingReady) return;
    try {
      _accessToken = await _storage.read(key: _keyAccessToken);
      _refreshToken = await _storage.read(key: _keyRefreshToken);
      _userId = await _storage.read(key: _keyUserId);
      _userRole = await _storage.read(key: _keyUserRole);
      _cachedUserProfileJson = await _storage.read(key: _keyUserProfile);
      authChangeNotifier.notify();
    } catch (e) {
      debugPrint('TokenManager.init storage read warning: $e');
    }
  }

  /// Sets and securely persists the full user session
  static Future<void> saveSession({
    required String access,
    String? refresh,
    String? userId,
    String? userRole,
    Map<String, dynamic>? userJson,
  }) async {
    _accessToken = access;
    if (refresh != null && refresh.isNotEmpty) {
      _refreshToken = refresh;
    }
    if (userId != null && userId.isNotEmpty) {
      _userId = userId;
    }
    if (userRole != null && userRole.isNotEmpty) {
      _userRole = userRole;
    }
    if (userJson != null) {
      _cachedUserProfileJson = jsonEncode(userJson);
    }

    authChangeNotifier.notify();

    if (!_isBindingReady) return;

    try {
      await _storage.write(key: _keyAccessToken, value: access);
      if (refresh != null && refresh.isNotEmpty) {
        await _storage.write(key: _keyRefreshToken, value: refresh);
      }
      if (userId != null && userId.isNotEmpty) {
        await _storage.write(key: _keyUserId, value: userId);
      }
      if (userRole != null && userRole.isNotEmpty) {
        await _storage.write(key: _keyUserRole, value: userRole);
      }
      if (_cachedUserProfileJson != null) {
        await _storage.write(key: _keyUserProfile, value: _cachedUserProfileJson);
      }
    } catch (e) {
      debugPrint('TokenManager.saveSession storage write warning: $e');
    }
  }

  /// Sets active JWT tokens (backwards compatible)
  static void setTokens({required String access, String? refresh}) {
    _accessToken = access;
    if (refresh != null && refresh.isNotEmpty) {
      _refreshToken = refresh;
    }
    authChangeNotifier.notify();
    if (!_isBindingReady) return;
    try {
      _storage.write(key: _keyAccessToken, value: access).catchError((_) {});
      if (refresh != null && refresh.isNotEmpty) {
        _storage.write(key: _keyRefreshToken, value: refresh).catchError((_) {});
      }
    } catch (_) {}
  }

  /// Clears all tokens and session data on sign out
  static Future<void> clear() async {
    _accessToken = null;
    _refreshToken = null;
    _userId = null;
    _userRole = null;
    _cachedUserProfileJson = null;
    authChangeNotifier.notify();

    if (!_isBindingReady) return;

    try {
      await _storage.deleteAll();
    } catch (e) {
      debugPrint('TokenManager.clear storage delete warning: $e');
    }
  }
}
