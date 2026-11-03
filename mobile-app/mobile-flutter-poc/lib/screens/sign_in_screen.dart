import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  String? _error;
  Future<void> _signIn() async {
    setState(() => _error = null);
    try {
      await context.read<AuthProvider>().signInWithGoogle();
    } catch (_) {
      if (mounted) {
        setState(() =>
            _error = 'Sign in failed. Check your connection and try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
        body: SafeArea(
            child: Center(
                child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        SvgPicture.asset('assets/images/logo.svg',
                            width: 140, height: 140),
                        const SizedBox(height: 24),
                        Text('PinPotha',
                            style: Theme.of(context).textTheme.headlineLarge),
                        const SizedBox(height: 12),
                        const Text(
                            'Record and remember the good things you have done.',
                            textAlign: TextAlign.center),
                        const SizedBox(height: 32),
                        if (_error != null)
                          Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Text(_error!,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .error))),
                        FilledButton.icon(
                            onPressed: auth.loading ? null : _signIn,
                            icon: const Icon(Icons.login),
                            label: Text(auth.loading
                                ? 'Signing in…'
                                : 'Continue with Google')),
                      ]),
                    )))));
  }
}
