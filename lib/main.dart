import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:capsula_flutter/theme/app_theme.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'gen/app_localizations.dart';
import 'l10n.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';
import 'routes/router.dart';
import 'services/db/app_database.dart';
import 'services/storage/sandbox_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");

  await SandboxService.instance.initialize();
  await AppDatabase.ensureInstance();

  // 打印系统主题信息
  final systemBrightness =
      SchedulerBinding.instance.platformDispatcher.platformBrightness;
  // ignore: avoid_print
  print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  // ignore: avoid_print
  print('🚀 应用启动 - 系统主题检测');
  // ignore: avoid_print
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  // ignore: avoid_print
  print(
    '📱 当前系统主题: ${systemBrightness == Brightness.light ? "☀️ Light Mode" : "🌙 Dark Mode"}',
  );
  // ignore: avoid_print
  print('📱 Brightness 枚举值: $systemBrightness');
  // ignore: avoid_print
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

  runApp(ProviderScope(child: App()));
}

class App extends ConsumerWidget {
  App({super.key});

  final _appRouter = AppRouter();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Demo',
      themeMode: themeMode,
      theme: AppTheme.lightTheme(context),
      darkTheme: AppTheme.darkTheme(context),
      routerConfig: _appRouter.config(),
      locale: locale,
      supportedLocales: L10n.all,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
    );
  }
}
