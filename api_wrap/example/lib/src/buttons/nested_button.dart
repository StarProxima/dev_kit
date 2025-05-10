import 'package:handler/handler.dart';
import 'package:example/src/handler.dart';
import 'package:example/src/app_button.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class NestedButton extends StatelessWidget {
  const NestedButton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppButton(
      onTap: () => handler.handleStrict<int, Map<String, dynamic>>(
        // Первый запрос - получаем ID пользователя
        () => Future.delayed(
          const Duration(milliseconds: 300),
          () => 42, // имитация получения ID пользователя
        ),
        onSuccess: (userId) async {
          // Показываем уведомление о промежуточном результате
          toastification.show(
            type: ToastificationType.info,
            autoCloseDuration: const Duration(seconds: 2),
            title: const Text('Step 1 completed'),
            description: Text('Got user ID: $userId'),
          );

          // Второй запрос - получаем детальную информацию о пользователе
          final userDetails = await handler
              .handleStrict<Map<String, dynamic>, Map<String, dynamic>>(
            () => Future.delayed(
              const Duration(milliseconds: 500),
              () => {'name': 'John Doe', 'role': 'Admin', 'id': userId},
            ),
            onSuccess: (details) => details,
          );

          // Показываем уведомление о втором результате
          toastification.show(
            type: ToastificationType.info,
            autoCloseDuration: const Duration(seconds: 2),
            title: const Text('Step 2 completed'),
            description: Text('Got user details for ${userDetails['name']}'),
          );

          // Третий запрос - получаем список задач пользователя
          final tasks = await handler.handleStrict<List<String>, List<String>>(
            () => Future.delayed(
              const Duration(milliseconds: 700),
              () => ['Review code', 'Update documentation', 'Fix bugs'],
            ),
            onSuccess: (tasks) => tasks,
          );

          // Возвращаем комбинированный результат всех запросов
          return {
            'user': userDetails,
            'tasks': tasks,
          };
        },
        onError: (error) {
          toastification.show(
            type: ToastificationType.error,
            autoCloseDuration: const Duration(seconds: 3),
            title: const Text('Error in nested requests'),
            description: Text(error.toString()),
          );
          throw error; // Передаем ошибку дальше
        },
      ).then((result) {
        // Показываем финальный результат
        final user = result['user'] as Map<String, dynamic>;
        final tasks = result['tasks'] as List;

        toastification.show(
          type: ToastificationType.success,
          autoCloseDuration: const Duration(seconds: 4),
          title: const Text('Nested requests completed'),
          description: Text(
            'User: ${user['name']}\n'
            'Total tasks: ${tasks.length}',
          ),
        );
      }),
      text: 'Nested requests',
    );
  }
}
