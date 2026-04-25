import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../models/voice_recording_history_item.dart';

class VoiceHistoryApi {
  VoiceHistoryApi(this._client);

  final ApiClient _client;

  Future<List<VoiceRecordingHistoryItem>> fetchRecordings() async {
    try {
      final res = await _client.getJson('/admin/voice-recordings');
      final items = _historyResponseToList(res.data)
          .map((item) => VoiceRecordingHistoryItem.fromJson(item))
          .toList();
      items.sort(_newestFirst);
      return items;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<VoiceRecordingHistoryItem?> updateCenter({
    required String leadId,
    required String centerId,
  }) async {
    try {
      final encodedLeadId = Uri.encodeComponent(leadId);
      final res = await _client.patchJson(
        '/admin/voice-recordings/$encodedLeadId/center',
        data: {'centerId': centerId},
      );
      final data = res.data;
      if (data is Map<String, dynamic>) {
        final item = data['item'] ?? data['recording'] ?? data;
        if (item is Map<String, dynamic>) {
          return VoiceRecordingHistoryItem.fromJson(item);
        }
      }
      return null;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

List<Map<String, dynamic>> _historyResponseToList(Object? data) {
  if (data is Map<String, dynamic>) {
    final items = data['items'] ?? data['recordings'] ?? data['data'];
    if (items is List<dynamic>) return _castItems(items);
  }
  if (data is List<dynamic>) return _castItems(data);
  throw ApiException('Չհաջողվեց բեռնել պատմությունը');
}

List<Map<String, dynamic>> _castItems(List<dynamic> items) {
  return items.whereType<Map<String, dynamic>>().toList();
}

int _newestFirst(
  VoiceRecordingHistoryItem a,
  VoiceRecordingHistoryItem b,
) {
  final aDate = a.createdAt;
  final bDate = b.createdAt;
  if (aDate == null && bDate == null) return 0;
  if (aDate == null) return 1;
  if (bDate == null) return -1;
  return bDate.compareTo(aDate);
}
