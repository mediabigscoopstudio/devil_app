import 'package:go_router/go_router.dart';
import '../../features/auth/models/auth_provider.dart';
import '../../features/auth/screens/sign_in_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
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
      final isGoingToAuth = state.matchedLocation == '/login' || state.matchedLocation == '/otp';

      // Still checking
      if (status == AuthStatus.initial || status == AuthStatus.loading) {
        return null; 
      }

      // Not authenticated
      if (status == AuthStatus.unauthenticated || status == AuthStatus.error) {
        if (!isGoingToAuth) return '/login';
        return null;
      }

      // Authenticated
      if (status == AuthStatus.authenticated) {
        if (isGoingToAuth) return '/';
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
        path: '/otp',
        builder: (context, state) {
          final phone = state.extra as String?;
          return OtpScreen(phoneNumber: phone ?? '');
        },
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
