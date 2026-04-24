import 'package:flutter_test/flutter_test.dart';

import 'package:crm_voice_app/core/config/app_config.dart';

void main() {
  test('AppConfig default API base targets Android emulator host', () {
    expect(AppConfig.apiBaseUrl, 'http://10.0.2.2:4000/api');
  });
}
