import 'package:flutter/material.dart';

import '../models/calculator_mode.dart';

class ModeSelector extends StatelessWidget {
  final CalculatorMode selectedMode;
  final bool isDegreeMode;
  final bool hasMemory;
  final ValueChanged<CalculatorMode> onModeChanged;

  const ModeSelector({
    super.key,
    required this.selectedMode,
    required this.isDegreeMode,
    required this.hasMemory,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        children: [
          Row(
            children: [
              _buildChip(
                context,
                label: 'Basic',
                isSelected: selectedMode == CalculatorMode.basic,
                onTap: () => onModeChanged(CalculatorMode.basic),
              ),
              const SizedBox(width: 8),
              _buildChip(
                context,
                label: 'Scientific',
                isSelected: selectedMode == CalculatorMode.scientific,
                onTap: () => onModeChanged(CalculatorMode.scientific),
              ),
              const SizedBox(width: 8),
              _buildChip(
                context,
                label: 'Programmer',
                isSelected: selectedMode == CalculatorMode.programmer,
                onTap: () => onModeChanged(CalculatorMode.programmer),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildStatusBadge(
                context,
                label: isDegreeMode ? 'DEG' : 'RAD',
              ),
              const SizedBox(width: 8),
              _buildStatusBadge(
                context,
                label: hasMemory ? 'MEM' : 'NO MEM',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.tertiary.withOpacity(0.18)
                : theme.colorScheme.secondary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.tertiary
                  : theme.dividerColor.withOpacity(0.25),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? theme.colorScheme.tertiary : null,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(
    BuildContext context, {
    required String label,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}