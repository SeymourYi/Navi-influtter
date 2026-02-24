# Navi - Flutter 社交应用（开发中）

<p align="center">
  <img src="https://via.placeholder.com/1200x400/6366f1/ffffff?text=Navi+社交+Flutter" alt="Navi Banner" width="80%"/>
</p>

<p align="center">
  使用 Flutter 开发的现代移动端社交应用，支持发帖、点赞、评论、转发、私信聊天等核心功能。
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.24+-02569B?style=flat&logo=flutter&logoColor=white" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Dart-3.5+-0175C2?style=flat&logo=dart&logoColor=white" alt="Dart"/>
  <img src="https://img.shields.io/badge/Platforms-Android%20%7C%20iOS%20%7C%20Web-blue?style=flat" alt="Platforms"/>
  <img src="https://img.shields.io/badge/状态-开发中-orange?style=flat" alt="Status"/>
</p>

## ✨ 当前核心功能（已部分实现 / 正在开发）

- 📝 发布帖子（文字 + 多图）
- ❤️ 点赞 / 取消点赞
- 💬 评论 + 回复评论
- 🔄 转发 / 引用式转发
- 📩 私信聊天（实时消息）
- 👤 个人主页 + 动态列表
- 发现页 / 推荐 feed 流
- 通知中心（点赞、评论、关注提醒）
- 暗黑模式支持

## 计划中的功能

- 视频帖子 / 短视频 feed
- 话题标签（#）
- 搜索（用户 / 内容）
- 关注 / 粉丝关系
- 内容举报 & 简单审核
- 多语言切换
- ...

## 技术栈（当前使用 / 计划）

- **UI 框架**：Flutter 3.2x+
- **状态管理**：Riverpod / Provider（待确认）
- **网络层**：dio + retrofit 或 http
- **本地存储**：shared_preferences + hive / drift
- **实时通信**：WebSocket 或 Supabase / Firebase（待选）
- **路由**：go_router
- **代码规范**：very_good_analysis
- **平台**：Android / iOS / Web（部分适配）

## 快速上手

### 环境要求

- Flutter 3.22+（推荐最新稳定版）
- Dart 3.4+
- Android Studio / VS Code + Flutter 插件

### 安装 & 运行

```bash
# 克隆仓库
git clone https://github.com/SeymourYi/Navi-influtter.git
cd Navi-influtter

# 获取依赖
flutter pub get

# （如果之前运行过有问题，建议先清理）
flutter clean
flutter pub get

# 运行（Android）
flutter run

# 运行（iOS，需 Mac）
flutter run -d ios

# 运行 Web（调试用）
flutter run -d chrome --web-port=52789