import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../models/center_model.dart';
import '../../models/voice_recording_history_item.dart';
import 'history_audio_player.dart';

class HistoryRecordingCard extends StatelessWidget {
  const HistoryRecordingCard({
    super.key,
    required this.item,
    required this.centers,
    required this.updating,
    required this.active,
    required this.playing,
    required this.loadingAudio,
    required this.position,
    required this.playerDuration,
    required this.onPlayPressed,
    required this.onCenterChanged,
  });

  final VoiceRecordingHistoryItem item;
  final List<CenterModel> centers;
  final bool updating;
  final bool active;
  final bool playing;
  final bool loadingAudio;
  final Duration position;
  final Duration? playerDuration;
  final VoidCallback onPlayPressed;
  final ValueChanged<String> onCenterChanged;

  @override
  Widget build(BuildContext context) {
    final selected = centers.any((center) => center.id == item.centerId)
        ? item.centerId
        : null;

    return Card(
      elevation: 0,
      color: const Color(0xFFF5F5F7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoRow(
              label: 'Ամսաթիվ',
              value: formatArmenianDateTime(item.createdAt),
            ),
            const SizedBox(height: 8),
            _InfoRow(
              label: 'Տևողություն',
              value: formatClockDuration(item.durationSec),
            ),
            const SizedBox(height: 14),
            HistoryAudioPlayer(
              enabled: item.hasPlayableAudio,
              active: active,
              playing: playing,
              loading: loadingAudio,
              position: active ? position : Duration.zero,
              totalDuration: _totalDuration,
              onPressed: onPlayPressed,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: selected,
              decoration: const InputDecoration(labelText: 'Մասնաճյուղ'),
              hint: Text(item.centerName ?? 'Ընտրեք մասնաճյուղը'),
              items: [
                for (final center in centers)
                  DropdownMenuItem(value: center.id, child: Text(center.name)),
              ],
              onChanged: updating ? null : _onDropdownChanged,
            ),
            if (updating) ...[
              const SizedBox(height: 10),
              Text(
                'Թարմացվում է...',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _onDropdownChanged(String? value) {
    if (value == null || value == item.centerId) return;
    onCenterChanged(value);
  }

  Duration get _totalDuration {
    if (item.durationSec > 0) return Duration(seconds: item.durationSec);
    return playerDuration ?? Duration.zero;
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF6E6E73),
              ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}
