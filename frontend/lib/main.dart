import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bootiehunter/services/auth_service.dart';
import 'package:bootiehunter/services/api_service.dart';
import 'package:bootiehunter/services/bootie_service.dart';
import 'package:bootiehunter/services/location_service.dart';
import 'package:bootiehunter/services/image_service.dart';
import 'package:bootiehunter/services/image_analysis_service.dart';
import 'package:bootiehunter/services/gemini_live_service.dart';
import 'package:bootiehunter/services/conversation_service.dart';
import 'package:bootiehunter/providers/auth_provider.dart';
import 'package:bootiehunter/providers/bootie_provider.dart';
import 'package:bootiehunter/screens/home_screen.dart';
import 'package:bootiehunter/screens/landing_screen.dart';
import 'package:bootiehunter/screens/onboarding_screen.dart';
import 'package:bootiehunter/screens/booties_list_screen.dart';
import 'package:bootiehunter/screens/phone_screen.dart';
import 'package:bootiehunter/screens/messages_screen.dart';
import 'package:bootiehunter/screens/prompts_config_screen.dart';
import 'package:bootiehunter/services/prompt_service.dart';
import 'package:flutter/foundation.dart';

// API Configuration
// Uses production URL when running on web, localhost for development
String getApiBaseUrl() {
  if (kIsWeb) {
    // Production API URL for web deployment
    return 'https://reed-bootie-hunter-v1-1.onrender.com/api/v1';
  } else {
    // Local development URL
    return 'http://localhost:3000/api/v1';
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BootieHunterApp());
}

class BootieHunterApp extends StatelessWidget {
  const BootieHunterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>(
          create: (_) => ApiService(baseUrl: getApiBaseUrl()),
        ),
        Provider<BootieService>(
          create: (context) => BootieService(
            apiService: context.read<ApiService>(),
          ),
        ),
        Provider<LocationService>(
          create: (context) => LocationService(
            apiService: context.read<ApiService>(),
          ),
        ),
        Provider<ImageService>(
          create: (context) => ImageService(
            apiService: context.read<ApiService>(),
          ),
        ),
        Provider<ImageAnalysisService>(
          create: (context) => ImageAnalysisService(
            apiService: context.read<ApiService>(),
          ),
        ),
        Provider<GeminiLiveService>(
          create: (context) => GeminiLiveService(
            apiService: context.read<ApiService>(),
          ),
        ),
        Provider<ConversationService>(
          create: (context) => ConversationService(
            apiService: context.read<ApiService>(),
          ),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            authService: AuthService(
              apiService: context.read<ApiService>(),
            ),
          )..checkAuthStatus(),
        ),
        ChangeNotifierProvider<BootieProvider>(
          create: (context) => BootieProvider(
            bootieService: context.read<BootieService>(),
          ),
        ),
        Provider<PromptService>(
          create: (context) {
            final promptService = PromptService(context.read<ApiService>());
            // Load cache at startup (non-blocking)
            promptService.loadCache().catchError((e) {
              debugPrint('Failed to load prompt cache: $e');
            });
            return promptService;
          },
        ),
      ],
      child: MaterialApp(
        title: 'R.E.E.D. Bootie Hunter',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        routes: {
          '/': (context) => _buildInitialRoute(context),
          '/booties': (context) => const BootiesListScreen(),
          '/phone': (context) => const PhoneScreen(),
          '/messages': (context) => const MessagesScreen(),
          '/prompts': (context) => const PromptsConfigScreen(),
        },
      ),
    );
  }

  Widget _buildInitialRoute(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Not authenticated - show landing screen
        if (!authProvider.isAuthenticated) {
          return const LandingScreen();
        }

        // Authenticated - check onboarding status
        final hasCompletedOnboarding = authProvider.hasCompletedOnboarding ?? false;

        if (!hasCompletedOnboarding) {
          // First time user - show onboarding
          return const OnboardingScreen();
        }

        // Returning user - show home
        return const HomeScreen();
      },
    );
  }
}
