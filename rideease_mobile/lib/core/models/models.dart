import 'enums.dart';

double _d(dynamic x) {
  if (x is num) return x.toDouble();
  if (x is String) return double.tryParse(x) ?? 0;
  return 0;
}

int _i(dynamic x) {
  if (x is num) return x.toInt();
  if (x is String) return int.tryParse(x) ?? 0;
  return 0;
}

DateTime? _t(dynamic x) => x is String ? DateTime.tryParse(x) : null;

class Vehicle {
  const Vehicle({
    required this.id,
    required this.licensePlate,
    required this.brand,
    required this.model,
    required this.category,
    required this.dailyRate,
    required this.status,
    required this.year,
    required this.version,
    this.photoUrl,
  });

  final int id;
  final String licensePlate, brand, model;
  final VehicleCategory category;
  final double dailyRate;
  final VehicleStatus status;
  final int year;
  final int version;

  /// Server-relative URL of the uploaded photo, null = use the default picture of the category.
  final String? photoUrl;

  String get title => '$brand $model';

  factory Vehicle.fromJson(Map<String, dynamic> j) {
    final id = _i(j['id']);
    // /api/vehicles answers with `photoUrl`; a vehicle nested in a reservation carries the raw `photoFile`.
    String? photo;
    final url = j['photoUrl'];
    final file = j['photoFile'];
    if (url is String && url.isNotEmpty) {
      photo = url;
    } else if (file is String && file.isNotEmpty) {
      photo = '/api/vehicles/$id/photo?v=$file';
    }
    return Vehicle(
      id: id,
      licensePlate: (j['licensePlate'] ?? '').toString(),
      brand: (j['brand'] ?? '').toString(),
      model: (j['model'] ?? '').toString(),
      category: VehicleCategory.parse(j['category']?.toString()),
      dailyRate: _d(j['dailyRate']),
      status: VehicleStatus.parse(j['status']?.toString()),
      year: _i(j['yearOfManufacture']),
      version: _i(j['version']),
      photoUrl: photo,
    );
  }
}

class Customer {
  const Customer({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.license,
    this.since,
  });

  final int id;
  final String username, firstName, lastName, email, phone, license;
  final DateTime? since;

  String get fullName => '$firstName $lastName'.trim();

  factory Customer.fromJson(Map<String, dynamic> j) => Customer(
        id: _i(j['id']),
        username: (j['username'] ?? '').toString(),
        firstName: (j['firstName'] ?? '').toString(),
        lastName: (j['lastName'] ?? '').toString(),
        email: (j['email'] ?? '').toString(),
        phone: (j['phoneNumber'] ?? '').toString(),
        license: (j['driverLicenseNumber'] ?? '').toString(),
        since: _t(j['registrationDate']),
      );
}

/// The backend returns the full Customer and Vehicle entities nested in a reservation.
class Reservation {
  const Reservation({
    required this.id,
    required this.customer,
    required this.vehicle,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.status,
  });

  final int id;
  final Customer? customer;
  final Vehicle? vehicle;
  final DateTime startDate, endDate;
  final double totalPrice;
  final ReservationStatus status;

  int get nights => endDate.difference(startDate).inDays;
  int get vehicleId => vehicle?.id ?? 0;
  String get vehiclePlate => vehicle?.licensePlate ?? '';

  factory Reservation.fromJson(Map<String, dynamic> j) => Reservation(
        id: _i(j['id']),
        customer: j['customer'] is Map<String, dynamic> ? Customer.fromJson(j['customer']) : null,
        vehicle: j['vehicle'] is Map<String, dynamic> ? Vehicle.fromJson(j['vehicle']) : null,
        startDate: DateTime.parse(j['startDate'].toString()),
        endDate: DateTime.parse(j['endDate'].toString()),
        totalPrice: _d(j['totalPrice']),
        status: ReservationStatus.parse(j['status']?.toString()),
      );
}

class Payment {
  const Payment({
    required this.id,
    required this.reservationId,
    required this.amount,
    required this.method,
    required this.status,
  });

  final int id, reservationId;
  final double amount;
  final String method, status;

  factory Payment.fromJson(Map<String, dynamic> j) => Payment(
        id: _i(j['id']),
        reservationId: j['reservation'] is Map ? _i((j['reservation'] as Map)['id']) : 0,
        amount: _d(j['amount']),
        method: (j['paymentMethod'] ?? '').toString(),
        status: (j['paymentStatus'] ?? '').toString(),
      );
}

class AppUser {
  const AppUser({
    required this.id,
    required this.username,
    required this.email,
    required this.enabled,
    required this.roles,
  });

  final int id;
  final String username, email;
  final bool enabled;
  final List<String> roles;

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
        id: _i(j['id']),
        username: (j['username'] ?? '').toString(),
        email: (j['email'] ?? '').toString(),
        enabled: j['enabled'] == true,
        roles: (j['roles'] is List)
            ? (j['roles'] as List).map((e) => e.toString().replaceFirst('ROLE_', '')).toList()
            : <String>[],
      );
}

class Dashboard {
  const Dashboard(this.raw);
  final Map<String, dynamic> raw;

  int get customers => _i(raw['totalCustomers']);
  int get vehicles => _i(raw['totalVehicles']);
  int get available => _i(raw['availableVehicles']);
  int get rented => _i(raw['rentedVehicles']);
  int get maintenance => _i(raw['maintenanceVehicles']);
  int get pending => _i(raw['pendingReservations']);
  int get confirmed => _i(raw['confirmedReservations']);
  int get cancelled => _i(raw['cancelledReservations']);
  int get payments => _i(raw['totalPayments']);
  double get revenue => _d(raw['revenue']);
}

/// Roles are stored WITHOUT the ROLE_ prefix: ADMIN, EMPLOYEE, CUSTOMER.
class Session {
  const Session({
    required this.token,
    required this.username,
    required this.roles,
    this.customerId,
  });

  final String token, username;
  final List<String> roles;
  final int? customerId;

  bool get isAdmin => roles.contains('ADMIN');
  bool get isStaff => isAdmin || roles.contains('EMPLOYEE');
}

/// Accepts a plain list, or a page object. The backend's page uses the keys
/// `cintent` / `totalElemnts` (typos), so both spellings are read.
class PageData<T> {
  const PageData({required this.content, required this.page, required this.last});
  final List<T> content;
  final int page;
  final bool last;

  static PageData<T> parse<T>(dynamic json, T Function(Map<String, dynamic>) conv) {
    if (json is List) {
      return PageData(content: json.whereType<Map<String, dynamic>>().map(conv).toList(), page: 0, last: true);
    }
    if (json is Map<String, dynamic>) {
      final raw = json['content'] ?? json['cintent'] ?? const [];
      final list = (raw as List).whereType<Map<String, dynamic>>().map(conv).toList();
      final page = _i(json['page']);
      final totalPages = _i(json['totalPages']);
      final last = json['last'] is bool ? json['last'] as bool : (page + 1 >= totalPages);
      return PageData(content: list, page: page, last: last);
    }
    return PageData(content: <T>[], page: 0, last: true);
  }
}
