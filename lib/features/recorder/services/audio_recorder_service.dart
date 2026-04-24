import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class AudioRecorderService {
  AudioRecorderService() : _recorder = AudioRecorder();

  final AudioRecorder _recorder;
  String? _currentPath;

  String? get currentPath => _currentPath;

  Future<bool> hasPermission() async {
    return _recorder.hasPermission();
  }

  Future<String> startRecording() async {
    final allowed = await hasPermission();
    if (!allowed) {
      throw StateError('Microphone permission was denied.');
    }

    final dir = await getTemporaryDirectory();
    final ts = DateTime.now().millisecondsSinceEpoch;
    final base = '${dir.path}${Platform.pathSeparator}voice_recording_$ts';

    try {
      final path = '$base.m4a';
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: path,
      );
      _currentPath = path;
      return path;
    } catch (_) {
      final path = '$base.wav';
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.wav),
        path: path,
      );
      _currentPath = path;
      return path;
    }
  }

  Future<String?> stopRecording() async {
    final path = await _recorder.stop();
    _currentPath = path ?? _currentPath;
    return _currentPath;
  }

  Future<void> dispose() async {
    try {
      await _recorder.stop();
    } catch (_) {
      /* not recording or already stopped */
    }
    await _recorder.dispose();
  }
}
