import 'package:go_router/go_router.dart';
import '../../features/auth/models/auth_provider.dart';
import '../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
import '../../features/auth/screens/phone_screen.dart';
import '../../features/profile/models/profile.dart';
import '../../features/profile/screens/onboarding/name_screen.dart';
import '../../features/profile/screens/onboarding/age_screen.dart';
import '../../features/profile/screens/onboarding/gender_screen.dart';
import '../../features/profile/screens/onboarding/looking_for_screen.dart';
import '../../features/profile/screens/onboarding/interests_screen.dart';
import '../../features/profile/screens/onboarding/photos_screen.dart';
import '../../features/profile/screens/onboarding/bio_screen.dart';
import '../../features/profile/screens/onboarding/location_screen.dart';
import '../../features/profile/screens/onboarding/review_screen.dart';
import '../../features/profile/screens/onboarding/notifications_screen.dart';
import '../../features/profile/screens/onboarding/success_screen.dart';
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
        redirect: (context, state) => '/onboarding/name',
      ),
      GoRoute(
        path: '/onboarding/name',
        builder: (context, state) => const NameScreen(),
      ),
      GoRoute(
        path: '/onboarding/age',
        builder: (context, state) => const AgeScreen(),
      ),
      GoRoute(
        path: '/onboarding/gender',
        builder: (context, state) => const GenderScreen(),
      ),
      GoRoute(
        path: '/onboarding/looking-for',
        builder: (context, state) => const LookingForScreen(),
      ),
      GoRoute(
        path: '/onboarding/interests',
        builder: (context, state) => const InterestsScreen(),
      ),
      GoRoute(
        path: '/onboarding/photos',
        builder: (context, state) => const PhotosScreen(),
      ),
      GoRoute(
        path: '/onboarding/bio',
        builder: (context, state) => const BioScreen(),
      ),
      GoRoute(
        path: '/onboarding/location',
        builder: (context, state) => const LocationScreen(),
      ),
      GoRoute(
        path: '/onboarding/review',
        builder: (context, state) => const ReviewScreen(),
      ),
      GoRoute(
        path: '/onboarding/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/onboarding/success',
        builder: (context, state) => const SuccessScreen(),
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
