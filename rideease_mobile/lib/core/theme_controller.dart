import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Light / dark / system theme choice, remembered on the device.
class ThemeController extends StateNotifier<ThemeMode> {
  ThemeController() : super(ThemeMode.system) {
    _load();
  }

  static const _key = 'themeMode';
  final _storage = const FlutterSecureStorage();

  Future<void> _load() async {
    try {
      final saved = await _storage.read(key: _key);
      state = ThemeMode.values.firstWhere((m) => m.name == saved, orElse: () => ThemeMode.system);
    } catch (_) {
      // keep the default (system) if storage is unavailable
    }
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    try {
      await _storage.write(key: _key, value: mode.name);
    } catch (_) {
      // the choice still applies for this session
    }
  }
}

final themeModeProvider = StateNotifierProvider<ThemeController, ThemeMode>((ref) => ThemeController());

/// Icon button that flips between the light and the dark theme.
class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key, this.color});
  final Color? color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return IconButton(
      tooltip: dark ? 'Switch to light theme' : 'Switch to dark theme',
      onPressed: () => ref.read(themeModeProvider.notifier).set(dark ? ThemeMode.light : ThemeMode.dark),
      icon: Icon(dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined, color: color),
    );
  }
}
