import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';

class RecordingsApi {
  RecordingsApi(this._client);

  final ApiClient _client;

  Future<void> uploadRecording({
    required String filePath,
    required String centerId,
    required int durationSec,
  }) async {
    final fileName = p.basename(filePath);
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        filePath,
        filename: fileName,
      ),
      'centerId': centerId,
      'durationSec': durationSec.toString(),
    });
    try {
      await _client.postMultipart('/admin/recordings', formData: formData);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
