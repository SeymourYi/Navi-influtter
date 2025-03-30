class AppConfig {
  // 根据不同运行环境更改这里的服务器地址
  // 模拟器上使用 10.0.2.2 (Android)
  // 真机上使用你电脑的局域网 IP，如 192.168.1.x
  // 如果是 Web 应用，可以使用 window.location.hostname

  // 可选配置，根据实际情况选择：
  // static const String serverHost = '10.0.2.2';       // Android 模拟器访问本机
  // static const String serverHost = '122.51.93.212'; // 物理机 WLAN IP
  // static const String serverHost = '192.168.88.1'; // VMware 网络 IP
  // static const String serverHost = 'localhost';     // 本机测试

  // 服务器配置
  // 可以在运行时通过setServerConfig方法修改
  static String serverHost = '122.51.93.212'; // 默认服务器IP
  // static String serverHost = '192.168.88.1'; // 默认服务器IP
  static int serverPort = 5487; // 默认服务器端口
  static bool enableSockJS = true; // 是否启用SockJS备用连接

  // 完整的服务器URL
  static String get serverUrl => '$serverHost:$serverPort';
  static String get wsUrl => 'ws://$serverUrl/ws';
  static String get httpUrl => 'http://$serverUrl';

  // 更新服务器配置
  static void setServerConfig({String? host, int? port, bool? useSockJS}) {
    if (host != null) serverHost = host;
    if (port != null) serverPort = port;
    if (useSockJS != null) enableSockJS = useSockJS;
    print('更新服务器配置: $serverUrl, SockJS: $enableSockJS');
  }

  // 重置为本地测试配置
  static void setLocalConfig() {
    serverHost = 'localhost';
    serverPort = 8080;
    enableSockJS = true;
    print('已切换到本地测试配置: $serverUrl');
  }
}
