import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:etbp_mobile/screens/splash/splash_screen.dart';
import 'package:etbp_mobile/screens/onboarding/onboarding_screen.dart';
import 'package:etbp_mobile/screens/auth/login_screen.dart';
import 'package:etbp_mobile/screens/auth/register_screen.dart';
import 'package:etbp_mobile/screens/home/home_screen.dart';
import 'package:etbp_mobile/screens/search/search_results_screen.dart';
import 'package:etbp_mobile/screens/booking/seat_selection_screen.dart';
import 'package:etbp_mobile/screens/booking/passenger_details_screen.dart';
import 'package:etbp_mobile/screens/booking/review_screen.dart';
import 'package:etbp_mobile/screens/booking/payment_webview_screen.dart';
import 'package:etbp_mobile/screens/booking/confirmation_screen.dart';
import 'package:etbp_mobile/screens/trips/my_trips_screen.dart';
import 'package:etbp_mobile/screens/trips/trip_detail_screen.dart';
import 'package:etbp_mobile/screens/wallet/wallet_screen.dart';
import 'package:etbp_mobile/screens/profile/profile_screen.dart';
import 'package:etbp_mobile/screens/support/support_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (_, __, child) => ScaffoldWithNav(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/my-trips', builder: (_, __) => const MyTripsScreen()),
          GoRoute(path: '/wallet', builder: (_, __) => const WalletScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        ],
      ),
      GoRoute(
        path: '/search',
        builder: (_, state) => SearchResultsScreen(
          origin: state.uri.queryParameters['origin'] ?? '',
          destination: state.uri.queryParameters['destination'] ?? '',
          date: state.uri.queryParameters['date'] ?? '',
          passengers: state.uri.queryParameters['passengers'] ?? '1',
        ),
      ),
      GoRoute(path: '/trips/:id', builder: (_, state) => SeatSelectionScreen(tripId: state.pathParameters['id']!)),
      GoRoute(path: '/booking/passengers', builder: (_, __) => const PassengerDetailsScreen()),
      GoRoute(path: '/booking/review', builder: (_, __) => const ReviewScreen()),
      GoRoute(path: '/booking/payment', builder: (_, state) => PaymentWebViewScreen(url: state.uri.queryParameters['url'] ?? '', bookingRef: state.uri.queryParameters['ref'] ?? '')),
      GoRoute(path: '/booking/confirmation', builder: (_, state) => ConfirmationScreen(ref: state.uri.queryParameters['ref'] ?? '')),
      GoRoute(path: '/my-trips/:ref', builder: (_, state) => TripDetailScreen(ref: state.pathParameters['ref']!)),
      GoRoute(path: '/support', builder: (_, __) => const SupportScreen()),
    ],
  );
});

class ScaffoldWithNav extends StatelessWidget {
  final Widget child;
  const ScaffoldWithNav({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculateIndex(GoRouterState.of(context).uri.path),
        onTap: (i) => _onTap(context, i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.confirmation_number_outlined), activeIcon: Icon(Icons.confirmation_number), label: 'My Trips'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), activeIcon: Icon(Icons.account_balance_wallet), label: 'Wallet'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  int _calculateIndex(String path) {
    if (path.startsWith('/my-trips')) return 1;
    if (path.startsWith('/wallet')) return 2;
    if (path.startsWith('/profile')) return 3;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0: context.go('/home');
      case 1: context.go('/my-trips');
      case 2: context.go('/wallet');
      case 3: context.go('/profile');
    }
  }
}
