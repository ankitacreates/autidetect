import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:autidetect/constants/theme.dart';
import 'package:autidetect/constants/strings.dart';
import 'package:autidetect/constants/routes.dart';
import 'package:autidetect/constants/colors.dart';
import 'package:autidetect/screens/welcome_screen.dart';
import 'package:autidetect/screens/user_type_selection_screen.dart';
import 'package:autidetect/screens/home_screen.dart';
import 'package:autidetect/screens/assessment_selection_screen.dart';
import 'package:autidetect/screens/assessment_instructions_screen.dart';
import 'package:autidetect/screens/video_capture_screen.dart';
import 'package:autidetect/screens/questionnaire_screen.dart';
import 'package:autidetect/screens/processing_results_screen.dart';
import 'package:autidetect/screens/results_screen.dart';
import 'package:autidetect/screens/chat_screen.dart';
import 'package:autidetect/screens/child_profile_screen.dart';
import 'package:autidetect/screens/parent_profile_screen.dart';
import 'package:autidetect/screens/assessment_history_screen.dart';
import 'package:provider/provider.dart';
import 'package:autidetect/providers/chat_provider.dart';
import 'package:autidetect/models/user_model.dart';
import 'package:autidetect/models/assessment_model.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:autidetect/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load();
  
  // Initialize Supabase
  try {
    await SupabaseService.initialize();
    print('Supabase initialized successfully');
  } catch (e) {
    print('Error initializing Supabase: $e');
    // Continue with app initialization even if Supabase fails
    // The app will use local storage as fallback
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (context) => const SplashScreen(),
          AppRoutes.welcome: (context) => const WelcomeScreen(),
          AppRoutes.userTypeSelection: (context) => const UserTypeSelectionScreen(),
          AppRoutes.childProfile: (context) => const ChildProfileScreen(),
          AppRoutes.home: (context) => const HomeScreen(),
          AppRoutes.assessmentSelection: (context) => const AssessmentSelectionScreen(),
          AppRoutes.assessmentInstructions: (context) => const AssessmentInstructionsScreen(),
          AppRoutes.videoCapture: (context) => const VideoCaptureScreen(),
          AppRoutes.questionnaire: (context) => const QuestionnaireScreen(),
          AppRoutes.chat: (context) => const ChatScreen(),
          AppRoutes.assessmentHistory: (context) => const AssessmentHistoryScreen(),
          // Additional routes would be added here
        },
        onGenerateRoute: (settings) {
          if (settings.name == AppRoutes.parentProfile) {
            final userType = settings.arguments as UserType?;
            return MaterialPageRoute(
              builder: (context) => ParentProfileScreen(
                userType: userType ?? UserType.parent,
              ),
            );
          }
          
          if (settings.name == AppRoutes.processingResults) {
            final assessment = settings.arguments as Assessment;
            return MaterialPageRoute(
              builder: (context) => ProcessingResultsScreen(
                assessment: assessment,
              ),
            );
          }
          
          if (settings.name == AppRoutes.results) {
            final assessment = settings.arguments as Assessment;
            return MaterialPageRoute(
              builder: (context) => ResultsScreen(
                assessment: assessment,
              ),
            );
          }
          
          return null;
        },
      ),
    );
  }
}

// Splash screen following roadmap guidelines:
// - Simple, clean interface
// - Minimal distractions
// - Clear indication of app purpose

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate loading process
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, AppRoutes.welcome);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.psychology,
                  size: 72,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppStrings.appName,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.appTagline,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryDark),
            ),
          ],
        ),
      ),
    );
  }
}
