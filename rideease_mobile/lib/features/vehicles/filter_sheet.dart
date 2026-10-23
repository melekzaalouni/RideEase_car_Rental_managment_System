import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/enums.dart';
import '../../core/widgets/common.dart';
import '../auth/auth_controller.dart';
import 'vehicle_providers.dart';
import 'vehicle_repository.dart';

Future<void> showFilterSheet(BuildContext context) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _FilterSheet(),
    );

const _sorts = {
  'Price: low to high': 'dailyRate,asc',
  'Price: high to low': 'dailyRate,desc',
  'Newest first': 'yearOfManufacture,desc',
  'Brand A-Z': 'brand,asc',
};

class _FilterSheet extends ConsumerStatefulWidget {
  const _FilterSheet();

  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  late VehicleFilter _f;
  late RangeValues _range;
  final _year = TextEditingController();

  @override
  void initState() {
    super.initState();
    _f = ref.read(vehicleFilterProvider);
    _range = RangeValues(_f.minRate ?? 0, _f.maxRate ?? 500);
    _year.text = _f.year?.toString() ?? '';
  }

  @override
  void dispose() {
    _year.dispose();
    super.dispose();
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      );

  @override
  Widget build(BuildContext context) {
    final staff = ref.watch(authProvider)?.isStaff ?? false;
    final statuses = staff ? VehicleStatus.values : [VehicleStatus.available];
    final hi = _range.end >= 500 ? '500+' : _range.end.round().toString();

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Availability'),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: _f.status == null,
                  onSelected: (_) => setState(() => _f = _f.copyWith(status: null)),
                ),
                for (final s in statuses)
                  ChoiceChip(
                    label: Text(s.api[0] + s.api.substring(1).toLowerCase()),
                    selected: _f.status == s,
                    onSelected: (_) => setState(() => _f = _f.copyWith(status: s)),
                  ),
              ],
            ),
            _label('Daily rate'),
            RangeSlider(
              values: _range,
              min: 0,
              max: 500,
              divisions: 50,
              labels: RangeLabels('${_range.start.round()}', hi),
              onChanged: (v) => setState(() => _range = v),
            ),
            Text('${_range.start.round()} - $hi'),
            _label('Year'),
            TextField(
              controller: _year,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'e.g. 2022'),
            ),
            _label('Sort by'),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final e in _sorts.entries)
                  ChoiceChip(
                    label: Text(e.key),
                    selected: _f.sort == e.value,
                    onSelected: (_) => setState(() => _f = _f.copyWith(sort: e.value)),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ref.read(vehicleFilterProvider.notifier).reset();
                      Navigator.pop(context);
                    },
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: PrimaryButton(
                    label: 'Apply filters',
                    onPressed: () {
                      ref.read(vehicleFilterProvider.notifier).set(_f.copyWith(
                            minRate: _range.start <= 0 ? null : _range.start,
                            maxRate: _range.end >= 500 ? null : _range.end,
                            year: _year.text.trim().isEmpty ? null : int.tryParse(_year.text.trim()),
                          ));
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
