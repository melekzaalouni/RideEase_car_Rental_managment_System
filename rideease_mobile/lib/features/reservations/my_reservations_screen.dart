import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/format.dart';
import '../../core/models/enums.dart';
import '../../core/models/models.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/vehicle_image.dart';
import 'reservation_providers.dart';

class MyReservationsScreen extends ConsumerStatefulWidget {
  const MyReservationsScreen({super.key});

  @override
  ConsumerState<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends ConsumerState<MyReservationsScreen> {
  bool _showActive = true;

  Future<void> _cancel(Reservation r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel reservation?'),
        content: Text('Reservation #${r.id} will be cancelled.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep it')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cancel it', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(reservationRepoProvider).cancel(r.id);
      ref.invalidate(myReservationsProvider);
      if (mounted) showSnack(context, 'Reservation cancelled');
    } on ApiException catch (e) {
      if (mounted) showSnack(context, e.display, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(myReservationsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My trips')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, label: Text('Active'), icon: Icon(Icons.bolt)),
                  ButtonSegment(value: false, label: Text('History'), icon: Icon(Icons.history)),
                ],
                selected: {_showActive},
                onSelectionChanged: (s) => setState(() => _showActive = s.first),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => ref.refresh(myReservationsProvider.future),
              child: async.when(
                loading: () => ListView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  children: const [ShimmerList(count: 3, height: 150)],
                ),
                error: (e, _) => ListView(
                  children: [
                    SizedBox(
                      height: 400,
                      child: ErrorView(message: errorText(e), onRetry: () => ref.invalidate(myReservationsProvider)),
                    ),
                  ],
                ),
                data: (all) {
                  final items = all.where((r) => r.status.isActive == _showActive).toList();
                  if (items.isEmpty) {
                    return ListView(
                      children: [
                        SizedBox(
                          height: 400,
                          child: _showActive
                              ? const EmptyState(
                                  icon: Icons.luggage,
                                  title: 'No active trips',
                                  message: 'Browse the fleet and book your first ride.',
                                )
                              : const EmptyState(icon: Icons.history, title: 'No past trips'),
                        ),
                      ],
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (_, i) => _TripCard(
                      reservation: items[i],
                      onCancel: () => _cancel(items[i]),
                      onPay: () => context.push('/pay/${items[i].id}'),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard({required this.reservation, required this.onCancel, required this.onPay});
  final Reservation reservation;
  final VoidCallback onCancel, onPay;

  @override
  Widget build(BuildContext context) {
    final r = reservation;
    final cat = r.vehicle?.category ?? VehicleCategory.economy;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: 64,
                    height: 46,
                    child: VehicleImage(photoUrl: r.vehicle?.photoUrl, category: cat),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.vehicle?.title ?? r.vehiclePlate,
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('#${r.id} • ${r.vehiclePlate}',
                          style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                    ],
                  ),
                ),
                StatusPill(label: r.status.label, color: r.status.color),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: AppColors.muted),
                const SizedBox(width: 8),
                Expanded(child: Text('${dateShort(r.startDate)} → ${dateShort(r.endDate)}')),
                Text('${r.nights} night${r.nights > 1 ? 's' : ''}', style: const TextStyle(color: AppColors.muted)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total', style: TextStyle(color: AppColors.muted)),
                Text(money(r.totalPrice),
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800)),
              ],
            ),
            if (r.status.isActive) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(minimumSize: const Size(88, 46)),
                      onPressed: onCancel,
                      child: const Text('Cancel', style: TextStyle(color: AppColors.danger)),
                    ),
                  ),
                  if (r.status == ReservationStatus.pending) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(minimumSize: const Size(88, 46)),
                        onPressed: onPay,
                        child: const Text('Pay now'),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
