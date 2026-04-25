import 'package:flutter/material.dart';

const _accent = Color(0xFF252D46);
const _saveGreen = Color(0xFF16A34A);
const _deleteRed = Color(0xFFDC2626);

enum RecordButtonTone { accent, neutral, save }

class RecordActionButtons extends StatelessWidget {
  const RecordActionButtons({
    super.key,
    required this.recording,
    required this.uploading,
    required this.hasRecording,
    required this.canSave,
    required this.onStart,
    required this.onStop,
    required this.onSave,
  });

  final bool recording;
  final bool uploading;
  final bool hasRecording;
  final bool canSave;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    if (recording) {
      return LargeButton(
        label: 'Ավարտել',
        onPressed: onStop,
        tone: RecordButtonTone.neutral,
      );
    }
    if (hasRecording) {
      return LargeButton(
        label: 'Պահպանել',
        onPressed: canSave ? onSave : null,
        tone: RecordButtonTone.save,
      );
    }
    return LargeButton(
      label: 'Ձայնագրել',
      onPressed: uploading ? null : onStart,
    );
  }
}

class LargeButton extends StatelessWidget {
  const LargeButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.tone = RecordButtonTone.accent,
  });

  final String label;
  final VoidCallback? onPressed;
  final RecordButtonTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = switch (tone) {
      RecordButtonTone.accent => (
          background: _accent,
          foreground: Colors.white
        ),
      RecordButtonTone.neutral => (
          background: const Color(0xFFE8E8ED),
          foreground: const Color(0xFF1C1C1E),
        ),
      RecordButtonTone.save => (
          background: _saveGreen,
          foreground: Colors.white,
        ),
    };

    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: colors.background,
        disabledBackgroundColor: colors.background.withValues(alpha: 0.45),
        disabledForegroundColor: colors.foreground.withValues(alpha: 0.70),
        foregroundColor: colors.foreground,
        minimumSize: const Size.fromHeight(66),
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.1,
        ),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}

class DeleteRecordingButton extends StatelessWidget {
  const DeleteRecordingButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0x1ADC2626),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        splashColor: _deleteRed.withValues(alpha: 0.10),
        highlightColor: _deleteRed.withValues(alpha: 0.06),
        child: const SizedBox.square(
          dimension: 52,
          child: Icon(Icons.delete_rounded, color: _deleteRed, size: 25),
        ),
      ),
    );
  }
}

class PanelMessage extends StatelessWidget {
  const PanelMessage({
    super.key,
    required this.message,
    required this.onReload,
  });

  final String message;
  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: const Color(0xFFF5F5F7),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(child: Text(message)),
            TextButton(onPressed: onReload, child: const Text('Թարմացնել')),
          ],
        ),
      ),
    );
  }
}

class StatusMessage extends StatelessWidget {
  const StatusMessage({super.key, required this.text, this.isError = false});

  final String text;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: color),
      ),
    );
  }
}
