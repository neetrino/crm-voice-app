import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/widgets/loading_view.dart';
import '../data/centers_api.dart';
import '../data/voice_history_api.dart';
import '../models/center_model.dart';
import '../models/voice_recording_history_item.dart';
import 'widgets/history_recording_card.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({
    super.key,
    required this.apiClient,
    required this.refreshSignal,
  });

  final ApiClient apiClient;
  final int refreshSignal;

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late final CentersApi _centersApi = CentersApi(widget.apiClient);
  late final VoiceHistoryApi _historyApi = VoiceHistoryApi(widget.apiClient);
  late final AudioPlayer _player = AudioPlayer();
  StreamSubscription<PlayerState>? _playerSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;

  List<CenterModel> _centers = [];
  List<VoiceRecordingHistoryItem> _items = [];
  final Set<String> _updatingLeadIds = {};
  bool _loading = true;
  bool _isPlaying = false;
  bool _isLoadingAudio = false;
  String? _error;
  String? _message;
  String? _activeLeadId;
  Duration _position = Duration.zero;
  Duration? _duration;

  @override
  void initState() {
    super.initState();
    _playerSub = _player.playerStateStream.listen(_onPlayerState);
    _positionSub = _player.positionStream.listen(_onPositionChanged);
    _durationSub = _player.durationStream.listen(_onDurationChanged);
    _load();
  }

  @override
  void didUpdateWidget(covariant HistoryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshSignal != widget.refreshSignal) {
      _load();
    }
  }

  @override
  void dispose() {
    _playerSub?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();
    _player.stop();
    _player.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _message = null;
    });

    try {
      final centers = await _centersApi.fetchCenters();
      final items = await _historyApi.fetchRecordings();
      if (!mounted) return;
      setState(() {
        _centers = centers;
        _items = items;
        _loading = false;
      });
    } on ApiException catch (e) {
      _setLoadError(e.message);
    } catch (_) {
      _setLoadError('Չհաջողվեց բեռնել պատմությունը');
    }
  }

  void _setLoadError(String message) {
    if (!mounted) return;
    setState(() {
      _error = message;
      _loading = false;
    });
  }

  void _onPlayerState(PlayerState state) {
    if (state.processingState == ProcessingState.completed) {
      _handlePlaybackCompleted();
      return;
    }
    if (!mounted || _activeLeadId == null) return;
    setState(() => _isPlaying = state.playing);
  }

  void _onPositionChanged(Duration position) {
    if (!mounted || _activeLeadId == null) return;
    final duration = _duration;
    final nextPosition = duration == null || duration == Duration.zero
        ? position
        : _minDuration(position, duration);
    setState(() => _position = nextPosition);
  }

  void _onDurationChanged(Duration? duration) {
    if (!mounted || duration == null || duration == Duration.zero) return;
    setState(() => _duration = duration);
  }

  Future<void> _onTapVoice(VoiceRecordingHistoryItem item) async {
    if (!item.hasPlayableAudio) return;

    if (_activeLeadId == item.leadId) {
      if (_player.playing) {
        await _pauseCurrentPlayback();
        return;
      }
      await _resumeCurrentPlayback();
      return;
    }

    if (_isLoadingAudio) return;

    await _startNewPlayback(item);
  }

  Future<void> _pauseCurrentPlayback() async {
    try {
      await _player.pause();
    } finally {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _isLoadingAudio = false;
        });
      }
    }
  }

  Future<void> _resumeCurrentPlayback() async {
    unawaited(_player.play().catchError((Object _) {
      unawaited(_handlePlaybackFailure());
    }));
    if (mounted) {
      setState(() {
        _isPlaying = true;
        _isLoadingAudio = false;
      });
    }
  }

  Future<void> _startNewPlayback(VoiceRecordingHistoryItem item) async {
    final audioPath = item.audioPath;
    if (audioPath == null || audioPath.isEmpty) return;
    final audioUrl = _buildAudioUrl(item);
    final fallbackDuration = _durationFromItem(item);

    setState(() {
      _isLoadingAudio = true;
      _activeLeadId = item.leadId;
      _isPlaying = false;
      _position = Duration.zero;
      _duration = fallbackDuration;
      _message = null;
    });

    try {
      await _stopAndResetCurrentPlayback(clearActive: false);
      if (kDebugMode) {
        debugPrint(
          'History playback: leadId=${item.leadId}, '
          'createdAt=${item.createdAt?.toIso8601String()}, '
          'audioPath=$audioPath, audioUrl=$audioUrl',
        );
      }
      await _player.setAudioSource(
        AudioSource.uri(
          Uri.parse(audioUrl),
          headers: await _getPlaybackHeaders(),
        ),
      );
      if (!mounted) return;
      setState(() {
        _isLoadingAudio = false;
      });
      unawaited(_player.play().catchError((Object _) {
        unawaited(_handlePlaybackFailure());
      }));
      if (!mounted) return;
      setState(() => _isPlaying = true);
    } catch (_) {
      await _handlePlaybackFailure();
    } finally {
      if (mounted && _isLoadingAudio) {
        setState(() => _isLoadingAudio = false);
      }
    }
  }

  Future<void> _stopAndResetCurrentPlayback({required bool clearActive}) async {
    try {
      await _player.stop();
      await _player.seek(Duration.zero);
    } catch (_) {
      // Stopping is best-effort during source switches and disposal.
    }
    if (!mounted) return;
    setState(() {
      if (clearActive) _activeLeadId = null;
      _isPlaying = false;
      _position = Duration.zero;
      if (clearActive) _duration = null;
    });
  }

  void _handlePlaybackCompleted() {
    if (mounted) {
      setState(() {
        _isLoadingAudio = false;
        _activeLeadId = null;
        _isPlaying = false;
        _position = Duration.zero;
        _duration = null;
      });
    }
    unawaited(_stopAndResetCurrentPlayback(clearActive: true));
  }

  Future<void> _handlePlaybackFailure() async {
    await _stopAndResetCurrentPlayback(clearActive: true);
    if (!mounted) return;
    setState(() {
      _message = 'Չհաջողվեց միացնել ձայնագրությունը';
      _isLoadingAudio = false;
    });
  }

  String _buildAudioUrl(VoiceRecordingHistoryItem item) {
    final path = item.audioPath ?? '';
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    final base = AppConfig.apiBaseUrl.replaceFirst(RegExp(r'/$'), '');
    if (path.startsWith('/api/')) {
      return '$base${path.substring(4)}';
    }
    return '$base${path.startsWith('/') ? path : '/$path'}';
  }

  Future<Map<String, String>> _getPlaybackHeaders() async {
    final token = await widget.apiClient.getAccessToken();
    if (token == null || token.isEmpty) {
      throw StateError('Missing access token.');
    }
    return {'Authorization': 'Bearer $token'};
  }

  Duration _durationFromItem(VoiceRecordingHistoryItem item) {
    if (item.durationSec <= 0) return Duration.zero;
    return Duration(seconds: item.durationSec);
  }

  Duration _minDuration(Duration value, Duration max) {
    return value > max ? max : value;
  }

  Future<void> _updateCenter(
    VoiceRecordingHistoryItem item,
    String centerId,
  ) async {
    setState(() {
      _message = null;
      _updatingLeadIds.add(item.leadId);
    });

    try {
      final updated = await _historyApi.updateCenter(
        leadId: item.leadId,
        centerId: centerId,
      );
      _replaceItem(updated ?? _fallbackUpdatedItem(item, centerId));
      if (!mounted) return;
      setState(() => _message = 'Մասնաճյուղը թարմացվեց');
    } on ApiException {
      _showUpdateError();
    } catch (_) {
      _showUpdateError();
    } finally {
      if (mounted) {
        setState(() => _updatingLeadIds.remove(item.leadId));
      }
    }
  }

  VoiceRecordingHistoryItem _fallbackUpdatedItem(
    VoiceRecordingHistoryItem item,
    String centerId,
  ) {
    CenterModel? center;
    for (final candidate in _centers) {
      if (candidate.id == centerId) center = candidate;
    }
    return item.copyWith(centerId: centerId, centerName: center?.name);
  }

  void _replaceItem(VoiceRecordingHistoryItem updated) {
    if (!mounted) return;
    setState(() {
      _items = [
        for (final item in _items)
          if (item.leadId == updated.leadId) updated else item,
      ];
    });
  }

  void _showUpdateError() {
    if (!mounted) return;
    setState(() => _message = 'Չհաջողվեց թարմացնել մասնաճյուղը');
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingView(message: 'Բեռնվում է...');
    if (_error != null) return _HistoryError(message: _error!, onRetry: _load);

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          if (_message != null) _HistoryMessage(message: _message!),
          if (_items.isEmpty)
            const _EmptyHistory()
          else
            for (final item in _items) ...[
              HistoryRecordingCard(
                item: item,
                centers: _centers,
                updating: _updatingLeadIds.contains(item.leadId),
                active: _activeLeadId == item.leadId,
                playing: _activeLeadId == item.leadId && _isPlaying,
                loadingAudio: _activeLeadId == item.leadId && _isLoadingAudio,
                position:
                    _activeLeadId == item.leadId ? _position : Duration.zero,
                playerDuration: _activeLeadId == item.leadId ? _duration : null,
                onPlayPressed: () => _onTapVoice(item),
                onCenterChanged: (centerId) => _updateCenter(item, centerId),
              ),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }
}

class _HistoryError extends StatelessWidget {
  const _HistoryError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: onRetry,
              child: const Text('Թարմացնել'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryMessage extends StatelessWidget {
  const _HistoryMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 320,
      child: Center(child: Text('Ձայնագրություններ չկան')),
    );
  }
}
