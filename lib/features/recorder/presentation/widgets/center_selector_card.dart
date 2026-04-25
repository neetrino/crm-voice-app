import 'dart:ui';

import 'package:flutter/material.dart';

import '../../models/center_model.dart';
import 'center_selector_menu.dart';
import 'center_selector_shell.dart';

const _accent = Color(0xFF252D46);
const _primaryText = Color(0xFF111827);
const _secondaryText = Color(0xFF6B7280);

class CenterSelectorCard extends StatefulWidget {
  const CenterSelectorCard({
    super.key,
    required this.centers,
    required this.selectedCenter,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
    required this.onChanged,
    required this.enabled,
  });

  final List<CenterModel> centers;
  final CenterModel? selectedCenter;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final ValueChanged<CenterModel> onChanged;
  final bool enabled;

  @override
  State<CenterSelectorCard> createState() => _CenterSelectorCardState();
}

class _CenterSelectorCardState extends State<CenterSelectorCard> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  bool get _hasMenu =>
      !widget.isLoading &&
      widget.errorMessage == null &&
      widget.centers.isNotEmpty &&
      widget.enabled;

  @override
  Widget build(BuildContext context) {
    final state = _state(context);

    if (_hasMenu) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return CompositedTransformTarget(
            link: _layerLink,
            child: CenterSelectorShell(
              value: state.value,
              valueColor: state.valueColor,
              trailing: state.trailing,
              enabled: widget.enabled,
              onTap: () => _toggleOverlay(constraints.maxWidth),
            ),
          );
        },
      );
    }

    return CenterSelectorShell(
      value: state.value,
      valueColor: state.valueColor,
      trailing: state.trailing,
      enabled: widget.enabled,
      onTap: state.onTap,
    );
  }

  @override
  void didUpdateWidget(CenterSelectorCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_hasMenu) {
      _closeOverlay();
    }
  }

  @override
  void dispose() {
    _closeOverlay();
    super.dispose();
  }

  _SelectorState _state(BuildContext context) {
    if (widget.isLoading) {
      return const _SelectorState(
        value: 'Բեռնվում է...',
        valueColor: _secondaryText,
        trailing: SizedBox.square(
          dimension: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (widget.errorMessage != null) {
      return _retryState('Չհաջողվեց բեռնել մասնաճյուղերը');
    }

    if (widget.centers.isEmpty) {
      return _retryState('Մասնաճյուղեր չկան');
    }

    final selected = widget.selectedCenter;
    return _SelectorState(
      value: selected?.name ?? 'Ընտրեք մասնաճյուղը',
      valueColor: selected == null ? _secondaryText : _primaryText,
      trailing: const Icon(Icons.keyboard_arrow_down_rounded),
    );
  }

  _SelectorState _retryState(String value) {
    return _SelectorState(
      value: value,
      valueColor: _secondaryText,
      trailing: const Icon(Icons.refresh_rounded, color: _accent),
      onTap: widget.enabled ? widget.onRetry : null,
    );
  }

  void _toggleOverlay(double width) {
    if (_overlayEntry != null) {
      _closeOverlay();
      return;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) {
        final state = _state(context);

        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _closeOverlay,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: ColoredBox(
                    color: Colors.black.withValues(alpha: 0.10),
                  ),
                ),
              ),
            ),
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              child: SizedBox(
                width: width,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CenterSelectorShell(
                      value: state.value,
                      valueColor: state.valueColor,
                      trailing: state.trailing,
                      enabled: widget.enabled,
                      onTap: _closeOverlay,
                    ),
                    const SizedBox(height: 8),
                    CenterSelectorMenu(
                      width: width,
                      centers: widget.centers,
                      selectedCenterId: widget.selectedCenter?.id,
                      onSelected: _selectCenter,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _selectCenter(CenterModel center) {
    _closeOverlay();
    widget.onChanged(center);
  }

  void _closeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

class _SelectorState {
  const _SelectorState({
    required this.value,
    required this.valueColor,
    required this.trailing,
    this.onTap,
  });

  final String value;
  final Color valueColor;
  final Widget trailing;
  final VoidCallback? onTap;
}
