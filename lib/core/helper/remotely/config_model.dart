enum Environment {
  test,
  pre,
  pro,
}

class ConfigModel {
  static late String serverFirstHalfOfImageimageUrl;
  static late String baseApiimageUrlSqueak;

  static void setEnvironment(Environment env) {
    switch (env) {
      case Environment.test:
        serverFirstHalfOfImageimageUrl =
            'https://veticareapi.veticareapp.com:8002/files/';
        baseApiimageUrlSqueak = 'https://squeakapi.veticareapp.com:8001';
        break;
      case Environment.pre:
        serverFirstHalfOfImageimageUrl =
            'https://vicapiub.veticareapp.com/files/';
        baseApiimageUrlSqueak = 'https://squeakapipro.veticareapp.com';
        break;
      case Environment.pro:
        serverFirstHalfOfImageimageUrl =
            'https://vicapipro.veticareapp.com/files/';
        baseApiimageUrlSqueak = 'https://squeakapipro.veticareapp.com';
        break;
    }
  }
}
