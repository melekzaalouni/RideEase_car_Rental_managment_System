import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/format.dart';
import '../../core/models/enums.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme.dart';
import '../../core/widgets/common.dart';
import '../home/home_shell.dart';
import '../reservations/reservation_providers.dart';
import '../vehicles/vehicle_providers.dart';
import 'payment_repository.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key, required this.reservationId});
  final int reservationId;

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  PaymentMethod _method = PaymentMethod.creditCard;
  bool _busy = false;

  Future<void> _pay(double total) async {
    setState(() => _busy = true);
    try {
      await ref.read(paymentRepoProvider).pay(widget.reservationId, total, _method);
      ref.invalidate(myReservationsProvider);
      ref.invalidate(vehicleListProvider);
      HapticFeedback.lightImpact();
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: AppColors.success, size: 56),
          title: const Text('Payment confirmed'),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('View my trips'))],
        ),
      );
      if (!mounted) return;
      ref.read(homeTabProvider.notifier).state = 1; // "My trips" (customers)
      context.go('/home');
    } on ApiException catch (e) {
      if (mounted) showSnack(context, e.display, isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(reservationProvider(widget.reservationId));
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          message: errorText(e),
          onRetry: () => ref.invalidate(reservationProvider(widget.reservationId)),
        ),
        data: (r) {
          final summary = Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(gradient: heroGradient, borderRadius: BorderRadius.circular(24)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.vehicle?.title ?? r.vehiclePlate,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
                const SizedBox(height: 4),
                Text(
                  '${dateShort(r.startDate)} → ${dateShort(r.endDate)} • ${r.nights} night${r.nights > 1 ? 's' : ''}',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 20),
                const Text('Total to pay', style: TextStyle(color: Colors.white70)),
                Text(money(r.totalPrice),
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
              ],
            ),
          );

          if (r.status != ReservationStatus.pending) {
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                summary,
                const SizedBox(height: 40),
                EmptyState(
                  icon: Icons.info_outline,
                  title: 'Nothing to pay',
                  message: 'This reservation is ${r.status.label.toLowerCase()}.',
                ),
              ],
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              summary,
              const SizedBox(height: 24),
              Text('Payment method',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              for (final m in PaymentMethod.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => setState(() => _method = m),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: _method == m ? AppColors.primary.withValues(alpha: 0.08) : null,
                        border: Border.all(
                          color: _method == m ? AppColors.primary : AppColors.border,
                          width: _method == m ? 1.8 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(m.icon),
                          const SizedBox(width: 14),
                          Expanded(child: Text(m.label, style: const TextStyle(fontWeight: FontWeight.bold))),
                          Icon(
                            _method == m ? Icons.radio_button_checked : Icons.radio_button_off,
                            color: _method == m ? AppColors.primary : AppColors.muted,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 6),
              const Text(
                'Demo project: no card data is collected. The chosen method is only recorded.',
                style: TextStyle(color: AppColors.muted, fontSize: 12),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Pay ${money(r.totalPrice)}',
                icon: Icons.lock,
                loading: _busy,
                onPressed: () => _pay(r.totalPrice),
              ),
            ],
          );
        },
      ),
    );
  }
}
