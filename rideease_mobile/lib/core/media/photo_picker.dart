import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/common.dart';

const maxPhotoBytes = 5 * 1024 * 1024; // same limit as the backend

class PickedImage {
  const PickedImage(this.bytes, this.name);
  final Uint8List bytes;
  final String name;
}

/// Result of [askForPhoto]: either a chosen image or a request to remove the current photo.
class PhotoPick {
  const PhotoPick.image(PickedImage this.image) : remove = false;
  const PhotoPick.removal()
      : image = null,
        remove = true;
  final PickedImage? image;
  final bool remove;
}

enum _Choice { gallery, camera, remove }

bool get _cameraAvailable =>
    !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);

/// Lets the user pick a photo from the gallery (and the camera on phones).
/// With [canRemove] a "Remove photo" entry is offered too. Returns null when cancelled.
Future<PhotoPick?> askForPhoto(BuildContext context, {bool canRemove = false}) async {
  _Choice? choice;
  if (!_cameraAvailable && !canRemove) {
    choice = _Choice.gallery; // desktop / web: go straight to the file dialog
  } else {
    choice = await showModalBottomSheet<_Choice>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(ctx, _Choice.gallery),
            ),
            if (_cameraAvailable)
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Take a photo'),
                onTap: () => Navigator.pop(ctx, _Choice.camera),
              ),
            if (canRemove)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Remove photo', style: TextStyle(color: Colors.red)),
                onTap: () => Navigator.pop(ctx, _Choice.remove),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
  if (choice == null) return null;
  if (choice == _Choice.remove) return const PhotoPick.removal();

  try {
    final file = await ImagePicker().pickImage(
      source: choice == _Choice.camera ? ImageSource.camera : ImageSource.gallery,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 85,
    );
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    if (!context.mounted) return null;
    if (bytes.length > maxPhotoBytes) {
      showSnack(context, 'Image is too large (max 5 MB)', isError: true);
      return null;
    }
    return PhotoPick.image(PickedImage(bytes, file.name.isEmpty ? 'photo.jpg' : file.name));
  } catch (_) {
    if (context.mounted) showSnack(context, 'Could not open the photo picker', isError: true);
    return null;
  }
}
