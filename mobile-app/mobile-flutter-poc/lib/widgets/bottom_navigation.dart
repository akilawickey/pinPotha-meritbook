import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({super.key});
  @override
  Widget build(BuildContext context) {
    final navigation = context.watch<NavigationProvider>();
    return NavigationBar(
      selectedIndex: navigation.index,
      onDestinationSelected: (index) {
        navigation.select(index);
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.calendar_month), label: 'Home'),
        NavigationDestination(
            icon: Icon(Icons.add_circle_outline), label: 'Add'),
        NavigationDestination(icon: Icon(Icons.grid_view), label: 'View'),
        NavigationDestination(
            icon: Icon(Icons.settings_outlined), label: 'Settings'),
      ],
    );
  }
}
