import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase, handling the case where it might already be initialized
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // If Firebase is already initialized (duplicate-app error), that's fine
    // This can happen during hot reload or if native code auto-initializes it
    final errorString = e.toString().toLowerCase();
    if (errorString.contains('duplicate-app') || 
        errorString.contains('already exists') ||
        errorString.contains('[core/duplicate-app]')) {
      // App already exists, continue normally
      debugPrint('Firebase already initialized, continuing...');
    } else {
      // Some other error occurred, rethrow it
      debugPrint('Firebase initialization error: $e');
      rethrow;
    }
  }
  
  runApp(const PinPothaApp());
}

class PinPothaApp extends StatelessWidget {
  const PinPothaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'PinPotha',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.orange,
          primaryColor: const Color(0xFFEFAA21), // Orange from logo
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFEFAA21),
            primary: const Color(0xFFEFAA21), // Orange from logo
            secondary: const Color(0xFF132558), // Dark blue from logo
            tertiary: const Color(0xFFF5A61D), // Darker golden from logo
            surface: const Color(0xFFFFFEF6), // Light cream from logo
            onPrimary: Colors.white,
            onSecondary: Colors.white,
          ),
          useMaterial3: true,
          fontFamily: 'System',
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFEFAA21), // Orange
            foregroundColor: Colors.white,
            elevation: 2,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEFAA21), // Orange
              foregroundColor: Colors.white,
              elevation: 2,
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFFEFAA21), // Orange
            foregroundColor: Colors.white,
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

