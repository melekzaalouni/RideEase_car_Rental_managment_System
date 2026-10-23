import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/models.dart';
import '../../core/network/api_client.dart';

class AdminRepository {
  AdminRepository(this._dio);
  final Dio _dio;

  Future<Dashboard> stats() => guard(() async {
        final r = await _dio.get('/api/admin/statistics');
        return Dashboard(r.data as Map<String, dynamic>);
      });

  /// The backend returns its first 50 users and takes no paging parameters.
  Future<PageData<AppUser>> users(int page) => guard(() async {
        final r = await _dio.get('/api/admin/users');
        return PageData.parse(r.data, AppUser.fromJson);
      });

  Future<void> setEnabled(int id, bool enabled) => guard(() async {
        await _dio.put('/api/admin/users/$id/${enabled ? 'enable' : 'disable'}');
      });

  /// Body is a bare JSON array of role names, e.g. ["ADMIN","EMPLOYEE"].
  Future<void> updateRoles(int id, Set<String> roles) => guard(() async {
        await _dio.put('/api/admin/users/$id/roles', data: roles.toList());
      });
}

final adminRepoProvider = Provider<AdminRepository>((ref) => AdminRepository(ref.watch(dioProvider)));

final dashboardProvider = FutureProvider.autoDispose<Dashboard>((ref) => ref.watch(adminRepoProvider).stats());
