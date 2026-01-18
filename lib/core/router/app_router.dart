import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../di/providers.dart';
import '../utils/animation_utils.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/search/search_screen.dart';
import '../../presentation/screens/deal/deal_detail_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/post/post_deal_screen.dart';
import '../../presentation/screens/alerts/alerts_screen.dart';
import '../../presentation/screens/settings/notification_settings_screen.dart';
import '../../presentation/widgets/main_scaffold.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isAuthenticated && !isLoggingIn) {
        return '/login';
      }

      if (isAuthenticated && isLoggingIn) {
        return '/';
      }

      return null;
    },
    routes: [
      // Login route with fade transition
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) =>
            const FadeSlideTransitionPage(child: LoginScreen()),
      ),

      // Main app shell with bottom navigation
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: '/search',
            pageBuilder: (context, state) => NoTransitionPage(
              child: SearchScreen(
                initialQuery: state.uri.queryParameters['q'],
                initialCategory: state.uri.queryParameters['category'],
              ),
            ),
          ),
          GoRoute(
            path: '/alerts',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: AlertsScreen()),
          ),
        ],
      ),

      // Profile (smooth fade-slide transition)
      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) =>
            const FadeSlideTransitionPage(child: ProfileScreen()),
      ),

      // Post deal (slide-up modal style)
      GoRoute(
        path: '/post',
        pageBuilder: (context, state) =>
            const SlideUpTransitionPage(child: PostDealScreen()),
      ),

      // Deal detail (smooth fade for Hero animation compatibility)
      GoRoute(
        path: '/deal/:slug',
        pageBuilder: (context, state) => FadeSlideTransitionPage(
          child: DealDetailScreen(slug: state.pathParameters['slug']!),
        ),
      ),

      // Settings routes
      GoRoute(
        path: '/settings/notifications',
        pageBuilder: (context, state) =>
            const FadeSlideTransitionPage(child: NotificationSettingsScreen()),
      ),
    ],
  );
});
