import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/format.dart';
import '../../core/models/models.dart';
import '../../core/network/api_exception.dart';
import '../../core/paging.dart';
import '../../core/theme.dart';
import '../../core/widgets/common.dart';
import '../auth/auth_controller.dart';
import 'admin_repository.dart';

class UserListNotifier extends PagedNotifier<AppUser> {
  @override
  Future<PageData<AppUser>> fetch(int page) => ref.read(adminRepoProvider).users(page);
}

final userListProvider = AsyncNotifierProvider<UserListNotifier, PagedState<AppUser>>(UserListNotifier.new);

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.hasClients && _scroll.position.pixels >= _scroll.position.maxScrollExtent - 320) {
        ref.read(userListProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _toggle(AppUser u, bool v) async {
    try {
      await ref.read(adminRepoProvider).setEnabled(u.id, v);
    } on ApiException catch (e) {
      if (mounted) showSnack(context, e.display, isError: true);
    }
    ref.invalidate(userListProvider); // reload so the switch shows the real value
  }

  Future<void> _roles(AppUser u) async {
    final me = ref.read(authProvider)?.username;
    final selected = {...u.roles};
    final result = await showDialog<Set<String>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text('Roles for ${u.username}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final r in const ['ADMIN', 'EMPLOYEE', 'CUSTOMER'])
                CheckboxListTile(
                  value: selected.contains(r),
                  title: Text(r),
                  onChanged: (v) => setS(() => v == true ? selected.add(r) : selected.remove(r)),
                ),
              if (u.username == me)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text('This is your own account: removing ADMIN will remove your admin tabs.',
                      style: TextStyle(color: AppColors.warning, fontSize: 12)),
                ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            TextButton(
              onPressed: selected.isEmpty ? null : () => Navigator.pop(ctx, selected),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (result == null) return;
    try {
      await ref.read(adminRepoProvider).updateRoles(u.id, result);
      ref.invalidate(userListProvider);
      if (mounted) showSnack(context, 'Roles updated');
    } on ApiException catch (e) {
      if (mounted) showSnack(context, e.display, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(userListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(userListProvider.future),
        child: async.when(
          loading: () => ListView(padding: const EdgeInsets.all(20), children: const [ShimmerList(count: 5, height: 88)]),
          error: (e, _) => ListView(children: [
            SizedBox(height: 400, child: ErrorView(message: errorText(e), onRetry: () => ref.invalidate(userListProvider))),
          ]),
          data: (page) => ListView.separated(
            controller: _scroll,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            itemCount: page.items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final u = page.items[i];
              return Card(
                child: ListTile(
                  onTap: () => _roles(u),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                    child: Text(initials(u.username),
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(u.username, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(u.email, style: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 6),
                      Wrap(spacing: 6, runSpacing: 4, children: [
                        for (final r in u.roles) StatusPill(label: r, color: AppColors.primary),
                      ]),
                    ],
                  ),
                  trailing: Switch(value: u.enabled, onChanged: (v) => _toggle(u, v)),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
