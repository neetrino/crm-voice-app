import 'package:flutter/material.dart';

class HistoryAudioPlayer extends StatelessWidget {
  const HistoryAudioPlayer({
    super.key,
    required this.enabled,
    required this.active,
    required this.playing,
    required this.loading,
    required this.position,
    required this.totalDuration,
    required this.onPressed,
  });

  final bool enabled;
  final bool active;
  final bool playing;
  final bool loading;
  final Duration position;
  final Duration totalDuration;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final progress = _progressValue;
    final visibleDuration = active ? position : totalDuration;
    final accent = enabled ? const Color(0xFF252D46) : const Color(0xFF9A9AA0);

    return Opacity(
      opacity: enabled ? 1 : .55,
      child: Material(
        color: const Color(0xFFEDEDF2),
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: enabled && (!loading || active) ? onPressed : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  height: 34,
                  width: 34,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: loading
                      ? Padding(
                          padding: const EdgeInsets.all(9),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(accent),
                          ),
                        )
                      : Icon(
                          playing
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: accent,
                          size: 24,
                        ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 44,
                  child: Text(
                    _formatVoiceDuration(visibleDuration.inSeconds),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF252D46),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 4,
                      backgroundColor: const Color(0xFFD6D6DC),
                      valueColor: AlwaysStoppedAnimation<Color>(accent),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double get _progressValue {
    final totalMs = totalDuration.inMilliseconds;
    if (!active || totalMs <= 0) return 0;
    return (position.inMilliseconds / totalMs).clamp(0, 1).toDouble();
  }

  String _formatVoiceDuration(int seconds) {
    final safeSeconds = seconds < 0 ? 0 : seconds;
    final minutes = safeSeconds ~/ 60;
    final rest = (safeSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$rest';
  }
}
