import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/format.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/vehicle_image.dart';
import '../auth/auth_controller.dart';
import '../vehicles/vehicle_providers.dart';
import 'reservation_providers.dart';

class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key, required this.vehicleId});
  final int vehicleId;

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  DateTimeRange? _range;
  bool _busy = false;

  int get _nights => _range == null ? 0 : _range!.end.difference(_range!.start).inDays;

  Future<void> _pick() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final r = await showDateRangePicker(
      context: context,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
      initialDateRange: _range,
    );
    if (r != null) setState(() => _range = r);
  }

  Future<void> _submit(int customerId) async {
    if (_nights < 1) {
      showSnack(context, 'Pick at least one night', isError: true);
      return;
    }
    setState(() => _busy = true);
    try {
      final r = await ref
          .read(reservationRepoProvider)
          .create(customerId, widget.vehicleId, _range!.start, _range!.end);
      ref.invalidate(myReservationsProvider);
      if (!mounted) return;
      context.pushReplacement('/pay/${r.id}');
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.status == 409) {
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            icon: const Icon(Icons.event_busy, color: AppColors.danger, size: 36),
            title: const Text('Not available'),
            content: const Text(
              'This vehicle is already booked for those dates (or someone just booked it). '
              'Please choose different dates.',
            ),
            actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Change dates'))],
          ),
        );
      } else {
        showSnack(context, e.display, isError: true);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vAsync = ref.watch(vehicleProvider(widget.vehicleId));
    final customerId = ref.watch(authProvider)?.customerId;

    return Scaffold(
      appBar: AppBar(title: const Text('Book your ride')),
      body: vAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(message: errorText(e), onRetry: () => ref.invalidate(vehicleProvider(widget.vehicleId))),
        data: (v) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: 72,
                    height: 56,
                    child: VehicleImage(photoUrl: v.photoUrl, category: v.category),
                  ),
                ),
                title: Text(v.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${v.category.label} • ${v.licensePlate}'),
                trailing: Text(money(v.dailyRate),
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(height: 20),
            Text('Rental period',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: _pick,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _range != null ? AppColors.primary : AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _range == null
                          ? const Text('Select pickup & return dates', style: TextStyle(color: AppColors.muted))
                          : Text('${dateShort(_range!.start)} → ${dateShort(_range!.end)}',
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_nights > 0) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${money(v.dailyRate)} x $_nights night${_nights > 1 ? 's' : ''}'),
                          Text(money(v.dailyRate * _nights)),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Estimated total',
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 18)),
                          Text(money(v.dailyRate * _nights),
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 18)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('The final amount is calculated by the server.',
                            style: TextStyle(color: AppColors.muted, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
            if (customerId == null)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'Your account has no customer profile linked. Sign out and sign in again '
                  '(the backend must return customerId at login).',
                ),
              )
            else
              PrimaryButton(label: 'Confirm reservation', loading: _busy, onPressed: () => _submit(customerId)),
          ],
        ),
      ),
    );
  }
}
