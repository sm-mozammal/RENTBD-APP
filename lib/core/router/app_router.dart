import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/screens/kyc_verification_screen.dart';
import '../../features/auth/presentation/screens/login_otp_screen.dart';
import '../../features/auth/presentation/screens/profile_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/verify_profile_screen.dart';
import '../../features/communication_ledger/presentation/screens/ai_rent_agreement_screen.dart';
import '../../features/communication_ledger/presentation/screens/chat_room_screen.dart';
import '../../features/communication_ledger/presentation/screens/digital_ledger_screen.dart';
import '../../features/landlord/presentation/screens/property_vault_screen.dart';
import '../../features/landlord/presentation/screens/quick_post_screen.dart';
import '../../features/landlord/presentation/screens/tenant_screening_screen.dart';
import '../../features/location/presentation/screens/commute_calculator_screen.dart';
import '../../features/location/presentation/screens/map_search_screen.dart';
import '../../features/property/presentation/screens/home_screen.dart';
import '../../features/property/presentation/screens/move_in_calculator_screen.dart';
import '../../features/property/presentation/screens/property_comparison_screen.dart';
import '../../features/property/domain/entities/property.dart';
import '../../features/property/presentation/screens/property_detail_screen.dart';
import '../../features/property/presentation/screens/saved_properties_screen.dart';
import '../../features/visit/presentation/screens/visit_scheduler_screen.dart';
import '../network/token_manager.dart';
import '../theme/app_colors.dart';
import 'route_names.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = ChuckerFlutter.navigatorKey;
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

/// Centralized GoRouter configuration with ShellRoute Bottom Navigation and Auth Route Guarding.
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: TokenManager.authChangeNotifier,
    redirect: (context, state) {
      final isAuthenticated = TokenManager.hasToken;
      final isLandlord = TokenManager.isLandlord;
      final location = state.matchedLocation;

      final isAuthRoute = location == '/auth/login' || location == '/auth/register';

      // 1. If already authenticated and visiting login or register, redirect to home or landlord vault
      if (isAuthenticated && isAuthRoute) {
        return isLandlord ? '/landlord/vault' : '/';
      }

      // 2. Protected routes requiring authentication
      final isProtectedRoute = location.startsWith('/post') ||
          location.startsWith('/landlord/vault') ||
          location.startsWith('/landlord/tenant-screening') ||
          location.startsWith('/auth/kyc') ||
          location.startsWith('/auth/verify-profile') ||
          location.startsWith('/agreement') ||
          location.startsWith('/chat');

      if (!isAuthenticated && isProtectedRoute) {
        return '/auth/login';
      }

      // 3. Role enforcement: Non-landlord trying to access landlord vault or tenant screening
      if (isAuthenticated && !isLandlord && (location.startsWith('/landlord/vault') || location.startsWith('/landlord/tenant-screening'))) {
        return '/';
      }

      // 4. When authenticated landlord lands on '/', navigate them to their Landlord Vault
      if (isAuthenticated && isLandlord && location == '/') {
        return '/landlord/vault';
      }

      return null;
    },
    routes: [
      // Bottom Navigation Shell
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return _ScaffoldWithNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            name: RouteNames.home,
            pageBuilder: (context, state) => const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: '/saved',
            name: RouteNames.saved,
            pageBuilder: (context, state) => const NoTransitionPage(child: SavedPropertiesScreen()),
          ),
          GoRoute(
            path: '/post',
            name: RouteNames.quickPost,
            pageBuilder: (context, state) => const NoTransitionPage(child: QuickPostScreen()),
          ),
          GoRoute(
            path: '/visits',
            name: RouteNames.visits,
            pageBuilder: (context, state) => const NoTransitionPage(child: VisitSchedulerScreen()),
          ),
          GoRoute(
            path: '/ledger',
            name: RouteNames.digitalLedger,
            pageBuilder: (context, state) => const NoTransitionPage(child: DigitalLedgerScreen()),
          ),
          GoRoute(
            path: '/landlord/vault',
            name: RouteNames.propertyVault,
            pageBuilder: (context, state) => const NoTransitionPage(child: PropertyVaultScreen()),
          ),
          GoRoute(
            path: '/landlord/tenant-screening',
            name: RouteNames.tenantScreening,
            pageBuilder: (context, state) => const NoTransitionPage(child: TenantScreeningScreen()),
          ),
          GoRoute(
            path: '/profile',
            name: RouteNames.profile,
            pageBuilder: (context, state) => const NoTransitionPage(child: ProfileScreen()),
          ),
        ],
      ),

      // Auth routes
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/auth/login',
        name: RouteNames.login,
        builder: (context, state) => const LoginOtpScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/auth/register',
        name: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/auth/verify-profile',
        name: RouteNames.verifyProfile,
        builder: (context, state) => const VerifyProfileScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/auth/kyc',
        name: RouteNames.kycVerification,
        builder: (context, state) => const KycVerificationScreen(),
      ),

      // Property Subroutes
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/property/:id',
        name: RouteNames.propertyDetail,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          final property = state.extra is Property ? state.extra as Property : null;
          return PropertyDetailScreen(
            propertyId: id,
            initialProperty: property,
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/property/:id/calculator',
        name: RouteNames.moveInCalculator,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return MoveInCalculatorScreen(propertyId: id);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/compare',
        name: RouteNames.compare,
        builder: (context, state) => const PropertyComparisonScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/map-search',
        name: RouteNames.mapSearch,
        builder: (context, state) => const MapSearchScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/commute-calc',
        name: RouteNames.commuteCalculator,
        builder: (context, state) => const CommuteCalculatorScreen(),
      ),

      // Communication & Agreements
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/chat/:id',
        name: RouteNames.chatRoom,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return ChatRoomScreen(chatId: id);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/agreement/:propertyId',
        name: RouteNames.rentAgreement,
        builder: (context, state) {
          final id = state.pathParameters['propertyId'] ?? '';
          return AiRentAgreementScreen(propertyId: id);
        },
      ),
    ],
  );
}

class _ScaffoldWithNavBar extends StatelessWidget {
  const _ScaffoldWithNavBar({required this.child});
  final Widget child;

  int _calculateSelectedIndex(BuildContext context, bool isLandlord) {
    final location = GoRouterState.of(context).uri.toString();

    if (isLandlord) {
      if (location.startsWith('/landlord/vault')) return 0;
      if (location.startsWith('/post')) return 1;
      if (location.startsWith('/landlord/tenant-screening')) return 2;
      if (location.startsWith('/ledger')) return 3;
      if (location.startsWith('/profile')) return 4;
      return 0;
    } else {
      if (location == '/' || location.startsWith('/home')) return 0;
      if (location.startsWith('/saved')) return 1;
      if (location.startsWith('/visits')) return 2;
      if (location.startsWith('/ledger')) return 3;
      if (location.startsWith('/profile')) return 4;
      return 0;
    }
  }

  void _onItemTapped(int index, BuildContext context, bool isLandlord) {
    if (isLandlord) {
      switch (index) {
        case 0:
          context.goNamed(RouteNames.propertyVault);
          break;
        case 1:
          context.goNamed(RouteNames.quickPost);
          break;
        case 2:
          context.goNamed(RouteNames.tenantScreening);
          break;
        case 3:
          context.goNamed(RouteNames.digitalLedger);
          break;
        case 4:
          context.goNamed(RouteNames.profile);
          break;
      }
    } else {
      switch (index) {
        case 0:
          context.goNamed(RouteNames.home);
          break;
        case 1:
          context.goNamed(RouteNames.saved);
          break;
        case 2:
          context.goNamed(RouteNames.visits);
          break;
        case 3:
          context.goNamed(RouteNames.digitalLedger);
          break;
        case 4:
          context.goNamed(RouteNames.profile);
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final isLandlord = authState is Authenticated && authState.user.isLandlord;
    final currentIndex = _calculateSelectedIndex(context, isLandlord);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (idx) => _onItemTapped(idx, context, isLandlord),
        selectedItemColor: isLandlord ? AppColors.primaryDark : AppColors.primary,
        unselectedItemColor: AppColors.lightTextMuted,
        type: BottomNavigationBarType.fixed,
        items: isLandlord
            ? const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.inventory_2_outlined),
                  activeIcon: Icon(Icons.inventory_2_rounded),
                  label: 'Vault',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.add_circle_outline_rounded),
                  activeIcon: Icon(Icons.add_circle_rounded),
                  label: 'Quick Post',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people_outline_rounded),
                  activeIcon: Icon(Icons.people_rounded),
                  label: 'Screening',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long_outlined),
                  activeIcon: Icon(Icons.receipt_long_rounded),
                  label: 'Collection',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline_rounded),
                  activeIcon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ]
            : const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.search_rounded),
                  activeIcon: Icon(Icons.saved_search_rounded),
                  label: 'Explore',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite_border_rounded),
                  activeIcon: Icon(Icons.favorite_rounded),
                  label: 'Saved',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today_outlined),
                  activeIcon: Icon(Icons.calendar_today_rounded),
                  label: 'Visits',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long_outlined),
                  activeIcon: Icon(Icons.receipt_long_rounded),
                  label: 'Rent Ledger',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline_rounded),
                  activeIcon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
      ),
    );
  }
}
