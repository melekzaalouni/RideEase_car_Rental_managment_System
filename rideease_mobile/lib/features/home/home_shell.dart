import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../admin/dashboard_screen.dart';
import '../admin/users_screen.dart';
import '../auth/auth_controller.dart';
import '../profile/profile_screen.dart';
import '../reservations/my_reservations_screen.dart';
import '../vehicles/vehicles_screen.dart';

final homeTabProvider = StateProvider.autoDispose<int>((ref) => 0);

class _Tab {
  const _Tab(this.label, this.icon, this.selectedIcon, this.page);
  final String label;
  final IconData icon, selectedIcon;
  final Widget page;
}

class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(authProvider);
    if (s == null) return const SizedBox.shrink();

    final tabs = <_Tab>[
      if (s.isAdmin) const _Tab('Dashboard', Icons.dashboard_outlined, Icons.dashboard, DashboardScreen()),
      _Tab(
        s.isStaff ? 'Fleet' : 'Explore',
        Icons.directions_car_outlined,
        Icons.directions_car,
        VehiclesScreen(manage: s.isStaff),
      ),
      if (!s.isStaff) const _Tab('My trips', Icons.luggage_outlined, Icons.luggage, MyReservationsScreen()),
      if (s.isAdmin) const _Tab('Users', Icons.people_outline, Icons.people, UsersScreen()),
      const _Tab('Profile', Icons.person_outline, Icons.person, ProfileScreen()),
    ];

    final index = ref.watch(homeTabProvider).clamp(0, tabs.length - 1);

    return Scaffold(
      body: IndexedStack(index: index, children: [for (final t in tabs) t.page]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => ref.read(homeTabProvider.notifier).state = i,
        destinations: [
          for (final t in tabs)
            NavigationDestination(icon: Icon(t.icon), selectedIcon: Icon(t.selectedIcon), label: t.label),
        ],
      ),
    );
  }
}
