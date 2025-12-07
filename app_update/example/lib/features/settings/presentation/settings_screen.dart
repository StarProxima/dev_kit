import 'package:app_update/app_update.dart';
import 'package:flutter/material.dart';

import '../../shared/domain/app_state.dart';
import '../../shared/domain/update_config_type.dart';
import '../domain/settings_notifier.dart';

/// Экран настроек sandbox
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final SettingsNotifier _settingsNotifier;

  @override
  void initState() {
    super.initState();
    _settingsNotifier = SettingsNotifier();
    _settingsNotifier.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _settingsNotifier
      ..removeListener(_onStateChanged)
      ..dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _saveSettings() async {
    await _settingsNotifier.saveSettings();

    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Настройки сохранены')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = _settingsNotifier.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: const Text('Сохранить'),
          ),
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Локаль приложения'),
            subtitle: Text(_getLocaleName(state.locale)),
            leading: const Icon(Icons.language),
            onTap: _showLocaleDialog,
          ),
          const Divider(),
          ListTile(
            title: const Text('Конфигурация'),
            subtitle: Text(state.configType.displayName),
            leading: const Icon(Icons.settings_applications),
            onTap: _showConfigDialog,
          ),
          const Divider(),
          ListTile(
            title: const Text('Версия приложения (мок)'),
            subtitle: Text(state.mockVersion),
            leading: const Icon(Icons.apps),
            onTap: _showVersionDialog,
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Автоматически показывать диалог'),
            subtitle:
                const Text('Показывать диалог при обнаружении обновления'),
            value: state.autoShowDialog,
            secondary: const Icon(Icons.notifications_active),
            onChanged: (_) => _settingsNotifier.toggleAutoShowDialog(),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Информация',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Эти настройки используются только в sandbox '
                      'для тестирования различных сценариев.\n\n'
                      'Измените локаль чтобы увидеть локализованный контент.\n\n'
                      'Измените версию приложения чтобы имитировать разные '
                      'состояния (устаревшая, deprecated и т.д.).',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showLocaleDialog() async {
    final locale = await showDialog<UpdateLocale>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выберите локаль'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppState.availableLocales.map((locale) {
            return RadioListTile<UpdateLocale>(
              title: Text(_getLocaleName(locale)),
              value: locale,
              groupValue: _settingsNotifier.value.locale,
              onChanged: (value) => Navigator.of(context).pop(value),
            );
          }).toList(),
        ),
      ),
    );

    if (locale != null) {
      _settingsNotifier.changeLocale(locale);
    }
  }

  Future<void> _showConfigDialog() async {
    final config = await showDialog<UpdateConfigType>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выберите конфигурацию'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: UpdateConfigType.values.map((config) {
            return RadioListTile<UpdateConfigType>(
              title: Text(config.displayName),
              value: config,
              groupValue: _settingsNotifier.value.configType,
              onChanged: (value) => Navigator.of(context).pop(value),
            );
          }).toList(),
        ),
      ),
    );

    if (config != null) {
      _settingsNotifier.changeConfigType(config);
    }
  }

  Future<void> _showVersionDialog() async {
    final controller = TextEditingController(
      text: _settingsNotifier.value.mockVersion,
    );

    final version = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Версия приложения'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Версия (semver)',
            hintText: '1.0.0',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (version != null && version.isNotEmpty) {
      _settingsNotifier.changeMockVersion(version);
    }
  }

  String _getLocaleName(UpdateLocale locale) {
    return switch (locale) {
      UpdateLocale.en => 'English (en)',
      UpdateLocale.ru => 'Русский (ru)',
      UpdateLocale.any => 'Any (любой)',
      _ => locale.toString(),
    };
  }
}
