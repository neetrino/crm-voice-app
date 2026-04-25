import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/ui/app_toast.dart';
import '../../../core/utils/formatters.dart';
import '../data/centers_api.dart';
import '../data/recordings_api.dart';
import '../models/center_model.dart';
import '../services/audio_recorder_service.dart';
import 'widgets/center_selector_card.dart';
import 'widgets/delete_recording_dialog.dart';
import 'widgets/record_page_widgets.dart';
import 'widgets/recording_waveform.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({
    super.key,
    required this.apiClient,
    this.onRecordingUploaded,
  });

  final ApiClient apiClient;
  final VoidCallback? onRecordingUploaded;

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  late final CentersApi _centersApi = CentersApi(widget.apiClient);
  late final RecordingsApi _recordingsApi = RecordingsApi(widget.apiClient);
  late final AudioRecorderService _audio = AudioRecorderService();

  List<CenterModel> _centers = [];
  bool _loadingCenters = true;
  String? _centersError;
  String? _selectedCenterId;

  bool _recording = false;
  bool _uploading = false;
  String? _filePath;
  int _durationSec = 0;
  Stopwatch? _stopwatch;
  Timer? _tick;

  bool get _hasRecording => _filePath != null && !_recording;
  CenterModel? get _selectedCenter {
    final selectedId = _selectedCenterId;
    if (selectedId == null) return null;

    for (final center in _centers) {
      if (center.id == selectedId) return center;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _loadCenters();
  }

  @override
  void dispose() {
    _tick?.cancel();
    _audio.dispose();
    super.dispose();
  }

  Future<void> _loadCenters() async {
    setState(() {
      _loadingCenters = true;
      _centersError = null;
    });

    try {
      final list = await _centersApi.fetchCenters();
      if (!mounted) return;
      setState(() {
        _centers = list;
        _loadingCenters = false;
        _selectedCenterId = _initialCenterId(list);
      });
    } on ApiException catch (e) {
      _setCentersError(e.message);
    } catch (_) {
      _setCentersError('Չհաջողվեց բեռնել մասնաճյուղերը');
    }
  }

  String? _initialCenterId(List<CenterModel> list) {
    final selected = _selectedCenterId;
    if (selected != null && list.any((center) => center.id == selected)) {
      return selected;
    }
    return null;
  }

  void _setCentersError(String message) {
    if (!mounted) return;
    setState(() {
      _centersError = message;
      _loadingCenters = false;
    });
  }

  void _beginTick() {
    _tick?.cancel();
    _tick = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (!_recording || _stopwatch == null) return;
      if (mounted) {
        setState(() => _durationSec = _stopwatch!.elapsed.inSeconds);
      }
    });
  }

  Future<void> _startRecording() async {
    try {
      await _audio.startRecording();
      _stopwatch = Stopwatch()..start();
      setState(() {
        _recording = true;
        _filePath = _audio.currentPath;
        _durationSec = 0;
      });
      _beginTick();
    } on StateError {
      if (!mounted) return;
      showErrorToast(context, 'Միկրոֆոնի հասանելիությունը մերժված է');
    } catch (_) {
      if (!mounted) return;
      showErrorToast(context, 'Չհաջողվեց սկսել ձայնագրությունը');
    }
  }

  Future<void> _stopRecording() async {
    _tick?.cancel();
    _stopwatch?.stop();
    final elapsedSec = _stopwatch?.elapsed.inSeconds ?? 0;

    try {
      final path = await _audio.stopRecording();
      if (!mounted) return;
      setState(() {
        _recording = false;
        _filePath = path;
        _durationSec = elapsedSec;
        _selectedCenterId = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _recording = false;
      });
      showErrorToast(context, 'Չհաջողվեց ավարտել ձայնագրությունը');
    }
  }

  Future<void> _upload() async {
    final centerId = _selectedCenterId;
    final path = _filePath;
    if (centerId == null) {
      showErrorToast(context, 'Ընտրեք մասնաճյուղը');
      return;
    }
    if (path == null) return;
    if (_durationSec < 1) {
      showErrorToast(context, 'Ձայնագրությունը շատ կարճ է');
      return;
    }

    setState(() {
      _uploading = true;
    });

    try {
      await _recordingsApi.uploadRecording(
        filePath: path,
        centerId: centerId,
        durationSec: _durationSec,
      );
      if (!mounted) return;
      widget.onRecordingUploaded?.call();
      setState(() {
        _uploading = false;
        _filePath = null;
        _durationSec = 0;
        _stopwatch = null;
        _selectedCenterId = null;
      });
      showSuccessToast(context, 'Ձայնագրությունը պահպանվեց');
    } on ApiException catch (e) {
      _setUploadError(e.message);
    } catch (_) {
      _setUploadError('Չհաջողվեց պահպանել ձայնագրությունը');
    }
  }

  void _setUploadError(String message) {
    if (!mounted) return;
    setState(() {
      _uploading = false;
    });
    showErrorToast(context, message);
  }

  void _deleteRecording() {
    if (_recording) return;
    setState(() {
      _filePath = null;
      _durationSec = 0;
      _stopwatch = null;
      _selectedCenterId = null;
    });
  }

  Future<void> _confirmDeleteRecording() async {
    if (_recording) return;
    final confirmed = await showDeleteRecordingDialog(context);
    if (!mounted || !confirmed) return;
    _deleteRecording();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
            children: [
              CenterSelectorCard(
                centers: _centers,
                selectedCenter: _selectedCenter,
                isLoading: _loadingCenters,
                errorMessage: _centersError,
                enabled: !_uploading && !_recording,
                onRetry: _loadCenters,
                onChanged: (center) =>
                    setState(() => _selectedCenterId = center.id),
              ),
              const SizedBox(height: 30),
              Text(
                formatClockDuration(_durationSec),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1.5,
                      color: const Color(0xFF111111),
                    ),
              ),
              const SizedBox(height: 22),
              RecordingWaveform(
                isRecording: _recording,
                hasRecording: _hasRecording,
              ),
              const SizedBox(height: 28),
              _buildMainActionButtons(),
              if (_uploading) const StatusMessage(text: 'Պահպանվում է...'),
            ],
          ),
          if (_hasRecording && !_uploading)
            Positioned(
              right: 20,
              bottom: 24,
              child: DeleteRecordingButton(onPressed: _confirmDeleteRecording),
            ),
        ],
      ),
    );
  }

  Widget _buildMainActionButtons() {
    return RecordActionButtons(
      recording: _recording,
      uploading: _uploading,
      hasRecording: _hasRecording,
      canSave: _canSave,
      onStart: _startRecording,
      onStop: _stopRecording,
      onSave: _upload,
    );
  }

  bool get _canSave {
    return !_recording && !_uploading && _filePath != null && _durationSec >= 1;
  }
}
