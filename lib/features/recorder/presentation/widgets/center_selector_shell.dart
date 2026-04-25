import 'package:flutter/material.dart';

const _accent = Color(0xFF252D46);
const _border = Color(0xFFE5E7EB);
const _surface = Color(0xFFFFFFFF);
const _secondaryText = Color(0xFF6B7280);

class CenterSelectorShell extends StatelessWidget {
  const CenterSelectorShell({
    super.key,
    required this.value,
    required this.valueColor,
    required this.trailing,
    required this.enabled,
    required this.onTap,
  });

  final String value;
  final Color valueColor;
  final Widget trailing;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(24));

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: enabled ? 1 : 0.58,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
              color: _surface,
              borderRadius: radius,
              border: Border.fromBorderSide(BorderSide(color: _border)),
              boxShadow: [
                BoxShadow(
                  color: Color(0x0F000000),
                  blurRadius: 24,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                const _SelectorIcon(),
                const SizedBox(width: 14),
                Expanded(
                  child: _SelectorText(value: value, valueColor: valueColor),
                ),
                const SizedBox(width: 12),
                IconTheme(
                  data: const IconThemeData(color: _accent, size: 24),
                  child: trailing,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectorIcon extends StatelessWidget {
  const _SelectorIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: const BoxDecoration(
        color: Color(0x1A252D46),
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: const Icon(Icons.apartment_rounded, color: _accent, size: 23),
    );
  }
}

class _SelectorText extends StatelessWidget {
  const _SelectorText({required this.value, required this.valueColor});

  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Մասնաճյուղ',
          style: TextStyle(
            color: _secondaryText,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: valueColor,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}
