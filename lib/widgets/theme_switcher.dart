import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../providers/theme/theme_provider.dart';

/// 主题切换器组件 - 用于调试和手动切换主题
class ThemeSwitcher extends ConsumerWidget {
  const ThemeSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final themeNotifier = ref.read(themeModeProvider.notifier);
    final effectiveBrightness = themeNotifier.getEffectiveBrightness();
    final systemBrightness = themeNotifier.getSystemBrightness();

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Row(
              children: [
                Icon(
                  Iconsax.brush_2,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '主题设置',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 当前状态显示
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusRow(
                    context,
                    '系统主题',
                    systemBrightness == Brightness.light ? '☀️ Light' : '🌙 Dark',
                  ),
                  const Divider(height: 16),
                  _buildStatusRow(
                    context,
                    '应用设置',
                    _getThemeModeText(themeMode),
                  ),
                  const Divider(height: 16),
                  _buildStatusRow(
                    context,
                    '实际使用',
                    effectiveBrightness == Brightness.light ? '☀️ Light 模式' : '🌙 Dark 模式',
                    highlight: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 主题切换按钮
            Text(
              '选择主题模式',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ThemeModeButton(
                    icon: Iconsax.sun_1,
                    label: 'Light',
                    isSelected: themeMode == ThemeMode.light,
                    onTap: () => themeNotifier.setLightMode(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ThemeModeButton(
                    icon: Iconsax.moon,
                    label: 'Dark',
                    isSelected: themeMode == ThemeMode.dark,
                    onTap: () => themeNotifier.setDarkMode(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ThemeModeButton(
                    icon: Iconsax.setting_2,
                    label: 'System',
                    isSelected: themeMode == ThemeMode.system,
                    onTap: () => themeNotifier.setSystemMode(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(
    BuildContext context,
    String label,
    String value, {
    bool highlight = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
                color: highlight
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
              ),
        ),
      ],
    );
  }

  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return '☀️ Light (强制)';
      case ThemeMode.dark:
        return '🌙 Dark (强制)';
      case ThemeMode.system:
        return '🔄 System (自动)';
    }
  }
}

class _ThemeModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeModeButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurface,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
