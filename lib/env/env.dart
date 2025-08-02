import 'env_dev.dart';
import 'env_prod.dart';

abstract class EnvConfig {
  String get baseUrl;
}

class Environment {
  static late EnvConfig config;

  static void setDev() {
    config = DevConfig();
  }

  ///khi nao up len android thi bat
  static void setProd() {
    config = ProdConfig();
  }
}
