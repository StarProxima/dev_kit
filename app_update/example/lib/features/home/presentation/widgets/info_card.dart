import 'package:app_update/app_update.dart';
import 'package:flutter/material.dart';

import '../../../shared/domain/app_state.dart';

/// Информационная карточка с текущими настройками
class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    this.lastResult,
  });

  final UpdateResult? lastResult;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: AppState.instance.notifier,
      builder: (context, state, child) {
        return Card(
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
                      'Текущие настройки',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  context,
                  'Локаль',
                  state.locale.toString(),
                ),
                _buildInfoRow(
                  context,
                  'Конфиг',
                  state.configType.displayName,
                ),
                _buildInfoRow(
                  context,
                  'Версия приложения',
                  state.mockAppVersion,
                ),
                _buildInfoRow(
                  context,
                  'Автопоказ диалога',
                  state.autoShowDialog ? 'Включен' : 'Выключен',
                ),
                if (lastResult != null) ...[
                  const Divider(height: 24),
                  _buildInfoRow(
                    context,
                    'Статус',
                    _getStatusText(lastResult!),
                  ),
                  if (lastResult!.update != null)
                    _buildInfoRow(
                      context,
                      'Доступная версия',
                      lastResult!.update!.version.toString(),
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
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
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(UpdateResult result) {
    return switch (result.updateStatus.type) {
      UpdateStatusType.initial => 'Не проверялось',
      UpdateStatusType.found => 'Обновление найдено',
      UpdateStatusType.failedToFetch => 'Ошибка загрузки',
      UpdateStatusType.notFound => 'Обновление не найдено',
      UpdateStatusType.notFoundForTargetSource => 'Не найдено для источника',
      UpdateStatusType.skipped => 'Пропущено',
      UpdateStatusType.postponed => 'Отложено',
      UpdateStatusType.delayed => 'Отложено (delay)',
      UpdateStatusType.notYetRollout => 'Еще не раскатано',
    };
  }
}
