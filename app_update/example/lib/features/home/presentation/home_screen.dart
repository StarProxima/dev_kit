import 'package:app_update/app_update.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../settings/presentation/settings_screen.dart';
import '../../shared/domain/app_state.dart';
import '../../shared/presentation/widgets/scenario_card.dart';
import '../../update_info/presentation/update_info_screen.dart';
import '../domain/update_scenario.dart';
import 'widgets/info_card.dart';

/// Главный экран sandbox с различными сценариями тестирования
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _notifier = AppState.instance.notifier;

  @override
  void initState() {
    super.initState();
    // Подписываемся на изменения состояния
    _notifier.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _notifier.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    // Перерисовываем при изменении состояния
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _checkForUpdates() async {
    try {
      await _notifier.checkForUpdates();

      final result = _notifier.value.lastResult;
      if (!mounted) return;

      if (result?.shouldShow ?? false) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Найдено обновление: ${result?.update?.version}'),
            action: SnackBarAction(
              label: 'Показать',
              onPressed: () => _showMaterialDialog(),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Обновлений не найдено')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }

  void _showMaterialDialog() {
    final result = _notifier.value.lastResult;
    if (result?.shouldShow ?? false) {
      UpdateAlertHandler.materialDialog(
        context,
        _notifier.value.controller,
        result!,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Сначала проверьте обновления')),
      );
    }
  }

  void _showUpdateInfo() {
    final result = _notifier.value.lastResult;
    if (result != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => UpdateInfoScreen(result: result),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Сначала проверьте обновления')),
      );
    }
  }

  Future<void> _clearUpdates() async {
    final storage =
        SharedPreferencesUpdateStorage(await SharedPreferences.getInstance());
    final storageManager = UpdateStorageManager(storage);
    await storageManager.clear();
  }

  Future<void> _testScenario(UpdateScenario scenario) async {
    try {
      final result = await _notifier.loadScenario(scenario.configFile);

      if (!mounted) return;

      if (result?.shouldShow ?? false) {
        // Создаем временный контроллер для диалога
        UpdateAlertHandler.materialDialog(
          context,
          _notifier.value.controller,
          result!,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Обновление не должно показываться для сценария "${scenario.title}"',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки сценария: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = _notifier.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('App Update Sandbox'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Информационная карточка
                InfoCard(lastResult: state.lastResult),
                const SizedBox(height: 24),

                // Основные действия
                Text(
                  'Основные действия',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ScenarioCard(
                  title: 'Проверить обновления',
                  description:
                      'Проверить наличие обновлений с текущими настройками',
                  icon: Icons.refresh,
                  color: Colors.blue,
                  onTap: _checkForUpdates,
                ),
                const SizedBox(height: 12),
                ScenarioCard(
                  title: 'Показать Material Dialog',
                  description: 'Показать стандартный Material Design диалог',
                  icon: Icons.notification_important,
                  color: Colors.purple,
                  onTap: _showMaterialDialog,
                  enabled: state.lastResult?.shouldShow ?? false,
                ),
                const SizedBox(height: 12),
                ScenarioCard(
                  title: 'Информация об обновлении',
                  description:
                      'Показать детальную информацию о последнем результате',
                  icon: Icons.info_outline,
                  color: Colors.teal,
                  onTap: _showUpdateInfo,
                  enabled: state.lastResult != null,
                ),
                const SizedBox(height: 12),
                ScenarioCard(
                  title: 'Очистить хранилище обновлений',
                  description: 'Отменить отложенные и пропущенные обновления',
                  icon: Icons.delete,
                  color: Colors.red,
                  onTap: _clearUpdates,
                  enabled: true,
                ),
                const SizedBox(height: 24),

                // Тестовые сценарии
                Text(
                  'Тестовые сценарии',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ...UpdateScenario.scenarios.map((scenario) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ScenarioCard(
                      title: scenario.title,
                      description: scenario.description,
                      icon: scenario.icon,
                      color: scenario.color,
                      onTap: () => _testScenario(scenario),
                    ),
                  );
                }),
              ],
            ),
    );
  }
}
