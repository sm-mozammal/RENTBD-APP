import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/service_locator.dart';
import 'core/network/token_manager.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/bari_crash_recovery.dart';
import 'core/widgets/chucker_floating_button.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/communication_ledger/domain/repositories/chat_repository.dart';
import 'features/communication_ledger/domain/repositories/ledger_repository.dart';
import 'features/location/domain/repositories/insight_repository.dart';
import 'features/property/domain/repositories/property_repository.dart';
import 'features/property/presentation/bloc/property_bloc.dart';
import 'features/property/presentation/bloc/property_event.dart';
import 'features/visit/domain/repositories/visit_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Global Error Boundary 1: Catch framework errors without crashing
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };

  // Global Error Boundary 2: Catch unhandled asynchronous errors
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('RentBD Unhandled Async Exception Caught: $error');
    return true; // Prevents process crash
  };

  // Global Error Boundary 3: Replace Red Screen of Death with user-friendly recovery UI
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return BariCrashRecoveryWidget(errorDetails: details);
  };

  // Configure Chucker API Inspector (active in debug mode only)
  ChuckerFlutter.showOnRelease = false;
  ChuckerFlutter.showNotification = false;

  // Initialize secure session tokens & user credentials from storage
  await TokenManager.init();

  // Initialize all Clean Architecture layers via GetIt Service Locator
  await ServiceLocator.init();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: sl<AuthRepository>()),
        RepositoryProvider<PropertyRepository>.value(value: sl<PropertyRepository>()),
        RepositoryProvider<VisitRepository>.value(value: sl<VisitRepository>()),
        RepositoryProvider<InsightRepository>.value(value: sl<InsightRepository>()),
        RepositoryProvider<LedgerRepository>.value(value: sl<LedgerRepository>()),
        RepositoryProvider<ChatRepository>.value(value: sl<ChatRepository>()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (_) => sl<AuthBloc>()..add(const CheckAuthStatusEvent()),
          ),
          BlocProvider<PropertyBloc>(
            create: (_) => sl<PropertyBloc>()..add(const FetchPropertiesEvent()),
          ),
        ],
        child: const RentBdApp(),
      ),
    ),
  );
}

class RentBdApp extends StatelessWidget {
  const RentBdApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'RentBD',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: AppRouter.router,
      builder: (context, child) => ChuckerFloatingButton(child: child),
    );
  }
}

/// Backwards compatibility alias
typedef BariBaraApp = RentBdApp;
