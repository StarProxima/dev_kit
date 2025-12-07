import 'package:flutter/material.dart';

/// Модель тестового сценария обновления
class UpdateScenario {
  const UpdateScenario({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.configFile,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String configFile;

  /// Предопределенные тестовые сценарии
  static const scenarios = [
    UpdateScenario(
      id: 'critical',
      title: 'Критическое обновление',
      description: 'Обновление без возможности пропустить или отложить',
      icon: Icons.warning_amber_rounded,
      color: Colors.red,
      configFile: 'test_critical_update.yaml',
    ),
    UpdateScenario(
      id: 'recommended',
      title: 'Рекомендуемое обновление',
      description: 'Обновление с возможностью отложить',
      icon: Icons.arrow_upward,
      color: Colors.orange,
      configFile: 'test_recommended_update.yaml',
    ),
    UpdateScenario(
      id: 'optional',
      title: 'Опциональное обновление',
      description: 'Обновление с возможностью пропустить или отложить',
      icon: Icons.info,
      color: Colors.green,
      configFile: 'test_optional_update.yaml',
    ),
  ];
}
