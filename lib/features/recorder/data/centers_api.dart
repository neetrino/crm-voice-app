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
      final rawList = _centersResponseToList(res.data);
      return rawList
          .map((e) => CenterModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

List<dynamic> _centersResponseToList(Object? data) {
  if (data is Map<String, dynamic>) {
    final items = data['items'];
    if (items is List<dynamic>) return items;
  }
  if (data is List<dynamic>) return data;
  throw ApiException('Չհաջողվեց բեռնել մասնաճյուղերը');
}
