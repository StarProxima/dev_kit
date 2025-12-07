import 'package:app_update/app_update.dart';
import 'package:flutter/material.dart';

/// Экран с детальной информацией об обновлении
class UpdateInfoScreen extends StatelessWidget {
  const UpdateInfoScreen({
    super.key,
    required this.result,
  });

  final UpdateResult result;

  @override
  Widget build(BuildContext context) {
    final update = result.update;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Информация об обновлении'),
      ),
      body: update == null
          ? _buildNoUpdateInfo(context)
          : _buildUpdateInfo(context, update),
    );
  }

  Widget _buildNoUpdateInfo(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Обновлений не найдено',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            _getStatusDescription(),
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateInfo(BuildContext context, Update update) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSection(
          context,
          'Основная информация',
          [
            _buildInfoRow(context, 'Версия', update.version.toString()),
            _buildInfoRow(context, 'Источник', update.sourceName.name),
            _buildInfoRow(context, 'Платформа', update.platform.name),
            if (update.date != null)
              _buildInfoRow(
                context,
                'Дата релиза',
                _formatDate(update.date!),
              ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSection(
          context,
          'Контент',
          [
            _buildInfoRow(context, 'Заголовок', update.content.title),
            _buildInfoRow(context, 'Описание', update.content.description),
            _buildInfoRow(context, 'URL обновления', update.content.updateUrl),
            if (update.content.releaseNotes != null)
              _buildInfoRow(
                context,
                'Release Notes',
                update.content.releaseNotes!,
              ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSection(
          context,
          'Настройки',
          [
            _buildInfoRow(
              context,
              'Показывать',
              update.settings.shouldShow ? 'Да' : 'Нет',
            ),
            _buildInfoRow(
              context,
              'Можно пропустить',
              update.settings.canSkip ? 'Да' : 'Нет',
            ),
            _buildInfoRow(
              context,
              'Можно отложить',
              update.settings.canPostpone ? 'Да' : 'Нет',
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSection(
          context,
          'Статус приложения',
          [
            _buildInfoRow(
              context,
              'Статус',
              update.appSettings.appStatus.name,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  String _getStatusDescription() {
    return switch (result.updateStatus.type) {
      UpdateStatusType.notFound => 'У вас установлена последняя версия',
      UpdateStatusType.notFoundForTargetSource =>
        'Обновление не найдено для вашего источника установки',
      UpdateStatusType.initial => 'Проверка обновлений не выполнялась',
      UpdateStatusType.failedToFetch => 'Ошибка при загрузке данных',
      _ => 'Неизвестный статус',
    };
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute}';
  }
}
