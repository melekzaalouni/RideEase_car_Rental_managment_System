import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/format.dart';
import '../../core/media/photo_picker.dart';
import '../../core/theme.dart';
import '../../core/theme_controller.dart';
import '../../core/network/api_exception.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/user_avatar.dart';
import '../auth/auth_controller.dart';
import 'profile_repository.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _changePhoto(BuildContext context, WidgetRef ref) async {
    final hasPhoto = ref.read(myPhotoProvider).valueOrNull != null;
    final pick = await askForPhoto(context, canRemove: hasPhoto);
    if (pick == null) return;
    final repo = ref.read(profileRepoProvider);
    try {
      if (pick.remove) {
        await repo.removePhoto();
      } else {
        await repo.uploadPhoto(pick.image!.bytes, pick.image!.name);
      }
      ref.invalidate(myPhotoProvider);
      if (context.mounted) showSnack(context, pick.remove ? 'Profile photo removed' : 'Profile photo updated');
    } on ApiException catch (e) {
      if (context.mounted) showSnack(context, e.display, isError: true);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(authProvider);
    if (s == null) return const SizedBox.shrink();
    final customer = s.isStaff ? null : ref.watch(myCustomerProvider);
    final name = customer?.valueOrNull?.fullName.isNotEmpty == true ? customer!.value!.fullName : s.username;

    Widget tile(IconData icon, String label, String value) => ListTile(
          leading: Icon(icon, color: AppColors.primary),
          title: Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
          subtitle: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        );

    final tiles = <Widget>[tile(Icons.person_outline, 'Username', s.username)];
    if (customer != null) {
      tiles.add(customer.when(
        loading: () => const Padding(padding: EdgeInsets.all(16), child: LinearProgressIndicator()),
        error: (e, _) => ListTile(
          leading: const Icon(Icons.warning_amber, color: AppColors.warning),
          title: Text(s.customerId == null
              ? 'No customer profile linked to this account'
              : errorText(e)),
        ),
        data: (c) => Column(
          children: [
            tile(Icons.mail_outline, 'Email', c.email),
            tile(Icons.phone_outlined, 'Phone', c.phone),
            tile(Icons.badge_outlined, 'Driver license', c.license),
            tile(Icons.event, 'Member since', c.since == null ? '-' : dateShort(c.since!)),
          ],
        ),
      ));
    }

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 24, 20, 28),
          decoration: const BoxDecoration(
            gradient: heroGradient,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
          ),
          child: Column(
            children: [
              GestureDetector(
                onTap: () => _changePhoto(context, ref),
                child: Stack(
                  children: [
                    UserAvatar(name: name, radius: 48),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.photo_camera, size: 18, color: AppColors.ink),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(name,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final r in s.roles)
                    Chip(
                      label: Text(r, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Card(child: Column(children: tiles)),
              const SizedBox(height: 16),
              const _AppearanceCard(),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign out'),
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Sign out?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Sign out', style: TextStyle(color: AppColors.danger)),
                          ),
                        ],
                      ),
                    );
                    if (ok == true) ref.read(authProvider.notifier).logout();
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AppearanceCard extends ConsumerWidget {
  const _AppearanceCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.palette_outlined, color: AppColors.primary),
                SizedBox(width: 12),
                Text('Appearance', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<ThemeMode>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.brightness_auto_outlined), label: Text('Auto')),
                  ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode_outlined), label: Text('Light')),
                  ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode_outlined), label: Text('Dark')),
                ],
                selected: {mode},
                onSelectionChanged: (s) => ref.read(themeModeProvider.notifier).set(s.first),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
