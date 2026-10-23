import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/auth_controller.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/home/home_shell.dart';
import '../features/payments/payment_screen.dart';
import '../features/reservations/booking_screen.dart';
import '../features/vehicles/vehicle_detail_screen.dart';
import '../features/vehicles/vehicle_form_screen.dart';
import 'models/models.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(authProvider, (_, __) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/home',
    refreshListenable: refresh,
    redirect: (context, state) {
      final signedIn = ref.read(authProvider) != null;
      final loc = state.matchedLocation;
      final isAuthPage = loc == '/login' || loc == '/register';
      if (!signedIn && !isAuthPage) return '/login';
      if (signedIn && isAuthPage) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/home', builder: (_, __) => const HomeShell()),
      GoRoute(
        path: '/vehicle/:id',
        builder: (_, s) => VehicleDetailScreen(vehicleId: int.parse(s.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/book/:id',
        builder: (_, s) => BookingScreen(vehicleId: int.parse(s.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/pay/:id',
        builder: (_, s) => PaymentScreen(reservationId: int.parse(s.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/vehicle-form',
        builder: (_, s) => VehicleFormScreen(vehicle: s.extra as Vehicle?),
      ),
    ],
  );
});
