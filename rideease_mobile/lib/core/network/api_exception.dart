import 'package:dio/dio.dart';

class ApiException implements Exception {
  ApiException({this.status, required this.code, required this.message, this.fieldErrors = const []});

  final int? status;
  final String code;
  final String message;
  final List<String> fieldErrors;

  /// Field errors joined by new lines, or the message.
  String get display => fieldErrors.isNotEmpty ? fieldErrors.join('\n') : message;

  factory ApiException.from(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    if (data is Map) {
      final fe = data['fieldErrors'];
      final list = fe is List ? fe.map((x) => x.toString()).toList() : <String>[];
      final msg = data['message']?.toString();
      if ((msg != null && msg.isNotEmpty) || list.isNotEmpty) {
        return ApiException(
          status: status,
          code: status == 409 ? 'CONFLICT' : (data['error']?.toString() ?? 'ERROR'),
          message: (msg != null && msg.isNotEmpty) ? msg : list.join('\n'),
          fieldErrors: list,
        );
      }
    }
    if (data is String && data.isNotEmpty && status != null && status < 500) {
      return ApiException(status: status, code: 'ERROR', message: data);
    }
    const net = {
      DioExceptionType.connectionTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.connectionError,
    };
    if (net.contains(e.type)) {
      return ApiException(
        status: status,
        code: 'NETWORK',
        message: 'Cannot reach the server. Check your connection',
      );
    }
    final msg = switch (status) {
      401 => 'Please sign in again',
      403 => 'You are not allowed to do this',
      404 => 'Not found',
      _ => 'Unexpected error ($status)',
    };
    return ApiException(status: status, code: 'HTTP_${status ?? 0}', message: msg);
  }

  @override
  String toString() => message;
}

String errorText(Object e) =>
    e is ApiException ? e.display : 'Something went wrong. Please try again.';
