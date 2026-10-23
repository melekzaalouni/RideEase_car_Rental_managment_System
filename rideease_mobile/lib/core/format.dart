import 'package:intl/intl.dart';
import 'config.dart';

String money(num n) => '${NumberFormat('#,##0.00').format(n)} ${AppConfig.currency}';
String dateShort(DateTime d) => DateFormat('d MMM y').format(d);
String apiDate(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

String initials(String text) {
  final parts = text.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  return parts.take(2).map((e) => e[0].toUpperCase()).join();
}
