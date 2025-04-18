// 这是Web平台的Platform存根文件
// 在Web平台上提供一个兼容的Platform类实现

class Platform {
  static const bool isAndroid = false;
  static const bool isIOS = false;
  static const bool isWindows = false;
  static const bool isMacOS = false;
  static const bool isLinux = false;
  static const bool isFuchsia = false;

  static String get operatingSystem => 'web';

  static String get operatingSystemVersion => 'web';

  static String get localHostname => 'localhost';

  static int get numberOfProcessors => 1;

  static String get pathSeparator => '/';
}
