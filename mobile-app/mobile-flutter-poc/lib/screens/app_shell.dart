import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/posts_provider.dart';
import '../services/post_service.dart';
import '../widgets/bottom_navigation.dart';
import 'calendar_screen.dart';
import 'dashboard_screen.dart';
import 'add_post_screen.dart';
import 'settings_screen.dart';

class AuthenticatedApp extends StatefulWidget {
  final String email;
  final PostRepository? repository;
  const AuthenticatedApp({super.key, required this.email, this.repository});
  @override
  State<AuthenticatedApp> createState() => _AuthenticatedAppState();
}

class _AuthenticatedAppState extends State<AuthenticatedApp> {
  final _navigator = GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (_) =>
                  PostsProvider(widget.email, repository: widget.repository)),
          ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ],
        // Child routes are removed with this authenticated subtree on logout.
        child: NavigatorPopHandler<Object?>(
            onPopWithResult: (_) => _navigator.currentState!.maybePop(),
            child: Navigator(
                key: _navigator,
                onGenerateRoute: (_) =>
                    MaterialPageRoute<void>(builder: (_) => const AppShell()))),
      );
}

class AppShell extends StatelessWidget {
  const AppShell({super.key});
  @override
  Widget build(BuildContext context) {
    final navigation = context.watch<NavigationProvider>();
    final posts = context.watch<PostsProvider>();
    return Scaffold(
      body: Column(children: [
        if (!posts.connected)
          const MaterialBanner(
            content: Text(
                'Offline. Connect to save changes. Your current draft is kept.'),
            actions: [SizedBox.shrink()],
          ),
        if (posts.cleanupPending.isNotEmpty)
          MaterialBanner(
            content: const Text(
                'A photo could not be removed. Retry cleanup in Settings.'),
            actions: [
              TextButton(
                  onPressed: () => navigation.select(3),
                  child: const Text('Settings'))
            ],
          ),
        Expanded(
            child: IndexedStack(index: navigation.index, children: [
          const CalendarScreen(),
          AddPostScreen(embedded: true, onSaved: navigation.showSavedDate),
          const DashboardScreen(),
          const SettingsScreen(),
        ])),
      ]),
      bottomNavigationBar: const BottomNavigation(),
    );
  }
}
