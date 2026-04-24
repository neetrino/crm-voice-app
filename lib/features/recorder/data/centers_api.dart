import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../models/center_model.dart';

class CentersApi {
  CentersApi(this._client);

  final ApiClient _client;

  Future<List<CenterModel>> fetchCenters() async {
    try {
      final res = await _client.getJson('/admin/centers');
      final data = res.data;
      if (data is! List<dynamic>) {
        throw ApiException('Unexpected centers response.');
      }
      return data
          .map((e) => CenterModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
