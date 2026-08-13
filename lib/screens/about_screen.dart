import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


/// 构建时间（构建时通过 --dart-define=BUILD_TIME 注入，未注入用回退值）
const String _buildTime = String.fromEnvironment('BUILD_TIME', defaultValue: '2026-08-13 18:38:32');
/// 关于页：App 图标 + 名称 + 简介 + 版本 + 链接 + 构建时间/版权
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _openGitHub() async {
    final uri = Uri.parse('https://github.com/zzzjjj-ss/train-log-app');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('关于'), centerTitle: true),
      body: Column(
        children: [
          // 主内容：严格垂直居中
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset('assets/app_icon.png', width: 84, height: 84),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '铁路运转日志',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'v0.4.0-beta',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),
                  Text('为铁路迷打造的运转记录工具', style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 6),
                  Text(
                    '车票样式 · 购票信息 · 数据导出',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 28),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: _openGitHub,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.link, size: 16, color: theme.colorScheme.primary),
                          const SizedBox(width: 6),
                          Text(
                            'github.com/zzzjjj-ss/train-log-app',
                            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 底部：构建时间 + 版权
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '构建于 $_buildTime',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 4),
                Text(
                  'Copyright (c) 2026 zzzjjj-ss',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
