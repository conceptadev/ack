import 'package:test/test.dart';

import 'package:ack_example/additional_properties_example.dart';

void main() {
  group('Additional properties examples', () {
    test('additionalProperties excludes declared fields', () {
      final config = UserConfig.parse({
        'username': 'leo',
        'email': 'leo@example.com',
        'theme': 'dark',
        'retries': 3,
      });

      expect(config.username, 'leo');
      expect(config.email, 'leo@example.com');
      expect(config.additionalProperties, {'theme': 'dark', 'retries': 3});
    });

    test('passthrough additional properties are preserved', () {
      final request = ApiRequest.parse({
        'method': 'POST',
        'url': 'https://api.example.com/users',
        'headers': {'x-trace': '123'},
        'timeoutMs': 5000,
      });

      expect(request.method, 'POST');
      expect(request.url, 'https://api.example.com/users');
      expect(request.additionalProperties, {
        'headers': {'x-trace': '123'},
        'timeoutMs': 5000,
      });
    });

    test('empty-schema passthrough keeps all additional properties', () {
      final data = {'enabled': true, 'rollout': 25, 'label': 'beta'};
      final dynamicData = DynamicData.parse(data);

      expect(dynamicData.additionalProperties, data);
    });
  });
}
