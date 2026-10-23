import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/models.dart';
import '../../core/network/api_client.dart';
import '../auth/auth_controller.dart';
import 'reservation_repository.dart';

final reservationRepoProvider =
    Provider<ReservationRepository>((ref) => ReservationRepository(ref.watch(dioProvider)));

final myReservationsProvider = FutureProvider.autoDispose<List<Reservation>>((ref) async {
  final s = ref.watch(authProvider);
  final cid = s?.customerId;
  if (cid == null) return <Reservation>[];
  final list = await ref.read(reservationRepoProvider).mine(cid);
  list.sort((a, b) => b.id.compareTo(a.id));
  return list;
});

final reservationProvider = FutureProvider.autoDispose.family<Reservation, int>((ref, id) async {
  ref.watch(authProvider);
  try {
    final list = await ref.watch(myReservationsProvider.future);
    for (final r in list) {
      if (r.id == id) return r;
    }
  } catch (_) {}
  return ref.read(reservationRepoProvider).byId(id);
});
