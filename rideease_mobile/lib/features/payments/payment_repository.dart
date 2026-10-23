import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/enums.dart';
import '../../core/models/models.dart';
import '../../core/network/api_client.dart';

class PaymentRepository {
  PaymentRepository(this._dio);
  final Dio _dio;

  Future<Payment> pay(int reservationId, double amount, PaymentMethod method) => guard(() async {
        final r = await _dio.post('/api/payments', data: {
          'reservationId': reservationId,
          'amount': amount,
          'paymentMethod': method.api,
        });
        return Payment.fromJson(r.data as Map<String, dynamic>);
      });
}

final paymentRepoProvider = Provider<PaymentRepository>((ref) => PaymentRepository(ref.watch(dioProvider)));
