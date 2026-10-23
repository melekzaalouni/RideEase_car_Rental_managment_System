import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/profile/profile_repository.dart';
import '../format.dart';
import '../theme.dart';

/// Round avatar of the signed-in user: their profile photo, or their initials.
class UserAvatar extends ConsumerWidget {
  const UserAvatar({super.key, required this.name, this.radius = 42});
  final String name;
  final double radius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bytes = ref.watch(myPhotoProvider).valueOrNull;
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white,
      backgroundImage: bytes != null ? MemoryImage(bytes) : null,
      child: bytes != null
          ? null
          : Text(
              initials(name),
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: radius * 0.62),
            ),
    );
  }
}
