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
    this.compact = false,
  });

  final String value;
  final Color valueColor;
  final Widget trailing;
  final bool enabled;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.all(Radius.circular(compact ? 18 : 24));

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: enabled ? 1 : 0.58,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Ink(
            padding: EdgeInsets.all(compact ? 12 : 18),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: radius,
              border: const Border.fromBorderSide(BorderSide(color: _border)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0F000000),
                  blurRadius: 24,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                _SelectorIcon(compact: compact),
                SizedBox(width: compact ? 10 : 14),
                Expanded(
                  child: _SelectorText(
                    value: value,
                    valueColor: valueColor,
                    compact: compact,
                  ),
                ),
                SizedBox(width: compact ? 8 : 12),
                IconTheme(
                  data: IconThemeData(color: _accent, size: compact ? 22 : 24),
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
  const _SelectorIcon({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: compact ? 38 : 46,
      height: compact ? 38 : 46,
      decoration: BoxDecoration(
        color: const Color(0x1A252D46),
        borderRadius: BorderRadius.all(Radius.circular(compact ? 14 : 16)),
      ),
      child: Icon(Icons.apartment_rounded,
          color: _accent, size: compact ? 20 : 23),
    );
  }
}

class _SelectorText extends StatelessWidget {
  const _SelectorText({
    required this.value,
    required this.valueColor,
    required this.compact,
  });

  final String value;
  final Color valueColor;
  final bool compact;

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
        SizedBox(height: compact ? 3 : 5),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: valueColor,
            fontSize: compact ? 15 : 17,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}
