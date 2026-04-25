import 'package:flutter/material.dart';

import '../../models/center_model.dart';

const _accent = Color(0xFF252D46);
const _border = Color(0xFFE5E7EB);
const _mutedSurface = Color(0xFFF7F7FA);
const _primaryText = Color(0xFF111827);
const _surface = Color(0xFFFFFFFF);

class CenterSelectorMenu extends StatelessWidget {
  const CenterSelectorMenu({
    super.key,
    required this.width,
    required this.centers,
    required this.selectedCenterId,
    required this.onSelected,
  });

  final double width;
  final List<CenterModel> centers;
  final String? selectedCenterId;
  final ValueChanged<CenterModel> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Material(
        color: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxHeight: 340),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 28,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final center in centers) ...[
                  CenterSelectorMenuItem(
                    center: center,
                    selected: center.id == selectedCenterId,
                    onSelected: onSelected,
                  ),
                  if (center != centers.last) const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CenterSelectorMenuItem extends StatelessWidget {
  const CenterSelectorMenuItem({
    super.key,
    required this.center,
    required this.selected,
    required this.onSelected,
  });

  final CenterModel center;
  final bool selected;
  final ValueChanged<CenterModel> onSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0x1A252D46) : _mutedSurface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => onSelected(center),
        splashColor: _accent.withValues(alpha: 0.08),
        highlightColor: _accent.withValues(alpha: 0.05),
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            border: Border.all(color: selected ? _accent : _border),
          ),
          child: Row(
            children: [
              Expanded(child: _CenterName(center.name)),
              if (selected) ...[
                const SizedBox(width: 12),
                const Icon(
                  Icons.check_circle_rounded,
                  color: _accent,
                  size: 22,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CenterName extends StatelessWidget {
  const _CenterName(this.name);

  final String name;

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: _primaryText,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
