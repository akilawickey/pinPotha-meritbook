import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'sign_in_screen.dart';
import 'app_shell.dart';
import '../services/post_service.dart';

class SplashScreen extends StatelessWidget {
  final PostRepository? repository;
  const SplashScreen({super.key, this.repository});
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.user != null) {
      final email = auth.user!.email;
      if (email == null || email.isEmpty) {
        return Scaffold(
            body: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text(
              'This account has no email address. Please use Google sign-in.'),
          TextButton(onPressed: auth.signOut, child: const Text('Sign out')),
        ])));
      }
      return AuthenticatedApp(
          key: ValueKey('${auth.user!.uid}:$email'),
          email: email,
          repository: repository);
    }
    if (auth.initializing) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return const SignInScreen();
  }
}
