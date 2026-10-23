import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/enums.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/user_avatar.dart';
import '../auth/auth_controller.dart';
import 'filter_sheet.dart';
import 'vehicle_card.dart';
import 'vehicle_providers.dart';

class VehiclesScreen extends ConsumerStatefulWidget {
  const VehiclesScreen({super.key, required this.manage});
  final bool manage;

  @override
  ConsumerState<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends ConsumerState<VehiclesScreen> {
  final _scroll = ScrollController();
  final _search = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.hasClients && _scroll.position.pixels >= _scroll.position.maxScrollExtent - 320) {
        ref.read(vehicleListProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scroll.dispose();
    _search.dispose();
    super.dispose();
  }

  void _onSearch(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      final t = text.trim();
      ref.read(vehicleFilterProvider.notifier).patch((f) => f.copyWith(brand: t.isEmpty ? null : t));
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authProvider);
    final filter = ref.watch(vehicleFilterProvider);
    final list = ref.watch(vehicleListProvider);
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      floatingActionButton: widget.manage
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/vehicle-form'),
              icon: const Icon(Icons.add),
              label: const Text('Add vehicle'),
            )
          : null,
      body: RefreshIndicator(
        edgeOffset: 140,
        onRefresh: () async => ref.refresh(vehicleListProvider.future),
        child: CustomScrollView(
          controller: _scroll,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.fromLTRB(20, top + 16, 20, 20),
                decoration: const BoxDecoration(
                  gradient: heroGradient,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.manage ? 'Fleet management' : 'Hi, ${session?.username ?? ''}',
                                style: const TextStyle(color: Colors.white70, fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.manage ? 'Manage vehicles' : 'Find your ride',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                        UserAvatar(name: session?.username ?? '', radius: 22),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _search,
                            onChanged: _onSearch,
                            style: const TextStyle(color: AppColors.ink),
                            decoration: const InputDecoration(
                              hintText: 'Brand, e.g. Toyota',
                              hintStyle: TextStyle(color: AppColors.muted),
                              prefixIcon: Icon(Icons.search, color: AppColors.muted),
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 54,
                          height: 54,
                          child: Material(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(14),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () => showFilterSheet(context),
                              child: Center(
                                child: Badge(
                                  isLabelVisible: filter.activeCount > 0,
                                  label: Text('${filter.activeCount}'),
                                  child: const Icon(Icons.tune, color: AppColors.ink),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 66,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: const Text('All'),
                        selected: filter.category == null,
                        onSelected: (_) =>
                            ref.read(vehicleFilterProvider.notifier).patch((f) => f.copyWith(category: null)),
                      ),
                    ),
                    for (final c in VehicleCategory.values)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          avatar: Icon(c.icon, size: 18),
                          label: Text(c.label),
                          selected: filter.category == c,
                          onSelected: (_) =>
                              ref.read(vehicleFilterProvider.notifier).patch((f) => f.copyWith(category: c)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            list.when(
              loading: () => const SliverPadding(
                padding: EdgeInsets.fromLTRB(20, 4, 20, 0),
                sliver: SliverToBoxAdapter(child: ShimmerList(count: 3, height: 230)),
              ),
              error: (e, _) => SliverFillRemaining(
                hasScrollBody: false,
                child: ErrorView(message: errorText(e), onRetry: () => ref.invalidate(vehicleListProvider)),
              ),
              data: (page) {
                if (page.items.isEmpty) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      icon: Icons.search_off,
                      title: 'No vehicles found',
                      message: 'Try another brand or remove some filters.',
                    ),
                  );
                }
                final extra = page.loadingMore ? 1 : 0;
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                  sliver: SliverList.separated(
                    itemCount: page.items.length + extra,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (_, i) {
                      if (i >= page.items.length) {
                        return const Padding(
                          padding: EdgeInsets.all(12),
                          child: Center(
                            child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.4)),
                          ),
                        );
                      }
                      final v = page.items[i];
                      return VehicleCard(vehicle: v, onTap: () => context.push('/vehicle/${v.id}'));
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
