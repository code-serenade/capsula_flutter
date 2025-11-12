# Capsula Flutter 客户端

[English Version](README.md)

基于 Flutter + Riverpod 的 Capsula 健康数据客户端。该应用在本地沙盒中管理健康资产（手动笔记、文件上传、设备同步数据），通过 AutoRoute 多标签页展示，使用 Drift 进行本地持久化。

## 环境要求

- Flutter 3.19+（Dart 3.9）
- macOS 或 Linux（如需构建 iOS，则需安装 Xcode）
- `fluttergen` 与 `build_runner` 可通过 `dart run` 调用

## 快速开始

```bash
git clone <repo>
cd capsula_flutter
cp assets/example.env assets/.env   # 配置 API 地址
flutter pub get
flutter gen-l10n
fluttergen -c pubspec.yaml
dart run build_runner build --delete-conflicting-outputs
```

### 常用命令

| 目的 | 命令 |
| --- | --- |
| 安装依赖 | `flutter pub get` |
| 生成多语言文件 | `flutter gen-l10n` |
| 重新生成 asset 绑定 (`flutter_gen`) | `fluttergen -c pubspec.yaml` |
| 运行代码生成（Riverpod/AutoRoute/json） | `dart run build_runner build --delete-conflicting-outputs` |
| 开发时监听文件变化 | `dart run build_runner watch --delete-conflicting-outputs` |

## 运行方式

- **iOS / macOS / Android**：`flutter run -d <deviceId>`
- **Web**：暂不支持（Web 端禁用了 Drift 存储，会抛出异常）。

## 测试与检查

```bash
flutter analyze
flutter test
```

当前单元/组件测试覆盖主题、健康数据 Provider、过滤逻辑等。建议将新的测试放在对应功能目录下。

## 目录结构

- `lib/main.dart`：应用入口，负责 `.env` 加载、沙盒/数据库初始化、路由配置。
- `lib/providers/`：Riverpod 状态 + 生成的 `.g.dart` 文件。
- `lib/services/`：HTTP 客户端、沙盒工具、Drift 连接、健康数据控制器等。
- `lib/pages/`：AutoRoute 页面（登录、主标签页等）。
- `lib/widgets/health_data/`：复用性强的健康数据组件（采集网格、筛选器、卡片、弹窗）。
- `lib/theme/`：主题配置与子主题。
- `assets/`：ARB 多语言文件、环境配置、静态资源。

## 本地沙盒架构

`SandboxService` 在启动时会创建 `AppSandbox` 目录：

- `db/app_data.db`：Drift/SQLite 数据库。
- `files/`：用户文件
  - `images/`、`audio/`、`doc/{pdf,word,excel,manual}`
- `config/settings.json`：偏好配置（语言、主题等）。
- `secure/key_store/`：密钥或加密材料。

应用中的仓库/服务均使用沙盒相对路径，确保文件不会越界。

## 健康资产存储

所有健康资产写入 `health_asset` 表：

| 列名 | 说明 |
| --- | --- |
| `id` | 自增主键 |
| `filename` | 原始或用户输入的文件名 |
| `path` | 沙盒内相对路径 |
| `mime` | MIME 类型 |
| `size_bytes` | 文件大小 |
| `hash_sha256` | 哈希值（去重/校验） |
| `data_source` | 数据来源（camera/upload/manual/device/voice） |
| `data_type` | 数据类型（bloodPressure、checkup 等） |
| `note` | 备注 |
| `tags` | 逗号分隔标签 |
| `metadata_json` | 额外 JSON 信息 |
| `created_at` / `updated_at` | ISO 时间戳 |

`HealthAssetRepository` 负责生成文档、移动文件、计算哈希，并同步 Riverpod 状态 (`healthAssetsProvider`)。Health Data 页面通过过滤/搜索/详情弹窗来展示这些记录。

## 常见问题

- **在 Codex CLI 中运行 `flutter analyze` / `flutter test` 报权限错误**：请在本地终端执行，Flutter 需要写 `bin/cache`。
- **桌面端无法预览文件**：确保通过 `flutter run` 启动过应用，`SandboxService` 会在此阶段创建沙盒。
- **找不到多语言或资源**：重新运行 `flutter gen-l10n` 与 `fluttergen -c pubspec.yaml`。

## 许可证

MIT License。
