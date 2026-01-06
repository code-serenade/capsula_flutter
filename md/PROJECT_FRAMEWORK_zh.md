# Capsula Flutter 项目代码框架（可扩展指南）

> 目标：把本仓库当成一个“可扩展的功能框架”。当你让 AI 生成新功能时，应严格遵循本文描述的目录分层、状态管理、路由与本地存储等既有模式，避免引入与现有架构冲突的新风格。

---

## 1. 技术栈与核心约束

### 1.1 技术栈（按重要性）

- **Flutter / Material 3**：UI 框架与组件体系（`ThemeData(useMaterial3: true)`）。
- **状态管理：Riverpod 3 + 代码生成**
  - 依赖：`hooks_riverpod`, `riverpod_annotation`
  - 生成：`riverpod_generator` + `build_runner`
- **路由：AutoRoute 10**
  - `@RoutePage()` 标注页面
  - `@AutoRouterConfig(...)` 集中声明路由树
  - 生成文件：`lib/routes/router.gr.dart`
- **网络：Dio**
  - 自封装 `HttpClient`（JSON / Upload 两种配置）
  - 统一错误拦截（把 Dio 的网络/业务错误转换为可读消息）
- **本地持久化：Drift + SQLite（仅 IO 平台）**
  - 通过 conditional import 在 Web 上直接抛 `UnsupportedError`
- **本地文件沙盒：SandboxService（仅 IO 平台）**
  - 统一在应用支持目录创建 `AppSandbox/`
  - 所有文件写入/复制必须走 `SandboxService`
- **国际化：flutter gen-l10n**
  - ARB 位于 `assets/l10n/`
  - 输出位于 `lib/gen/`

### 1.2 平台约束（必须理解）

- **Web 不支持**：`SandboxService` 与 Drift Web 实现被显式禁用/抛错。
  - DB：`lib/services/db/app_database_connection_web.dart`
  - Sandbox：`lib/services/storage/sandbox_service_stub.dart`
- 任何依赖本地 DB/文件的功能都应默认按 **iOS/Android/macOS/Windows/Linux** 扩展。

### 1.3 代码生成约束（必须遵守）

- 你**不应该手改**任何生成文件：
  - `*.g.dart`（Riverpod / json_serializable / drift）
  - `*.gr.dart`（AutoRoute）
  - `lib/gen/*`（l10n 输出）
- 当你新增/修改带注解的内容（`@riverpod` / `@RoutePage` / `@JsonSerializable` / Drift 表）后，需要运行生成命令（见文末）。

---

## 2. 目录结构与职责边界（“框架骨架”）

项目采用“按层 + 按领域组合”的结构（不是严格 Clean Architecture，但有明确分层）。

### 2.1 `lib/` 顶层目录

- `lib/main.dart`：应用入口与启动流程（env 加载、沙盒/数据库初始化、MaterialApp.router 配置）。
- `lib/routes/`：路由树定义（AutoRoute），属于**全局骨架**。
- `lib/providers/`：Riverpod 状态（含 Notifier / AsyncNotifier）与依赖注入入口。
- `lib/helpers/`：偏“业务编排/用例层”
  - Repository（聚合 DB + 文件沙盒）
  - Controller（需要 `BuildContext` 的 UI 流程编排：弹窗、导航、交互）
- `lib/services/`：偏“基础设施层”
  - HTTP client
  - DB / Drift 连接与表
  - Sandbox 文件系统能力
- `lib/models/`：领域/DTO 模型（含 `json_serializable` 输出）。
- `lib/pages/`：页面级 UI（AutoRoute `@RoutePage()` 的页面必须放这）。
- `lib/widgets/`：可复用 UI 组件（页面内部的可拆分部件）。
- `lib/theme/`：主题体系、子主题配置、主题相关扩展（如健康数据颜色扩展）。
- `lib/constants/`：颜色/尺寸/常量（包含部分 demo 常量，注意甄别是否业务相关）。
- `lib/utils/`：通用工具（格式化、校验、系统能力包装、文件打开）。
- `lib/gen/`：生成代码（l10n），不要手改。

> 扩展原则：**新功能优先按“领域”落到 `providers/ + helpers/ + pages/ + widgets/ + models/`**，基础能力才落到 `services/`。

---

## 3. 启动流程（App Bootstrap）——从 `main()` 到首屏

入口：`lib/main.dart`

启动步骤（严格顺序）：

1. `WidgetsFlutterBinding.ensureInitialized()`
2. `dotenv.load(fileName: "assets/.env")`
   - `.env` 在 `pubspec.yaml` 的 `assets:` 中声明，会被打包进应用。
   - 常见 key：`API_BASE_URL`, `API_AUTH_URL`, `API_FILE_URL` 等（不要在文档/日志中暴露密钥值）。
3. `SandboxService.instance.initialize()`
   - 在本地创建/确保沙盒目录结构（详见第 7 节）。
4. `AppDatabase.ensureInstance()`
   - 初始化 Drift/SQLite，依赖 Sandbox 目录中的 `db/`。
5. `runApp(ProviderScope(child: App()))`
   - Riverpod 全局容器入口。

`App`（`ConsumerWidget`）的关键点：

- `final locale = ref.watch(localeProvider);`
- `final themeMode = ref.watch(themeModeProvider);`
- `MaterialApp.router(...)` 绑定：
  - `routerConfig: _appRouter.config()`
  - `theme / darkTheme / themeMode`
  - `locale / supportedLocales / localizationsDelegates`

> 扩展原则：任何需要在应用启动前初始化的能力（例如新数据库、缓存、密钥初始化）应按这个路径放到 `main()`，并保持“先基础设施后 UI”的顺序。

---

## 4. 路由体系（AutoRoute）与页面组织

### 4.1 路由树入口

文件：`lib/routes/router.dart`

- `@AutoRouterConfig(replaceInRouteName: 'Page,Route')`
  - 约定：页面类名通常以 `Page` 结尾，生成的路由类以 `Route` 结尾。
  - 例如 `HealthDataPage` → 生成 `HealthDataRoute`

当前路由结构：

- `/sign-in` → `SignInPage`
- `/`（初始）→ `MainTabLayoutPage`（下挂 children）
  - `/home` → `HomePage`（initial）
  - `/health-data` → `HealthDataPage`
  - `/me` → `MePage`

### 4.2 Tab 容器页

文件：`lib/pages/layouts/main_tab_layout.dart`

关键点：

- 使用 `AutoTabsRouter(routes: const [HomeRoute(), HealthDataRoute(), MeRoute()])`
- `NavigationBar` 控制 `tabsRouter.setActiveIndex(index)`
- AppBar 标题根据当前 Tab 的 `Route.name` 切换
- 右上角 Actions 放了 `LanguagePickerWidget`（Locale 切换）

### 4.3 新增页面/路由的标准流程

1. 在 `lib/pages/...` 创建页面，并添加 `@RoutePage()`
2. 在 `lib/routes/router.dart` 中 import 页面并添加 `AutoRoute(page: XxxRoute.page, path: ...)`
3. 运行 build_runner 生成 `router.gr.dart`
4. 在需要的地方使用：
   - `context.router.push(XxxRoute(...))`
   - 或 `context.router.replace(...) / replacePath(...)`

> 重要：**不要直接编辑 `router.gr.dart`**，它会被覆盖。

---

## 5. 状态管理（Riverpod 3）——全项目“扩展接口”

目录：`lib/providers/`

该项目的状态管理主要分两种风格：

### 5.1 生成式 Provider（推荐，默认）

通过 `riverpod_annotation` 的 `@riverpod`：

- **函数式 Provider**：适合单例对象/依赖注入。
  - 例：`configProvider`（返回 `Config` 单例）
  - 例：`sandboxServiceProvider`（返回 `SandboxService.instance`）
- **Notifier Provider（同步状态）**：适合纯 UI 状态。
  - 例：`LocaleNotifier`、`ThemeModeNotifier`、`HealthDataView`
- **AsyncNotifier Provider（异步状态）**：适合从 DB/网络加载列表等。
  - 例：`HealthAssets`：`Future<List<HealthAsset>> build({query, tags})`

文件特征：

- 必须包含 `part 'xxx_provider.g.dart';`
- Notifier 类名通常为 `XxxNotifier extends _$XxxNotifier`
- provider 名由生成器决定（例如 `ThemeModeNotifier` → `themeModeProvider`）

### 5.2 手写 Provider（用于 Controller/Service 编排）

当类需要持有 `Ref` 并做“流程编排”（弹窗、选择文件、导航等）时，使用 `Provider(...)`：

- `healthDataImportControllerProvider`
- `healthDataSearchControllerProvider`
- `healthAssetDetailControllerProvider`
- `healthAssetPreviewServiceProvider`

这种类通常放在 `lib/helpers/...`，原因：

- 它不是纯 UI Widget
- 也不是纯数据服务（往往桥接 UI 与业务状态）

### 5.3 Riverpod 使用约定（扩展时必须一致）

- 在 UI 中：
  - 读取状态：`ref.watch(xxxProvider)`
  - 调用行为：`ref.read(xxxProvider.notifier).doSomething()`
- 处理异步列表：
  - `AsyncValue<T>` 用 `when(data/loading/error)` 渲染
  - 刷新用 `AsyncLoading()` + `AsyncValue.guard(...)`
- “UI 的瞬时状态” vs “业务持久状态”：
  - UI 筛选/搜索/视图切换：放 `HealthDataViewState`
  - 资产列表来自 DB：放 `HealthAssets`（AsyncNotifier）

---

## 6. 领域模型（models）与数据流

### 6.1 健康资产（HealthAsset）是核心实体

文件：`lib/models/health_asset.dart`

`HealthAsset` 字段包含：

- 标识：`id`
- 展示：`filename`, `note`, `tags`
- 文件定位：`path`（沙盒内相对路径）、`mime`, `sizeBytes`, `hashSha256`
- 分类：`dataSource`（来源）、`dataType`（类型）
- 扩展：`metadata`（自由 JSON）
- 时间：`createdAt`, `updatedAt`

并提供：

- `fromMap/toMap`：与 DB 表字段对应（字符串时间、json 字符串等）
- `toRecord()`：转换为 UI 用的 `HealthDataRecord`

### 6.2 健康数据枚举与展示扩展

文件：`lib/models/health_data_model.dart`

- 枚举：
  - `HealthDataType`（血压/血糖/心率/体检/用药/其他）
  - `DataSource`（camera/upload/manual/device/voice）
- extension：
  - `displayName`：在 UI 中直接使用，避免散落硬编码
- `DataCollectionMethod.methods`：采集方式配置（用于网格展示与导入逻辑）

> 扩展原则：新增健康数据类型时，至少同时修改：
>
> - `HealthDataType` 枚举
> - `HealthDataTypeDisplayName` 显示名
> - （可选）`theme/health_data_colors.dart` 给类型配色
> - UI 快捷筛选/标签（如果需要）

---

## 7. 本地文件沙盒（SandboxService）

入口导出：`lib/services/storage/sandbox_service.dart`

- IO 平台会导出：`sandbox_service_io.dart`
- 非 IO 平台会导出：`sandbox_service_stub.dart`（直接抛错）

### 7.1 沙盒目录结构（初始化后保证存在）

`SandboxService.initialize()` 会创建（示意）：

```
AppSandbox/
  db/
  files/
    images/
    audio/
    doc/
      pdf/
      word/
      excel/
      manual/
  config/
    settings.json
  secure/
    key_store/
```

### 7.2 使用原则（非常重要）

- DB 与业务文件都必须落在 `AppSandbox/` 内，防止越界访问。
- DB/文件路径在业务层只存 **相对路径**：
  - `HealthAsset.path` 存的是 `files/...` 这种相对路径
  - 绝不把系统绝对路径写进 DB（除非只用于调试，并明确不持久化）
- 文件写入/复制统一走：
  - `writeTextFile(...)`
  - `copyIntoSandbox(...)`
  - `resolvePath(...) / fileFor(...)`

### 7.3 资产导入落盘策略（现有实现）

`HealthAssetRepository` 会按 MIME/后缀把文件放到对应目录：

- 图片 → `files/images/`
- 音频 → `files/audio/`
- PDF → `files/doc/pdf/`
- Word → `files/doc/word/`
- Excel → `files/doc/excel/`
- 其他 → `files/doc/`
- 手动输入 → `files/doc/manual/`（生成 `.txt`）

---

## 8. 本地数据库（Drift + SQLite）

入口：`lib/services/db/app_database.dart`

核心结构：

- `AppDatabase` 是 Drift Database 单例（`ensureInstance()`）
- 通过 conditional import 选择 executor：
  - IO：`NativeDatabase.createInBackground(File(dbPath))`
  - Web/Stub：直接抛 `UnsupportedError`
- 当前 `schemaVersion = 1`

### 8.1 HealthAsset 表与 DAO

文件：`lib/services/db/tables/health_asset/health_asset_table.dart`

- 表：`health_asset`
- DAO：`HealthAssetDao`
  - `insertAsset/updateAsset/deleteAsset/getAsset/fetchAssets`
  - `fetchAssets` 支持：
    - keyword 模糊匹配：filename/note/tags
    - tags 逐个 like（逗号分隔字符串）

### 8.2 新增表/字段的扩展规则

如果你要扩展新的可持久化实体：

1. 在 `lib/services/db/tables/<feature>/..._table.dart` 新建 Drift `Table`
2. 在 `@DriftDatabase(tables: [...])` 中把新表加入列表
3. 调整 `schemaVersion` 与 `migration`（否则旧数据无法升级）
4. 运行 build_runner 生成 `app_database.g.dart` 与 table mixin

> 注意：当前迁移策略很简单（`from < 1` 就 `createAll()`）。如果你开始在生产环境演进 schema，需要更精细的 migration 设计。

---

## 9. 网络层（Dio 封装）与 API 组织

### 9.1 HttpClient：对 Dio 的薄封装

文件：`lib/services/http/http_client.dart`

- `HttpClient.json(...)`：默认 JSON headers + baseUrl
- `HttpClient.upload(...)`：用于 multipart 上传（baseUrl 可为空，允许直接传完整 URL）
- 提供 `get/post/put/patch/delete` 以及 `postForm`、`uploadFile(s)`、`downloadFile`

### 9.2 ApiService：多个 baseURL + 统一错误拦截

文件：`lib/services/http/api_service.dart`

特点：

- 从 `.env` 读取：
  - `API_BASE_URL`
  - `API_AUTH_URL`
  - `API_FILE_URL`
- 生成 4 个全局 client（只暴露 HttpClient，不暴露 Dio）：
  - `httpClient`（base）
  - `authHttpClient`（auth）
  - `fileHttpClient`（file）
  - `uploadClient`（upload，无 baseUrl）
- 拦截器对 `DioException` 做统一错误消息转换：
  - 超时 → “连接超时，请重试”
  - 网络错误 → “网络错误，请检查网络连接”
  - badResponse → 尝试解析 `{ error: { message } }` 或按 statusCode fallback

### 9.3 API 模块的组织方式

目录：`lib/api/`

- `auth.dart`：认证相关 API（调用 `authHttpClient`）
- `upload.dart`：上传相关 API（先通过 `fileHttpClient` 获取 token，再用 `uploadClient` 上传）

> 扩展原则：新增远程接口时，优先按领域在 `lib/api/<domain>.dart` 增加函数；复杂时再引入 Repository 包装（但要避免重复已有的 `HttpClient`/错误拦截体系）。

---

## 10. UI 架构：Pages + Widgets + Controllers 的协作

以健康数据 Tab 为例，完整链路如下：

1. `HealthDataPage`（page）
2. 调用 controller：
   - `HealthDataImportController.startImport(...)` → 弹窗/选文件/提交
   - `HealthDataSearchController.startSearch(...)` → 弹搜索 dialog
   - `HealthAssetDetailController.showDetails(...)` → 底部弹窗详情
3. controller 调用 provider notifier：
   - `healthAssetsProvider(...).notifier.addFileAsset(...)`
4. provider 调用 repository：
   - `HealthAssetRepository.importFile(...)`
5. repository 调用基础设施：
   - `SandboxService.copyIntoSandbox(...)`
   - `HealthAssetDao.insertAsset(...)`
6. provider 更新 `AsyncValue<List<HealthAsset>>`
7. UI 通过 `ref.watch(...)` 自动刷新

这种拆法的价值：

- 页面只负责“布局与组合”
- 复杂交互流程放在 controller（更容易复用/测试）
- 数据写入集中在 repository（可扩展、可替换）

---

## 11. 国际化（l10n）约定

配置：`l10n.yaml`

- ARB 目录：`assets/l10n`
- 模板：`app_en.arb`
- 输出：`lib/gen/app_localizations.dart`（及多语言分拆文件）

使用方式：

- 在 Widget 中：
  - `final localizations = AppLocalizations.of(context)!;`
  - `localizations.<key>`
- 支持语言列表：`lib/l10n.dart` 中 `L10n.all`
- 语言状态：`localeProvider`
- 语言切换 UI：
  - `LanguagePickerWidget`（AppBar 右上角）
  - `MePage` 里也提供语言选择卡片

新增文案流程：

1. 在 `assets/l10n/app_en.arb` 加 key/value
2. 同步补齐 `assets/l10n/app_zh.arb`、`assets/l10n/app_zh_TW.arb`
3. 运行 `flutter gen-l10n`
4. 在代码里使用 `AppLocalizations` 访问新 key

---

## 12. 主题系统（Theme）

入口：`lib/theme/app_theme.dart`

- `AppTheme.lightTheme(context)` / `AppTheme.darkTheme(context)`
  - 设置 `colorScheme`、`textTheme`、各组件 theme（Button/Chip/AppBar/...）
- 主题模式状态：`themeModeProvider`（`ThemeModeNotifier`）
  - `ThemeMode.system/light/dark`
  - `getEffectiveBrightness()` 用于展示当前实际生效主题
- 业务色彩扩展：
  - `lib/theme/health_data_colors.dart` 为不同 `HealthDataType` 提供自适应配色

扩展建议：

- UI 颜色尽量使用：
  - `Theme.of(context).colorScheme.*`
  - 或领域扩展（例如 `theme.getHealthDataColor(type)`）
- 避免在业务 UI 中写死颜色值（除非是临时 demo）。

---

## 13. 测试策略（当前项目的最低要求）

目录：`test/`

现有测试覆盖：

- `test/theme_test.dart`：主题/健康数据配色扩展
- `test/providers/health_data_view_provider_test.dart`：`HealthDataView` 默认值与状态变更
- `test/services/health_asset_filter_service_test.dart`：过滤逻辑正确性

扩展建议：

- 新增纯函数逻辑 → 优先加 unit test（类似 filter service）
- 新增 provider（非 UI） → 用 `ProviderContainer()` 验证状态变更
- 新增 widget 复杂渲染 → 再考虑 widget test（当前项目以 unit 为主）

---

## 14. 代码生成与常用命令（开发时必备）

### 14.1 安装依赖

```bash
flutter pub get
```

### 14.2 生成国际化

```bash
flutter gen-l10n
```

### 14.3 运行代码生成（Riverpod/AutoRoute/json/drift）

```bash
dart run build_runner build --delete-conflicting-outputs
```

开发时监听：

```bash
dart run build_runner watch --delete-conflicting-outputs
```

### 14.4 静态检查与测试

```bash
flutter analyze
flutter test
```

---

## 15. 新功能扩展“规范化流程”（给 AI 的硬性约束清单）

> 你可以把这一节当作“生成新功能的提示词模板”。当 AI 生成代码时，按此清单逐项落地，就能最大概率与现有框架一致。

### 15.1 新增一个“新页面”功能（不涉及 DB/文件）

1. `lib/pages/<feature>/<feature>_page.dart`
   - `@RoutePage()`
   - `Widget build(...)` 内只做布局与组合
2. `lib/routes/router.dart`
   - 添加 `AutoRoute(page: XxxRoute.page, path: 'xxx')`
3. 如果有状态：
   - `lib/providers/<feature>/<feature>_provider.dart` 用 `@riverpod`
4. 运行 build_runner

### 15.2 新增一个“新 Tab”

1. 新建页面：`lib/pages/tabs/<new_tab>_page.dart`（`@RoutePage()`）
2. `lib/routes/router.dart`
   - 在 `MainTabLayoutRoute.children` 中加入新 tab route
3. `lib/pages/layouts/main_tab_layout.dart`
   - `AutoTabsRouter(routes: [...])` 加入新 route
   - `NavigationBar.destinations` 加一个 item
   - AppBar 标题 switch 加一项（按 `Route.name`）
4. build_runner 生成路由

### 15.3 新增一个“可持久化实体”（DB + 本地文件可选）

推荐拆分：

- 领域模型：`lib/models/<feature>/<entity>.dart`
- Drift 表/DAO：`lib/services/db/tables/<feature>/<entity>_table.dart`
- Repository：`lib/helpers/<feature>/<feature>_repository.dart`
- Provider：`lib/providers/<feature>/<feature>_provider.dart`
- UI：`lib/pages/...` + `lib/widgets/...`

关键规则：

- 任何文件落盘必须通过 `SandboxService`
- DB 中存相对路径，不存系统绝对路径
- 修改 drift schema 后：
  - 更新 `schemaVersion`
  - 写 migration
  - 运行 build_runner

### 15.4 新增一个“远程 API 对接”功能

1. 选择合适 client：
   - 业务：`httpClient`
   - 认证：`authHttpClient`
   - 文件：`fileHttpClient`
   - 上传：`uploadClient`
2. 新增 API 文件：`lib/api/<domain>.dart`
3. DTO 模型放 `lib/models/<domain>/...`，用 `@JsonSerializable`
4. 在 UI 里捕获错误时优先展示 `DioException.error`（项目拦截器已把它转换成用户可读文本）

### 15.5 Riverpod Provider 写法模板（建议）

同步状态（UI 状态）：

```dart
@riverpod
class XxxState extends _$XxxState {
  @override
  XxxViewState build() => const XxxViewState();

  void updateSomething(...) {
    state = state.copyWith(...);
  }
}
```

异步状态（列表/加载）：

```dart
@riverpod
class XxxItems extends _$XxxItems {
  @override
  Future<List<Item>> build({String query = ''}) async {
    final repo = ref.watch(xxxRepositoryProvider);
    return repo.fetch(query: query);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(xxxRepositoryProvider);
      return repo.fetch(query: query);
    });
  }
}
```

### 15.6 不要做的事情（避免破坏框架一致性）

- 不要引入新的状态管理框架（Bloc/GetX/MobX 等）与现有 Riverpod 混用。
- 不要绕过 `SandboxService` 直接读写文件。
- 不要把业务写入逻辑塞进 Widget（应该在 repository/provider/controller）。
- 不要手改 `*.g.dart / *.gr.dart / lib/gen/*`。
- 不要在文档/日志中写出 `.env` 中的密钥值（即使它看起来是 demo）。

---

## 16. 快速定位：当你要改/加功能时应该先看哪里？

- 想加入口/路由 → `lib/routes/router.dart` + `lib/pages/...`
- 想加页面 UI → `lib/pages/...`（大布局）+ `lib/widgets/...`（拆组件）
- 想加状态/交互 → `lib/providers/...`（状态）+ `lib/helpers/...`（流程编排）
- 想落地本地文件 → `lib/services/storage/*` + `HealthAssetRepository` 的写法
- 想落地本地 DB → `lib/services/db/*`
- 想接后端接口 → `lib/services/http/*` + `lib/api/*`
- 想加多语言 → `assets/l10n/*.arb` + `flutter gen-l10n`

