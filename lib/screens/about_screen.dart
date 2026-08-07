import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// 关于页：项目信息
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
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 8),
          Center(
            child: Icon(Icons.train, size: 64, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              '铁路运转日志',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              '版本 v0.2.0-beta',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              '为铁路迷打造的运转记录工具',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.code),
                  title: const Text('GitHub'),
                  subtitle: const Text('zzzjjj-ss/train-log-app'),
                  trailing: const Icon(Icons.open_in_new, size: 18),
                  onTap: _openGitHub,
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.gavel),
                  title: Text('许可证'),
                  subtitle: Text('MPL-2.0（弱传播性）'),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.menu_book),
                  title: Text('车型数据来源'),
                  subtitle: Text('路路通公开页面（定员为参考值）'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '声明：本应用为铁路迷个人开发的运转记录工具。'
            '受版权保护的数据（如时刻表）不内置，数据由用户自行记录。',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
