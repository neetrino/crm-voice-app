import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/api_client.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/loading_view.dart';
import '../data/centers_api.dart';
import '../data/recordings_api.dart';
import '../models/center_model.dart';
import '../services/audio_recorder_service.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({
    super.key,
    required this.apiClient,
    required this.onLogout,
  });

  final ApiClient apiClient;
  final VoidCallback onLogout;

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
  String? _filePath;
  int _durationSec = 0;
  Stopwatch? _stopwatch;
  Timer? _tick;

  bool _uploading = false;
  String? _error;
  String? _success;

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
        if (list.isEmpty) {
          _selectedCenterId = null;
        } else if (_selectedCenterId == null ||
            !list.any((c) => c.id == _selectedCenterId)) {
          _selectedCenterId = list.first.id;
        }
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _centersError = e.message;
        _loadingCenters = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _centersError = 'Could not load centers.';
        _loadingCenters = false;
      });
    }
  }

  void _beginTick() {
    _tick?.cancel();
    _tick = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (!_recording || _stopwatch == null) return;
      final sec = _stopwatch!.elapsed.inSeconds;
      if (mounted) setState(() => _durationSec = sec);
    });
  }

  Future<void> _toggleRecord() async {
    setState(() {
      _error = null;
      _success = null;
    });
    if (!_recording) {
      try {
        await _audio.startRecording();
        _stopwatch = Stopwatch()..start();
        setState(() {
          _recording = true;
          _filePath = _audio.currentPath;
          _durationSec = 0;
        });
        _beginTick();
      } on StateError catch (e) {
        setState(() => _error = e.message);
      } catch (_) {
        setState(() => _error = 'Could not start recording.');
      }
      return;
    }

    _tick?.cancel();
    _stopwatch?.stop();
    final sw = _stopwatch;
    final elapsedSec = sw == null ? 0 : sw.elapsed.inSeconds;
    try {
      final path = await _audio.stopRecording();
      if (!mounted) return;
      setState(() {
        _recording = false;
        _filePath = path;
        _durationSec = elapsedSec;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _recording = false;
        _error = 'Could not stop recording.';
      });
    }
  }

  Future<void> _upload() async {
    final centerId = _selectedCenterId;
    final path = _filePath;
    if (centerId == null || path == null) return;
    if (_durationSec < 1) {
      setState(() => _error = 'Recording must be at least 1 second.');
      return;
    }
    setState(() {
      _uploading = true;
      _error = null;
      _success = null;
    });
    try {
      await _recordingsApi.uploadRecording(
        filePath: path,
        centerId: centerId,
        durationSec: _durationSec,
      );
      if (!mounted) return;
      setState(() {
        _uploading = false;
        _success = 'Upload successful. A new CRM card was created.';
        _filePath = null;
        _durationSec = 0;
        _stopwatch = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _uploading = false;
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _uploading = false;
        _error = 'Upload failed. Please try again.';
      });
    }
  }

  void _resetRecording() {
    if (_recording) return;
    setState(() {
      _filePath = null;
      _durationSec = 0;
      _success = null;
      _error = null;
      _stopwatch = null;
    });
  }

  String _statusLabel() {
    if (_uploading) return 'Uploading...';
    if (_recording) return 'Recording...';
    if (_filePath != null) return 'Recorded';
    return 'Ready';
  }

  @override
  Widget build(BuildContext context) {
    final canUpload = !_recording &&
        !_uploading &&
        _filePath != null &&
        (_selectedCenterId != null) &&
        _durationSec >= 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Recorder'),
        actions: [
          TextButton(
            onPressed: _uploading ? null : widget.onLogout,
            child: const Text('Logout'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (kDebugMode)
              Text(
                'API: ${AppConfig.apiBaseUrl}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            if (_loadingCenters) const LoadingView(message: 'Loading centers...'),
            if (_centersError != null && !_loadingCenters)
              Text(
                _centersError!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            if (!_loadingCenters &&
                _centersError == null &&
                _centers.isEmpty)
              const Text('No active centers available.'),
            if (!_loadingCenters && _centers.isNotEmpty) ...[
              DropdownButtonFormField<String>(
                value: _selectedCenterId,
                decoration: const InputDecoration(
                  labelText: 'Center',
                  border: OutlineInputBorder(),
                ),
                items: _centers
                    .map(
                      (c) => DropdownMenuItem<String>(
                        value: c.id,
                        child: Text(c.name),
                      ),
                    )
                    .toList(),
                onChanged: _uploading || _recording
                    ? null
                    : (v) => setState(() => _selectedCenterId = v),
              ),
            ],
            const SizedBox(height: 24),
            Text('Status: ${_statusLabel()}'),
            const SizedBox(height: 8),
            Text('Duration: ${_durationSec}s'),
            const SizedBox(height: 24),
            Center(
              child: SizedBox(
                height: 88,
                width: 88,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: _uploading ? null : _toggleRecord,
                  child: Icon(
                    _recording ? Icons.stop : Icons.mic,
                    size: 40,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            AppButton(
              label: 'Upload',
              loading: _uploading,
              onPressed: canUpload ? _upload : null,
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: (_uploading || _recording || _filePath == null)
                  ? null
                  : _resetRecording,
              child: const Text('Record again'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            if (_success != null) ...[
              const SizedBox(height: 16),
              Text(
                _success!,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
