import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/posts_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final Future<PackageInfo> _info = PackageInfo.fromPlatform();
  bool _signingOut = false;
  Future<void> _signOut() async {
    final auth = context.read<AuthProvider>();
    if (context.read<PostsProvider>().activeOperations > 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Wait for pending saves or uploads before signing out.')));
      return;
    }
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Sign out?'),
              content: const Text(
                  'Unsaved drafts will be discarded. Wait for any pending saves before signing out.'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel')),
                TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Sign out'))
              ],
            ));
    if (confirmed != true || !mounted) return;
    if (context.read<PostsProvider>().activeOperations > 0) return;
    setState(() => _signingOut = true);
    try {
      await auth.signOut();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Sign out failed. Please try again.')));
      }
    } finally {
      if (mounted) setState(() => _signingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final posts = context.watch<PostsProvider>();
    return Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: ListView(children: [
          ListTile(
              leading: const Icon(Icons.account_circle),
              title: Text(user?.displayName ?? 'Profile'),
              subtitle: Text(user?.email ?? '')),
          FutureBuilder<PackageInfo>(
              future: _info,
              builder: (context, snapshot) => ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('PinPotha'),
                    subtitle: Text(snapshot.hasError
                        ? 'Version unavailable'
                        : snapshot.hasData
                            ? 'Version ${snapshot.data!.version} (${snapshot.data!.buildNumber})'
                            : 'Loading version…'),
                  )),
          const ListTile(
              title: Text('About PinPotha'),
              subtitle: Text(
                  'Record and remember the good things you have done. පින් පොත')),
          if (posts.cleanupPending.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.cloud_off),
              title:
                  Text('${posts.cleanupPending.length} photo cleanup pending'),
              trailing: TextButton(
                  onPressed: posts.connected ? posts.retryCleanup : null,
                  child: const Text('Retry')),
            ),
          ListTile(
              leading: const Icon(Icons.logout),
              title: Text(_signingOut ? 'Signing out…' : 'Sign out'),
              onTap: _signingOut ? null : _signOut),
        ]));
  }
}
