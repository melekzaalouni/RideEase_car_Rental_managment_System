import 'package:flutter/material.dart';
import '../theme.dart';

enum VehicleCategory {
  economy('ECONOMY', 'Eco', Icons.directions_car, Color(0xFFEF6A6E), Color(0xFFC23035)),
  compact('COMPACT', 'Compact', Icons.directions_car_filled, Color(0xFF2DB8AC), Color(0xFF0E7C74)),
  suv('SUV', 'SUV', Icons.airport_shuttle, Color(0xFF6E9B77), Color(0xFF35604A)),
  luxury('LUXURY', 'Luxury', Icons.diamond, Color(0xFF5A4F48), Color(0xFF1D1916));

  const VehicleCategory(this.api, this.label, this.icon, this.c1, this.c2);
  final String api;
  final String label;
  final IconData icon;
  final Color c1, c2;

  /// Picture shown when a vehicle has no uploaded photo (enum names match the file names).
  String get photoAsset => 'assets/images/vehicles/$name.jpg';

  LinearGradient get gradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [c1, c2],
      );

  static VehicleCategory parse(String? s) =>
      VehicleCategory.values.firstWhere((e) => e.api == s, orElse: () => VehicleCategory.economy);
}

enum VehicleStatus {
  available('AVAILABLE', 'AVAILABLE', AppColors.success),
  rented('RENTED', 'RENTED', AppColors.warning),
  maintenance('MAINTENANCE', 'MAINTENANCE', AppColors.danger);

  const VehicleStatus(this.api, this.label, this.color);
  final String api;
  final String label;
  final Color color;

  static VehicleStatus parse(String? s) =>
      VehicleStatus.values.firstWhere((e) => e.api == s, orElse: () => VehicleStatus.available);
}

enum ReservationStatus {
  pending('PENDING', 'PENDING', AppColors.warning),
  confirmed('CONFIRMED', 'CONFIRMED', AppColors.success),
  cancelled('CANCELLED', 'CANCELLED', AppColors.danger),
  completed('COMPLETED', 'COMPLETED', AppColors.muted);

  const ReservationStatus(this.api, this.label, this.color);
  final String api;
  final String label;
  final Color color;

  bool get isActive => this == pending || this == confirmed;

  static ReservationStatus parse(String? s) =>
      ReservationStatus.values.firstWhere((e) => e.api == s, orElse: () => ReservationStatus.pending);
}

enum PaymentMethod {
  creditCard('CREDIT_CARD', 'Credit card', Icons.credit_card),
  debitCard('DEBIT_CARD', 'Debit card', Icons.payment),
  cash('CASH', 'Cash at pickup', Icons.payments_outlined);

  const PaymentMethod(this.api, this.label, this.icon);
  final String api;
  final String label;
  final IconData icon;

  static PaymentMethod parse(String? s) =>
      PaymentMethod.values.firstWhere((e) => e.api == s, orElse: () => PaymentMethod.creditCard);
}
