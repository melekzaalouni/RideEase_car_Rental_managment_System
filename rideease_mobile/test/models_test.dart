import 'package:flutter_test/flutter_test.dart';
import 'package:rideease_mobile/core/models/enums.dart';
import 'package:rideease_mobile/core/models/models.dart';

void main() {
  test('Vehicle.fromJson maps the backend keys', () {
    final v = Vehicle.fromJson({
      'id': 3,
      'licensePlate': '123 TUN 456',
      'brand': 'Toyota',
      'model': 'Yaris',
      'category': 'ECONOMY',
      'dailyRate': 89,
      'status': 'AVAILABLE',
      'yearOfManufacture': 2022,
      'version': 0,
    });
    expect(v.title, 'Toyota Yaris');
    expect(v.dailyRate, 89.0);
    expect(v.year, 2022);
    expect(v.category, VehicleCategory.economy);
    expect(v.status, VehicleStatus.available);
  });

  test('Vehicle photo: photoUrl, nested photoFile, or none', () {
    final base = {'id': 7, 'brand': 'Kia', 'model': 'Rio', 'category': 'COMPACT', 'dailyRate': 70};
    expect(Vehicle.fromJson({...base}).photoUrl, isNull);
    expect(Vehicle.fromJson({...base, 'photoUrl': '/api/vehicles/7/photo?v=a.jpg'}).photoUrl,
        '/api/vehicles/7/photo?v=a.jpg');
    expect(Vehicle.fromJson({...base, 'photoFile': 'b.png'}).photoUrl, '/api/vehicles/7/photo?v=b.png');
    expect(VehicleCategory.suv.photoAsset, 'assets/images/vehicles/suv.jpg');
  });

  test('PageData reads the backend page (typo keys) and plain lists', () {
    final page = PageData.parse<AppUser>({
      'cintent': [
        {'id': 1, 'username': 'admin', 'email': 'a@b.c', 'enabled': true, 'roles': ['ADMIN']}
      ],
      'page': 0,
      'totalPages': 1,
    }, AppUser.fromJson);
    expect(page.content.single.roles, ['ADMIN']);
    expect(page.last, true);

    final list = PageData.parse<AppUser>([], AppUser.fromJson);
    expect(list.content, isEmpty);
  });

  test('Reservation nights', () {
    final r = Reservation.fromJson({
      'id': 1,
      'startDate': '2026-06-10',
      'endDate': '2026-06-15',
      'totalPrice': 445.0,
      'status': 'PENDING',
      'vehicle': {'id': 3, 'brand': 'Toyota', 'model': 'Yaris', 'category': 'ECONOMY', 'status': 'AVAILABLE'},
    });
    expect(r.nights, 5);
    expect(r.vehicle!.title, 'Toyota Yaris');
  });
}
