import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';
import 'services/post_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const PinPothaApp());
}

class PinPothaApp extends StatelessWidget {
  final AuthProvider Function()? authFactory;
  final PostRepository? repository;
  const PinPothaApp({super.key, this.authFactory, this.repository});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => authFactory?.call() ?? AuthProvider()),
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
        home: SplashScreen(repository: repository),
      ),
    );
  }
}
