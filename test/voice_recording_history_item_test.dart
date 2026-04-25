import 'package:crm_voice_app/features/recorder/models/voice_recording_history_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses direct history item fields', () {
    final item = VoiceRecordingHistoryItem.fromJson({
      'leadId': 'lead-1',
      'createdAt': '2026-04-25T10:15:00.000Z',
      'durationSec': 42,
      'audioPath': '/storage/file/voice%2Fone.m4a',
      'centerId': 'center-1',
      'centerName': 'Կենտրոն',
    });

    expect(item.leadId, 'lead-1');
    expect(item.durationSec, 42);
    expect(item.audioPath, '/storage/file/voice%2Fone.m4a');
    expect(item.hasPlayableAudio, isTrue);
    expect(item.centerId, 'center-1');
    expect(item.centerName, 'Կենտրոն');
    expect(item.createdAt, isNotNull);
  });

  test('parses nested center and colon duration', () {
    final item = VoiceRecordingHistoryItem.fromJson({
      'id': 'lead-2',
      'duration': '01:05',
      'url': 'https://example.com/audio.wav',
      'center': {'id': 'center-2', 'name': 'Արաբկիր'},
    });

    expect(item.leadId, 'lead-2');
    expect(item.durationSec, 65);
    expect(item.centerId, 'center-2');
    expect(item.centerName, 'Արաբկիր');
  });

  test('builds playable storage path from r2Key', () {
    final item = VoiceRecordingHistoryItem.fromJson({
      'leadId': 'lead-3',
      'r2Key': 'voice/leads/example file.m4a',
    });

    expect(
      item.audioPath,
      '/storage/file/voice%2Fleads%2Fexample%20file.m4a',
    );
    expect(item.hasPlayableAudio, isTrue);
  });
}
