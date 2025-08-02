import 'env.dart';

class ProdConfig implements EnvConfig {
  @override
  String get baseUrl => 'https://api-ndol-v2-prod.nongdanonline.cc';
}
