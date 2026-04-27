// Force reload
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pantheon/models/user_model.dart';
import 'package:pantheon/services/auth_service.dart';
import 'package:pantheon/services/chat_service.dart';
import 'package:pantheon/services/ad_service.dart';
import 'package:pantheon/screens/splash_screen.dart';
import 'package:pantheon/screens/login_screen.dart';
import 'package:pantheon/screens/register_screen.dart';
import 'package:pantheon/screens/forgot_password_screen.dart';
import 'package:pantheon/screens/email_confirmation_screen.dart';
import 'package:pantheon/screens/profile_questions_screen.dart';
import 'package:pantheon/screens/home_screen.dart';
import 'package:pantheon/screens/edit_profile_screen.dart';
import 'package:pantheon/screens/find_players_screen.dart';
import 'package:pantheon/screens/chat_screen.dart';
import 'package:pantheon/screens/notificaciones_screen.dart';
import 'package:pantheon/services/notificaciones_estado_service.dart';
import 'package:pantheon/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://frwthxndvjmkbdtaidgn.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZyd3RoeG5kdmpta2JkdGFpZGduIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY5NDYyOTUsImV4cCI6MjA5MjUyMjI5NX0.15mrHW9MwVPOK8QDLtsN0xVjUliH4AWOCJzE035dALY',
  );

  await AdService().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ChatService()),
        ChangeNotifierProvider(create: (_) => NotificacionesEstadoService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SMASH',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            name: 'splash',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const SplashScreen(),
            ),
          ),
          GoRoute(
            path: '/login',
            name: 'login',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const LoginScreen(),
            ),
          ),
          GoRoute(
            path: '/register',
            name: 'register',
            pageBuilder: (context, state) => MaterialPage(
              child: const RegisterScreen(),
            ),
          ),
          GoRoute(
            path: '/forgot-password',
            name: 'forgot-password',
            pageBuilder: (context, state) => MaterialPage(
              child: const ForgotPasswordScreen(),
            ),
          ),
          GoRoute(
            path: '/email-confirmation',
            name: 'email-confirmation',
            pageBuilder: (context, state) {
              final email = state.uri.queryParameters['email'] ?? '';
              return MaterialPage(
                child: EmailConfirmationScreen(email: email),
              );
            },
          ),
          GoRoute(
            path: '/profile-questions',
            name: 'profile-questions',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const ProfileQuestionsScreen(),
            ),
          ),
          GoRoute(
            path: '/home',
            name: 'home',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/edit-profile',
            name: 'edit-profile',
            pageBuilder: (context, state) => MaterialPage(
              child: const EditProfileScreen(),
            ),
          ),
          GoRoute(
            path: '/find-players',
            name: 'find-players',
            pageBuilder: (context, state) => MaterialPage(
              child: const FindPlayersScreen(),
            ),
          ),
          GoRoute(
            path: '/chat/:userId',
            name: 'chat',
            pageBuilder: (context, state) {
              final userId = state.pathParameters['userId']!;
              final connectionId = state.uri.queryParameters['connectionId'];
              final matchedUser = state.extra as UserModel?;
              return MaterialPage(
                child: ChatScreen(
                  otherUserId: userId,
                  connectionId: connectionId,
                  matchedUser: matchedUser,
                ),
              );
            },
          ),
          GoRoute(
            path: '/notificaciones',
            name: 'notificaciones',
            pageBuilder: (context, state) => MaterialPage(
              child: const NotificacionesScreen(),
            ),
          ),
        ],
      ),
    );
  }
}
