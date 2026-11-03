import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/navigation_provider.dart';

class MobileDrawer extends StatelessWidget {
  const MobileDrawer({super.key});
  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Drawer(
        child: SafeArea(
            child: ListView(children: [
      UserAccountsDrawerHeader(
          accountName: Text(user?.displayName ?? 'PinPotha'),
          accountEmail: Text(user?.email ?? '')),
      for (final entry in [
        (0, 'Home', Icons.calendar_month),
        (1, 'Add Good Thought', Icons.add),
        (2, 'View Good Things', Icons.grid_view),
        (3, 'Settings', Icons.settings)
      ])
        ListTile(
            leading: Icon(entry.$3),
            title: Text(entry.$2),
            onTap: () {
              context.read<NavigationProvider>().select(entry.$1);
              Navigator.pop(context);
              Navigator.of(context).popUntil((route) => route.isFirst);
            }),
    ])));
  }
}
