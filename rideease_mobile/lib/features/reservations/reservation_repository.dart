import 'package:dio/dio.dart';
import '../../core/format.dart';
import '../../core/models/models.dart';
import '../../core/network/api_client.dart';

class ReservationRepository {
  ReservationRepository(this._dio);
  final Dio _dio;

  Future<Reservation> create(int customerId, int vehicleId, DateTime start, DateTime end) => guard(() async {
        final r = await _dio.post('/api/reservations', data: {
          'customerId': customerId,
          'vehicleId': vehicleId,
          'startDate': apiDate(start),
          'endDate': apiDate(end),
        });
        return Reservation.fromJson(r.data as Map<String, dynamic>);
      });

  Future<Reservation> byId(int id) => guard(() async {
        final r = await _dio.get('/api/reservations/$id');
        return Reservation.fromJson(r.data as Map<String, dynamic>);
      });

  /// The backend lists reservations per customer id (no /me endpoint).
  Future<List<Reservation>> mine(int customerId) => guard(() async {
        final r = await _dio.get('/api/reservations/customers/$customerId');
        return PageData.parse(r.data, Reservation.fromJson).content;
      });

  Future<void> cancel(int id) => guard(() async {
        await _dio.put('/api/reservations/$id/cancel');
      });
}
