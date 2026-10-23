import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/format.dart';
import '../../core/models/models.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme.dart';
import '../../core/widgets/common.dart';
import 'admin_repository.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(dashboardProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(dashboardProvider.future),
        child: async.when(
          loading: () => ListView(padding: const EdgeInsets.all(20), children: const [ShimmerList(count: 4, height: 110)]),
          error: (e, _) => ListView(children: [
            SizedBox(height: 400, child: ErrorView(message: errorText(e), onRetry: () => ref.invalidate(dashboardProvider))),
          ]),
          data: (d) => ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(gradient: heroGradient, borderRadius: BorderRadius.circular(24)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total revenue', style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 4),
                    Text(money(d.revenue),
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text('${d.payments} completed payments',
                        style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _FleetCard(d: d),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _Stat(icon: Icons.hourglass_bottom, color: AppColors.warning, value: d.pending, label: 'Pending')),
                  const SizedBox(width: 12),
                  Expanded(child: _Stat(icon: Icons.check_circle, color: AppColors.success, value: d.confirmed, label: 'Confirmed')),
                  const SizedBox(width: 12),
                  Expanded(child: _Stat(icon: Icons.cancel, color: AppColors.danger, value: d.cancelled, label: 'Cancelled')),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _Stat(icon: Icons.groups, color: AppColors.primary, value: d.customers, label: 'Customers')),
                  const SizedBox(width: 12),
                  Expanded(child: _Stat(icon: Icons.receipt_long, color: AppColors.accent, value: d.payments, label: 'Payments')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FleetCard extends StatelessWidget {
  const _FleetCard({required this.d});
  final Dashboard d;

  @override
  Widget build(BuildContext context) {
    final total = d.available + d.rented + d.maintenance;
    Widget dot(Color c, String t) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(t, style: const TextStyle(fontSize: 12)),
          ],
        );
    Widget block(int n, Color c) => n == 0 ? const SizedBox.shrink() : Expanded(flex: n, child: Container(color: c));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Fleet', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('${d.vehicles} vehicles', style: const TextStyle(color: AppColors.muted)),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 14,
                child: total == 0
                    ? Container(color: AppColors.border)
                    : Row(children: [
                        block(d.available, AppColors.success),
                        block(d.rented, AppColors.warning),
                        block(d.maintenance, AppColors.danger),
                      ]),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 6,
              children: [
                dot(AppColors.success, 'Available ${d.available}'),
                dot(AppColors.warning, 'Rented ${d.rented}'),
                dot(AppColors.danger, 'Maintenance ${d.maintenance}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.color, required this.value, required this.label});
  final IconData icon;
  final Color color;
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 10),
              Text('$value', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
            ],
          ),
        ),
      );
}
