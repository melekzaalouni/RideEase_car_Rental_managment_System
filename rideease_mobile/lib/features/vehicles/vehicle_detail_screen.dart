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
import '../auth/auth_controller.dart';
import 'vehicle_providers.dart';

class VehicleDetailScreen extends ConsumerWidget {
  const VehicleDetailScreen({super.key, required this.vehicleId});
  final int vehicleId;

  Future<void> _delete(BuildContext context, WidgetRef ref, Vehicle v) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete vehicle?'),
        content: Text('${v.title} (${v.licensePlate}) will be removed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(vehicleRepoProvider).delete(v.id);
      ref.invalidate(vehicleListProvider);
      if (context.mounted) context.pop();
    } on ApiException catch (e) {
      if (context.mounted) {
        showSnack(
          context,
          e.status == 500 ? 'Cannot delete: reservations still reference this vehicle' : e.display,
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(vehicleProvider(vehicleId));
    final session = ref.watch(authProvider);
    final staff = session?.isStaff ?? false;
    final admin = session?.isAdmin ?? false;

    return async.when(
      loading: () => Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: ErrorView(message: errorText(e), onRetry: () => ref.invalidate(vehicleProvider(vehicleId))),
      ),
      data: (v) {
        final maint = v.status == VehicleStatus.maintenance;
        return Scaffold(
          bottomNavigationBar: staff
              ? null
              : Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                      child: Row(
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('From', style: TextStyle(color: AppColors.muted, fontSize: 12)),
                              Text('${money(v.dailyRate)} / day', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: PrimaryButton(
                              label: maint ? 'In maintenance' : 'Reserve now',
                              icon: Icons.event,
                              onPressed: maint ? null : () => context.push('/book/${v.id}'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 280,
                backgroundColor: v.category.c2,
                foregroundColor: Colors.white,
                iconTheme: const IconThemeData(color: Colors.white),
                actions: [
                  if (staff)
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => context.push('/vehicle-form', extra: v),
                    ),
                  if (admin)
                    IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _delete(context, ref, v)),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      VehicleImage(photoUrl: v.photoUrl, category: v.category),
                      // darkens the top so the white back / edit / delete icons stay readable
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.center,
                            colors: [Color(0x99000000), Color(0x00000000)],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              v.title,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ),
                          StatusPill(label: v.status.label, color: v.status.color),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('${v.category.label} • ${v.year}', style: const TextStyle(color: AppColors.muted)),
                      const SizedBox(height: 20),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 2.3,
                        children: [
                          _Spec(icon: Icons.payments_outlined, label: 'Daily rate', value: money(v.dailyRate)),
                          _Spec(icon: Icons.calendar_today, label: 'Year', value: '${v.year}'),
                          _Spec(icon: v.category.icon, label: 'Category', value: v.category.label),
                          _Spec(icon: Icons.pin_outlined, label: 'Plate', value: v.licensePlate),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text('Good to know',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      const _Tip('Price = daily rate x nights, confirmed by the server'),
                      const _Tip('Minimum rental: 1 night'),
                      const _Tip('Cancel while pending or confirmed'),
                      if (v.status == VehicleStatus.rented)
                        const _Tip('Currently rented, but other dates may still be free'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Spec extends StatelessWidget {
  const _Spec({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label, value;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                    Text(value, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _Tip extends StatelessWidget {
  const _Tip(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(text)),
          ],
        ),
      );
}
