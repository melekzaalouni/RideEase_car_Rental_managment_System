import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/enums.dart';
import '../../core/models/models.dart';
import '../../core/network/api_client.dart';
import '../../core/paging.dart';
import '../auth/auth_controller.dart';
import 'vehicle_repository.dart';

final vehicleRepoProvider = Provider<VehicleRepository>((ref) => VehicleRepository(ref.watch(dioProvider)));

class VehicleFilterNotifier extends Notifier<VehicleFilter> {
  @override
  VehicleFilter build() {
    final s = ref.watch(authProvider); // a new login resets the filter
    return VehicleFilter(status: (s?.isStaff ?? false) ? null : VehicleStatus.available);
  }

  void set(VehicleFilter f) => state = f;
  void patch(VehicleFilter Function(VehicleFilter) fn) => state = fn(state);
  void reset() => ref.invalidateSelf();
}

final vehicleFilterProvider = NotifierProvider<VehicleFilterNotifier, VehicleFilter>(VehicleFilterNotifier.new);

/// The backend returns a plain list, so paging (10 per page) is done on the phone:
/// page 0 downloads and filters everything, the next pages just reveal more of it.
class VehicleListNotifier extends PagedNotifier<Vehicle> {
  static const _size = 10;
  List<Vehicle> _all = const [];

  @override
  Future<PagedState<Vehicle>> build() {
    ref.watch(vehicleFilterProvider); // any filter change reloads page 0
    return super.build();
  }

  @override
  Future<PageData<Vehicle>> fetch(int page) async {
    if (page == 0) {
      final f = ref.read(vehicleFilterProvider);
      final staff = ref.read(authProvider)?.isStaff ?? false;
      _all = await ref.read(vehicleRepoProvider).all(f, staff: staff);
    }
    final start = page * _size;
    final end = min(start + _size, _all.length);
    final slice = start >= _all.length ? <Vehicle>[] : _all.sublist(start, end);
    return PageData(content: slice, page: page, last: end >= _all.length);
  }
}

final vehicleListProvider =
    AsyncNotifierProvider<VehicleListNotifier, PagedState<Vehicle>>(VehicleListNotifier.new);

final vehicleProvider = FutureProvider.family<Vehicle, int>(
  (ref, id) => ref.watch(vehicleRepoProvider).byId(id),
);
