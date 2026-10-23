import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/media/photo_picker.dart';
import '../../core/models/enums.dart';
import '../../core/models/models.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/vehicle_image.dart';
import 'vehicle_providers.dart';

class VehicleFormScreen extends ConsumerStatefulWidget {
  const VehicleFormScreen({super.key, this.vehicle});
  final Vehicle? vehicle;

  @override
  ConsumerState<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends ConsumerState<VehicleFormScreen> {
  final _form = GlobalKey<FormState>();
  late final _plate = TextEditingController(text: widget.vehicle?.licensePlate ?? '');
  late final _brand = TextEditingController(text: widget.vehicle?.brand ?? '');
  late final _model = TextEditingController(text: widget.vehicle?.model ?? '');
  late final _rate = TextEditingController(text: widget.vehicle?.dailyRate.toStringAsFixed(2) ?? '');
  late final _year = TextEditingController(text: widget.vehicle?.year.toString() ?? '');
  late VehicleCategory _category = widget.vehicle?.category ?? VehicleCategory.economy;
  bool _busy = false;

  // photo: nothing picked + not removed = the vehicle keeps its current photo
  // (or gets the default picture of its category when it is created without one)
  PickedImage? _picked;
  bool _removeCurrent = false;

  bool get _editing => widget.vehicle != null;

  @override
  void dispose() {
    for (final c in [_plate, _brand, _model, _rate, _year]) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _hasCurrentPhoto => _editing && !_removeCurrent && widget.vehicle?.photoUrl != null;

  Future<void> _choosePhoto() async {
    final pick = await askForPhoto(context);
    if (pick?.image != null) {
      setState(() {
        _picked = pick!.image;
        _removeCurrent = false;
      });
    }
  }

  void _dropPhoto() => setState(() {
        if (_picked != null) {
          _picked = null; // back to the current photo (edit) or the default one (new vehicle)
        } else {
          _removeCurrent = true; // edit: the vehicle goes back to the default picture
        }
      });

  Widget _photoPreview() {
    final Widget image;
    if (_picked != null) {
      image = Image.memory(_picked!.bytes, fit: BoxFit.cover, width: double.infinity, height: double.infinity);
    } else if (_hasCurrentPhoto) {
      image = VehicleImage(photoUrl: widget.vehicle!.photoUrl, category: _category);
    } else {
      image = VehicleImage(photoUrl: null, category: _category);
    }
    final String caption;
    if (_picked != null) {
      caption = 'New photo selected';
    } else if (_hasCurrentPhoto) {
      caption = 'Current photo (kept if you do not change it)';
    } else {
      caption = 'Default ${_category.label} picture (used when no photo is added)';
    }
    final canDrop = _picked != null || _hasCurrentPhoto;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Photo', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: AspectRatio(aspectRatio: 16 / 9, child: image),
        ),
        const SizedBox(height: 8),
        Text(caption, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(minimumSize: const Size(88, 46)),
                onPressed: _busy ? null : _choosePhoto,
                icon: const Icon(Icons.add_a_photo_outlined),
                label: Text(_picked != null || _hasCurrentPhoto ? 'Change photo' : 'Add photo'),
              ),
            ),
            if (canDrop) ...[
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(88, 46),
                    foregroundColor: AppColors.danger,
                  ),
                  onPressed: _busy ? null : _dropPhoto,
                  icon: const Icon(Icons.delete_outline),
                  label: Text(_picked != null ? 'Discard' : 'Use default'),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  String? _req(String? v) => (v == null || v.trim().isEmpty) ? 'Required' : null;

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      final body = {
        'licensePlate': _plate.text.trim(),
        'brand': _brand.text.trim(),
        'model': _model.text.trim(),
        'category': _category.api,
        'dailyRate': double.parse(_rate.text.trim().replaceAll(',', '.')),
        'yearOfManufacture': int.parse(_year.text.trim()),
        // the backend requires the field; it stores whatever is sent
        'version': widget.vehicle?.version ?? 0,
      };
      final repo = ref.read(vehicleRepoProvider);
      final saved = await repo.save(body, widget.vehicle?.id);
      // the photo goes in a second request; the vehicle itself is already saved at this point
      String? photoError;
      try {
        if (_picked != null) {
          await repo.uploadPhoto(saved.id, _picked!.bytes, _picked!.name);
        } else if (_editing && _removeCurrent) {
          await repo.removePhoto(saved.id);
        }
      } on ApiException catch (e) {
        photoError = e.display;
      }
      ref.invalidate(vehicleListProvider);
      ref.invalidate(vehicleProvider(saved.id));
      if (!mounted) return;
      if (photoError != null) {
        showSnack(context, 'Vehicle saved, but the photo was not uploaded: $photoError', isError: true);
      } else {
        showSnack(context, _editing ? 'Vehicle updated' : 'Vehicle added');
      }
      context.pop();
    } on ApiException catch (e) {
      if (mounted) showSnack(context, e.display, isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _gap(Widget w) => Padding(padding: const EdgeInsets.only(bottom: 16), child: w);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_editing ? 'Edit vehicle' : 'Add vehicle')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _gap(_photoPreview()),
            _gap(TextFormField(
              controller: _plate,
              decoration: const InputDecoration(labelText: 'License plate'),
              validator: _req,
            )),
            _gap(TextFormField(
              controller: _brand,
              decoration: const InputDecoration(labelText: 'Brand'),
              validator: _req,
            )),
            _gap(TextFormField(
              controller: _model,
              decoration: const InputDecoration(labelText: 'Model'),
              validator: _req,
            )),
            const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _gap(Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final c in VehicleCategory.values)
                  ChoiceChip(
                    avatar: Icon(c.icon, size: 18),
                    label: Text(c.label),
                    selected: _category == c,
                    onSelected: (_) => setState(() => _category = c),
                  ),
              ],
            )),
            _gap(TextFormField(
              controller: _rate,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Daily rate'),
              validator: (v) {
                final n = double.tryParse((v ?? '').trim().replaceAll(',', '.'));
                return (n == null || n < 0.01) ? 'Enter a rate of at least 0.01' : null;
              },
            )),
            _gap(TextFormField(
              controller: _year,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Year of manufacture'),
              validator: (v) {
                final n = int.tryParse((v ?? '').trim());
                return (n == null || n < 1990) ? 'Year must be 1990 or later' : null;
              },
            )),
            const SizedBox(height: 10),
            PrimaryButton(label: _editing ? 'Save changes' : 'Add vehicle', loading: _busy, onPressed: _save),
          ],
        ),
      ),
    );
  }
}
