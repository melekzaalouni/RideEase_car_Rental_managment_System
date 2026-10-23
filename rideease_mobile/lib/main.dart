import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/storage/token_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = TokenStore();
  await store.load();
  runApp(ProviderScope(
    overrides: [tokenStoreProvider.overrideWithValue(store)],
    child: const RideEaseApp(),
  ));
}
