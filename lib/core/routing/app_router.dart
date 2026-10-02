import 'package:go_router/go_router.dart';
import '../../features/auth/models/auth_provider.dart';
import '../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
import '../../features/auth/screens/phone_screen.dart';
import '../../features/auth/screens/onboarding_placeholder_screen.dart';
import '../../features/profile/models/profile.dart';
import '../../features/messaging/screens/conversation_detail_screen.dart';
import '../../shared/widgets/main_navigation_screen.dart';

class AppRouter {
  final AuthProvider authProvider;

  AppRouter(this.authProvider);

  late final GoRouter router = GoRouter(
    initialLocation: '/',
    refreshListenable: authProvider,
    redirect: (context, state) {
      final status = authProvider.status;
      final location = state.matchedLocation;
      final isGoingToAuth = location == '/login' || location == '/otp' || location == '/phone';

      // Still checking/loading
      if (status == AuthStatus.initial || status == AuthStatus.loading) {
        // We could route to a splash screen, but staying where we are 
        // while displaying a loading overlay in the current screen is usually fine,
        // or we return a dedicated loading route. For MVP, we'll let the UI handle showing a loader.
        return null; 
      }

      // Unauthenticated
      if (status == AuthStatus.unauthenticated || status == AuthStatus.error) {
        if (!isGoingToAuth) return '/login';
        return null;
      }

      // Authenticated but onboarding required
      if (status == AuthStatus.onboardingRequired) {
        if (location != '/onboarding') return '/onboarding';
        return null;
      }

      // Authenticated and complete
      if (status == AuthStatus.authenticated) {
        if (isGoingToAuth || location == '/onboarding') return '/';
        return null;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/phone',
        builder: (context, state) => const PhoneScreen(),
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) {
          final phone = state.extra as String?;
          return OtpScreen(phoneNumber: phone ?? '');
        },
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPlaceholderScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const MainNavigationScreen(),
      ),
      GoRoute(
        path: '/chat/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          final targetUser = state.extra as Profile;
          return ConversationDetailScreen(
            conversationId: id,
            targetUser: targetUser,
          );
        },
      ),
    ],
  );
}
