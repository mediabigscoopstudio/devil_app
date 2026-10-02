import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/network/api_client.dart';
import 'core/storage/secure_storage.dart';
import 'features/auth/repositories/auth_repository.dart';
import 'features/auth/models/auth_provider.dart';
import 'features/profile/repositories/profile_repository.dart';
import 'features/profile/models/profile_provider.dart';
import 'features/profile/models/onboarding_provider.dart';
import 'features/discovery/repositories/discovery_repository.dart';
import 'features/discovery/models/discovery_provider.dart';
import 'features/matching/repositories/matching_repository.dart';
import 'features/matching/models/matching_provider.dart';
import 'features/messaging/repositories/messaging_repository.dart';
import 'features/messaging/models/messaging_provider.dart';
import 'features/moderation/repositories/moderation_repository.dart';
import 'features/moderation/models/moderation_provider.dart';
import 'features/notifications/repositories/notifications_repository.dart';
import 'features/notifications/models/notifications_provider.dart';
import 'core/routing/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiClient>(create: (_) => ApiClient()),
        Provider<SecureStorage>(create: (_) => SecureStorage()),
        ProxyProvider2<ApiClient, SecureStorage, AuthRepository>(
          update: (_, api, storage, prev) => AuthRepository(api, storage),
        ),
        ChangeNotifierProxyProvider<AuthRepository, AuthProvider>(
          create: (context) => AuthProvider(context.read<AuthRepository>()),
          update: (_, authRepo, authProvider) => authProvider ?? AuthProvider(authRepo),
        ),
        ProxyProvider2<ApiClient, SecureStorage, ProfileRepository>(
          update: (_, api, storage, prev) => ProfileRepository(api, storage),
        ),
        ChangeNotifierProxyProvider<ProfileRepository, ProfileProvider>(
          create: (context) => ProfileProvider(context.read<ProfileRepository>()),
          update: (_, profileRepo, profileProvider) => profileProvider ?? ProfileProvider(profileRepo),
        ),
        ChangeNotifierProxyProvider2<ProfileRepository, AuthProvider, OnboardingProvider>(
          create: (context) => OnboardingProvider(context.read<ProfileRepository>(), context.read<AuthProvider>()),
          update: (_, profileRepo, authProvider, onboardingProvider) => onboardingProvider ?? OnboardingProvider(profileRepo, authProvider),
        ),
        ProxyProvider<ApiClient, DiscoveryRepository>(
          update: (_, api, prev) => DiscoveryRepository(api),
        ),
        ChangeNotifierProxyProvider<DiscoveryRepository, DiscoveryProvider>(
          create: (context) => DiscoveryProvider(context.read<DiscoveryRepository>()),
          update: (_, discoveryRepo, discoveryProvider) => discoveryProvider ?? DiscoveryProvider(discoveryRepo),
        ),
        ProxyProvider<ApiClient, MatchingRepository>(
          update: (_, api, prev) => MatchingRepository(api),
        ),
        ChangeNotifierProxyProvider<MatchingRepository, MatchingProvider>(
          create: (context) => MatchingProvider(context.read<MatchingRepository>()),
          update: (_, matchingRepo, matchingProvider) => matchingProvider ?? MatchingProvider(matchingRepo),
        ),
        ProxyProvider<ApiClient, MessagingRepository>(
          update: (_, api, prev) => MessagingRepository(api),
        ),
        ChangeNotifierProxyProvider<MessagingRepository, MessagingProvider>(
          create: (context) => MessagingProvider(context.read<MessagingRepository>()),
          update: (_, messagingRepo, messagingProvider) => messagingProvider ?? MessagingProvider(messagingRepo),
        ),
        ProxyProvider<ApiClient, ModerationRepository>(
          update: (_, api, prev) => ModerationRepository(api),
        ),
        ChangeNotifierProxyProvider<ModerationRepository, ModerationProvider>(
          create: (context) => ModerationProvider(context.read<ModerationRepository>()),
          update: (_, modRepo, modProvider) => modProvider ?? ModerationProvider(modRepo),
        ),
        ProxyProvider<ApiClient, NotificationsRepository>(
          update: (_, api, prev) => NotificationsRepository(api),
        ),
        ChangeNotifierProxyProvider<NotificationsRepository, NotificationsProvider>(
          create: (context) => NotificationsProvider(context.read<NotificationsRepository>()),
          update: (_, notifRepo, notifProvider) => notifProvider ?? NotificationsProvider(notifRepo),
        ),
      ],
      child: const DevilApp(),
    );
  }
}

class DevilApp extends StatefulWidget {
  const DevilApp({super.key});

  @override
  State<DevilApp> createState() => _DevilAppState();
}

class _DevilAppState extends State<DevilApp> {
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    // Initialize router with the AuthProvider to handle redirects automatically
    _appRouter = AppRouter(context.read<AuthProvider>());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'DEVIL',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      routerConfig: _appRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
