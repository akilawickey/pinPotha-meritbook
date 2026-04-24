import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../providers/auth_provider.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Listen to auth state changes to clear loading if user signs in
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isAuthenticated) {
        // User is already authenticated, navigation will happen via SplashScreen
        if (mounted) {
          setState(() {
            _loading = false;
          });
        }
      }
    });
  }

  Future<void> _handleSignIn() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signInWithGoogle();
      
      // Wait a bit for auth state changes to propagate
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Clear loading state - navigation will happen via SplashScreen if authenticated
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Sign-in error: $e');
      if (mounted) {
        String errorMessage = 'Failed to sign in. Please try again.';
        
        // Extract a more user-friendly error message
        final errorString = e.toString();
        if (errorString.contains('network')) {
          errorMessage = 'Network error. Please check your connection and try again.';
        } else if (errorString.contains('cancelled') || errorString.contains('canceled')) {
          errorMessage = 'Sign in was cancelled.';
          // Don't show error for cancellation
          setState(() {
            _loading = false;
          });
          return;
        } else if (errorString.isNotEmpty) {
          // Try to extract a cleaner error message
          final match = RegExp(r'Exception: (.+)').firstMatch(errorString);
          if (match != null) {
            errorMessage = match.group(1) ?? errorMessage;
          } else {
            errorMessage = errorString.replaceAll('Exception: ', '');
          }
        }
        
        setState(() {
          _error = errorMessage;
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth provider to clear loading when authenticated
    final authProvider = Provider.of<AuthProvider>(context);
    
    // If user becomes authenticated, clear loading state immediately
    if (authProvider.isAuthenticated && _loading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _loading = false;
          });
        }
      });
    }
    
    // Also clear loading if auth provider is not loading anymore
    if (!authProvider.loading && _loading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !authProvider.isAuthenticated) {
          setState(() {
            _loading = false;
          });
        }
      });
    }
    
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFFFFEF6), // Light cream from logo
                Colors.white,
                const Color(0xFFFBFBF9), // Very light gray from logo
              ],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  SvgPicture.asset(
                    'assets/images/logo.svg',
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 32),
                  
                  // Tagline
                  Text(
                    'Record and remember the good things you\'ve done',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  
                  Container(
                    width: 96,
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF132558), // Dark blue from logo
                          const Color(0xFFEFAA21), // Golden from logo
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Description
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'The ancient people had a small book called \'PIN POTHA\' which they used to record and memorize good things they had done. This app brings back that good habit to our modern era.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  // Sign In Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _handleSignIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor, // Orange from theme
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.login, size: 24),
                                const SizedBox(width: 12),
                                const Text(
                                  'Sign in with Google',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  
                  // Error Message
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _error!,
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 32),
                  
                  // Footer
                  Text(
                    'Powered by leafylanka',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

