import 'package:flutter/material.dart';

import 'package:pulse_track/features/settings/domain/models/energy_unit.dart';
import 'package:pulse_track/l10n/app_localizations.dart';

/// Modal dialog for choosing the measurement unit for expended energy.
class EnergyUnitSelectionDialog extends StatelessWidget {
  /// Currently active energy unit.
  final EnergyUnit currentUnit;

  /// Callback when a new unit is selected.
  final ValueChanged<EnergyUnit> onSelected;

  const EnergyUnitSelectionDialog({
    required this.currentUnit,
    required this.onSelected,
    super.key,
  });

  /// Displays the modal dialog.
  static Future<void> show(
    BuildContext context, {
    required EnergyUnit currentUnit,
    required ValueChanged<EnergyUnit> onSelected,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => EnergyUnitSelectionDialog(
        currentUnit: currentUnit,
        onSelected: (unit) {
          onSelected(unit);
          Navigator.of(ctx).pop();
        },
      ),
    );
  }

  String _unitLabel(BuildContext context, EnergyUnit unit) {
    final l10n = AppLocalizations.of(context);
    return switch (unit) {
      EnergyUnit.kcal => l10n.settingsEnergyUnitKcal,
      EnergyUnit.kj => l10n.settingsEnergyUnitKj,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SimpleDialog(
      title: Text(l10n.settingsEnergyUnitTitle),
      children: [
        RadioGroup<EnergyUnit>(
          groupValue: currentUnit,
          onChanged: (val) {
            if (val != null) onSelected(val);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final unit in EnergyUnit.values)
                RadioListTile<EnergyUnit>(
                  title: Text(_unitLabel(context, unit)),
                  value: unit,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
