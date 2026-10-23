import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../core/models/enums.dart';
import '../../core/models/models.dart';
import '../../core/network/api_client.dart';

const _keep = Object();

class VehicleFilter {
  const VehicleFilter({
    this.category,
    this.status,
    this.brand,
    this.minRate,
    this.maxRate,
    this.year,
    this.sort = 'dailyRate,asc',
  });

  final VehicleCategory? category;
  final VehicleStatus? status;
  final String? brand;
  final double? minRate, maxRate;
  final int? year;
  final String sort;

  int get activeCount => [status, minRate, maxRate, year].where((e) => e != null).length;

  VehicleFilter copyWith({
    Object? category = _keep,
    Object? status = _keep,
    Object? brand = _keep,
    Object? minRate = _keep,
    Object? maxRate = _keep,
    Object? year = _keep,
    String? sort,
  }) =>
      VehicleFilter(
        category: identical(category, _keep) ? this.category : category as VehicleCategory?,
        status: identical(status, _keep) ? this.status : status as VehicleStatus?,
        brand: identical(brand, _keep) ? this.brand : brand as String?,
        minRate: identical(minRate, _keep) ? this.minRate : minRate as double?,
        maxRate: identical(maxRate, _keep) ? this.maxRate : maxRate as double?,
        year: identical(year, _keep) ? this.year : year as int?,
        sort: sort ?? this.sort,
      );
}

class VehicleRepository {
  VehicleRepository(this._dio);
  final Dio _dio;

  /// The backend's GET /api/vehicles matches `category = ? AND status = ?` and returns
  /// nothing when a parameter is missing, so every (category, status) pair is requested
  /// explicitly and merged. Brand / price / year / sort are applied here on the phone.
  Future<List<Vehicle>> all(VehicleFilter f, {required bool staff}) => guard(() async {
        final cats = f.category != null ? [f.category!] : VehicleCategory.values;
        final stats = f.status != null ? [f.status!] : VehicleStatus.values;
        final results = await Future.wait([
          for (final c in cats)
            for (final s in stats)
              _dio.get('/api/vehicles', queryParameters: {'category': c.api, 'status': s.api}),
        ]);
        final byId = <int, Vehicle>{};
        for (final r in results) {
          for (final j in (r.data as List)) {
            final v = Vehicle.fromJson(j as Map<String, dynamic>);
            byId[v.id] = v;
          }
        }
        var list = byId.values.toList();

        final q = (f.brand ?? '').trim().toLowerCase();
        if (q.isNotEmpty) list = list.where((v) => v.title.toLowerCase().contains(q)).toList();
        if (f.minRate != null) list = list.where((v) => v.dailyRate >= f.minRate!).toList();
        if (f.maxRate != null) list = list.where((v) => v.dailyRate <= f.maxRate!).toList();
        if (f.year != null) list = list.where((v) => v.year == f.year).toList();

        final parts = f.sort.split(',');
        final desc = parts.length > 1 && parts[1] == 'desc';
        int cmp(Vehicle a, Vehicle b) {
          switch (parts[0]) {
            case 'yearOfManufacture':
              return a.year.compareTo(b.year);
            case 'brand':
              return a.title.toLowerCase().compareTo(b.title.toLowerCase());
            default:
              return a.dailyRate.compareTo(b.dailyRate);
          }
        }

        list.sort((a, b) => desc ? cmp(b, a) : cmp(a, b));
        return list;
      });

  Future<Vehicle> byId(int id) => guard(() async {
        final r = await _dio.get('/api/vehicles/$id');
        return Vehicle.fromJson(r.data as Map<String, dynamic>);
      });

  Future<Vehicle> save(Map<String, dynamic> body, int? id) => guard(() async {
        final r = id == null
            ? await _dio.post('/api/vehicles', data: body)
            : await _dio.put('/api/vehicles/$id', data: body);
        return Vehicle.fromJson(r.data as Map<String, dynamic>);
      });

  /// Staff only. Replaces the photo of a vehicle.
  Future<Vehicle> uploadPhoto(int id, Uint8List bytes, String filename) => guard(() async {
        final form = FormData.fromMap({'file': MultipartFile.fromBytes(bytes, filename: filename)});
        final r = await _dio.post('/api/vehicles/$id/photo', data: form);
        return Vehicle.fromJson(r.data as Map<String, dynamic>);
      });

  /// Staff only. Goes back to the default picture of the category.
  Future<Vehicle> removePhoto(int id) => guard(() async {
        final r = await _dio.delete('/api/vehicles/$id/photo');
        return Vehicle.fromJson(r.data as Map<String, dynamic>);
      });

  Future<void> delete(int id) => guard(() async {
        await _dio.delete('/api/vehicles/$id');
      });
}
