import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart';
import '../screens/add_post_screen.dart';

enum CurrentScreen { dashboard, add, other }

class BottomNavigation extends StatelessWidget {
  final CurrentScreen currentScreen;
  
  const BottomNavigation({
    super.key,
    this.currentScreen = CurrentScreen.other,
  });

  @override
  Widget build(BuildContext context) {
    // Determine which screen is active
    final isDashboard = currentScreen == CurrentScreen.dashboard;
    final isAddScreen = currentScreen == CurrentScreen.add;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          constraints: const BoxConstraints(minHeight: 60, maxHeight: 65),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                icon: Icons.home,
                label: 'Home',
                isActive: isDashboard,
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const DashboardScreen()),
                    (route) => false,
                  );
                },
              ),
              _buildNavItem(
                context,
                icon: Icons.add_circle,
                label: 'Add',
                isActive: isAddScreen,
                isPrimary: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddPostScreen()),
                  );
                },
              ),
              _buildNavItem(
                context,
                icon: Icons.menu,
                label: 'Menu',
                isActive: false,
                onTap: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
    bool isActive = false,
  }) {
    final isHighlighted = isPrimary && isActive;
    final hasActiveBackground = isActive && !isPrimary; // For home button when active
    
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Container(
                padding: EdgeInsets.all(isHighlighted ? 10 : (hasActiveBackground ? 8 : 6)),
                decoration: isHighlighted
                    ? BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      )
                    : hasActiveBackground
                        ? BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.15),
                            shape: BoxShape.circle,
                          )
                        : null,
                child: Icon(
                  icon,
                  color: isHighlighted
                      ? Colors.white
                      : (isActive 
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).primaryColor.withOpacity(0.6)),
                  size: isHighlighted ? 26 : (hasActiveBackground ? 24 : 22),
                ),
              ),
            ),
            if (!isPrimary) ...[
              const SizedBox(height: 1),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: isActive 
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).primaryColor.withOpacity(0.6),
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

