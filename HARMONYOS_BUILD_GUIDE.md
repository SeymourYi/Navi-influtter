# Flutter 打包鸿蒙应用指南

本指南将帮助您将现有的 Flutter 应用打包成鸿蒙（HarmonyOS）手机应用。

## 方法一：使用 OpenHarmony SIG 适配的 Flutter SDK（推荐）

### 前置要求

1. **安装 DevEco Studio**
   - 下载地址：https://developer.harmonyos.com/cn/develop/deveco-studio
   - 安装并配置好开发环境

2. **准备 Flutter SDK**
   - 当前项目使用的 Flutter SDK 版本：^3.7.2

### 步骤 1：获取 OpenHarmony 适配的 Flutter SDK

```bash
# 克隆 OpenHarmony SIG 适配的 Flutter SDK
git clone https://gitee.com/openharmony-sig/flutter_flutter.git

# 切换到项目目录
cd flutter_flutter

# 切换到稳定版本分支（根据实际情况选择）
git checkout <stable-branch>
```

### 步骤 2：配置环境变量

**Windows PowerShell:**
```powershell
# 设置环境变量（临时）
$env:PATH += ";C:\path\to\flutter_flutter\bin"

# 或者添加到系统环境变量（永久）
[System.Environment]::SetEnvironmentVariable("PATH", $env:PATH + ";C:\path\to\flutter_flutter\bin", "User")
```

**验证环境配置：**
```bash
flutter doctor -v
```

### 步骤 3：创建鸿蒙项目

1. 打开 DevEco Studio
2. 创建新项目，选择 **Empty Ability** 模板
3. 配置项目信息：
   - **Project Name**: Navi（或您喜欢的名称）
   - **Package Name**: 保持与原项目一致
   - **Compatible SDK Version**: 选择最新的 API 版本

### 步骤 4：集成 Flutter 模块

有两种集成方式：

#### 方式 A：基于 HAR 包集成（适用于发布）

1. **在 Flutter 项目中生成 HAR 包：**
   ```bash
   cd Navi-influtter
   flutter build har
   ```

2. **在 DevEco Studio 中引入 HAR 包：**
   - 将生成的 HAR 文件复制到鸿蒙项目的 `libs` 目录
   - 在 `build-profile.json5` 中添加依赖

#### 方式 B：基于源码集成（推荐用于开发）

1. **在鸿蒙项目中创建 Flutter 模块目录：**
   ```
   harmonyos_project/
   ├── entry/
   ├── flutter_module/  (新建)
   │   ├── lib/
   │   ├── pubspec.yaml
   │   └── ...
   ```

2. **复制 Flutter 项目源码：**
   ```bash
   # 将整个 lib 目录复制到 flutter_module
   cp -r Navi-influtter/lib harmonyos_project/flutter_module/
   cp Navi-influtter/pubspec.yaml harmonyos_project/flutter_module/
   ```

3. **配置 Flutter 依赖：**
   - 在鸿蒙项目的 `oh-package.json5` 中添加 Flutter 相关依赖

### 步骤 5：配置签名信息

#### 开发/测试阶段（自动签名）

1. 打开 DevEco Studio
2. 选择 `File` > `Project Structure`
3. 在 `Signing Configs` 中勾选 `Automatically generate signature`

#### 发布阶段（手动签名）

1. **在 AppGallery Connect 创建签名证书：**
   - 访问：https://developer.huawei.com/consumer/cn/service/josp/agc/
   - 创建应用并生成签名证书

2. **配置签名文件（build-profile.json5）：**
   ```json5
   {
     "signingConfig": {
       "release": {
         "certificatePath": "path/to/your/certificate.p12",
         "certificatePassword": "your_password",
         "profilePath": "path/to/your/profile.p7b",
         "profilePassword": "your_profile_password",
         "signAlg": "SHA256withECDSA",
         "storeFile": "path/to/your/keystore.jks",
         "storePassword": "your_store_password"
       }
     }
   }
   ```

### 步骤 6：构建应用

1. **在 DevEco Studio 中：**
   - 选择 `Build` > `Build Hap(s)/APP(s)` > `Build APP(s)`
   - 确保构建模式为 `release`

2. **构建完成后：**
   - 安装包位于：`build/outputs/default/entry-default-signed.hap`
   - 或 APP 包位于：`build/outputs/default/entry-default-signed.app`

### 步骤 7：发布应用

1. **在 AppGallery Connect 创建应用：**
   - 访问：https://developer.huawei.com/consumer/cn/service/josp/agc/
   - 创建新应用，填写应用信息

2. **上传安装包：**
   - 上传生成的 `.hap` 或 `.app` 文件
   - 填写应用详情、截图等信息

3. **提交审核：**
   - 完成所有必填信息后提交审核
   - 审核通过后应用即可上线

## 方法二：使用官方 Flutter 支持的鸿蒙平台（如果可用）

如果 Flutter 官方已支持鸿蒙平台，您可以直接使用：

```bash
# 检查 Flutter 支持的平台
flutter devices

# 如果支持鸿蒙，可以直接构建
flutter build harmonyos
```

## 注意事项

1. **插件兼容性：**
   - 检查项目中使用的所有 Flutter 插件是否支持鸿蒙平台
   - 部分插件可能需要适配或替换

2. **原生代码适配：**
   - 如果项目中使用了原生 Android/iOS 代码，需要转换为鸿蒙的 ArkTS/ArkUI
   - 检查 `android/` 和 `ios/` 目录中的原生代码

3. **API 差异：**
   - 某些 Android/iOS 特有的 API 在鸿蒙上可能不可用
   - 需要查找鸿蒙对应的替代方案

4. **测试：**
   - 在鸿蒙设备或模拟器上充分测试应用功能
   - 确保所有功能正常运行

## 常见问题

### Q1: Flutter 官方是否支持鸿蒙？
A: 目前 Flutter 官方还未正式支持鸿蒙平台，需要使用 OpenHarmony SIG 社区适配的版本。

### Q2: 如何检查插件是否支持鸿蒙？
A: 检查插件的 pub.dev 页面或 GitHub 仓库，查看是否支持鸿蒙/HarmonyOS 平台。

### Q3: 构建失败怎么办？
A: 
- 检查 Flutter SDK 版本是否正确
- 确认所有依赖都已正确安装
- 查看构建日志中的具体错误信息
- 参考 OpenHarmony SIG 的文档和社区支持

## 参考资源

- OpenHarmony SIG Flutter 仓库：https://gitee.com/openharmony-sig/flutter_flutter
- DevEco Studio 官方文档：https://developer.harmonyos.com/cn/documentation
- AppGallery Connect：https://developer.huawei.com/consumer/cn/service/josp/agc/
- 鸿蒙开发者社区：https://developer.huawei.com/consumer/cn/

## 当前项目特殊配置

根据您的项目配置，需要注意以下插件可能需要适配：

- `jverify` - 极光认证，需要确认鸿蒙版本
- `photo_manager` - 照片管理，可能需要适配
- `permission_handler` - 权限处理，需要适配鸿蒙权限系统

建议在集成前先测试这些核心功能是否正常工作。

