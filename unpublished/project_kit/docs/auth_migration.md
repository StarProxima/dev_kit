# Auth Migration

`project_kit` больше не содержит `auth_token/**` и не инвалидирует кэш автоматически через `listenUserChanges()`.

Теперь auth-логика должна жить на стороне приложения или во внешнем auth-пакете.

## Что поменялось

- удалены `AuthToken` и `SecureTokenStorage`
- удален implicit hook из `RefCacheX.cacheFor()`, который следил за сменой пользователя
- `cacheFor()` теперь в riverpod_utils

## Что делать в приложении

Нужно явно инвалидировать завязанные на пользователя провайдеры, когда меняется auth/session state.

Обычно это один из двух сценариев:

1. logout/login
2. смена пользователя без перезапуска приложения

## Рекомендуемый подход

Заведите один app-level provider с текущей сессией и слушайте его изменения в корневом слое приложения.

```dart
final authSessionProvider = Provider<AuthSession?>((ref) {
  return ref.watch(authRepositoryProvider).session;
});

final cachedProfileProvider = FutureProvider.autoDispose<Profile>((ref) async {
  ref.cacheFor(const Duration(minutes: 5), tag: 'user-scoped');
  final session = ref.watch(authSessionProvider);
  return ref.watch(apiProvider).loadProfile(session!.userId);
});

class AuthInvalidationGate extends ConsumerWidget {
  const AuthInvalidationGate({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AuthSession?>(authSessionProvider, (previous, next) {
      final previousUserId = previous?.userId;
      final nextUserId = next?.userId;

      if (previousUserId == nextUserId) return;

      ref.invalidate(cachedProfileProvider);
      ref.invalidate(userFeedProvider);
      ref.invalidate(userSettingsProvider);
    });

    return child;
  }
}
```

## Если провайдеров много

Есть 2 рабочих стратегии:

1. держать явный список user-scoped провайдеров и инвалидировать его при смене сессии
2. вынести user-scoped кэш/инвалидацию во внешний auth/data пакет

Первый вариант проще и прозрачнее.
Второй полезен, если auth-слой общий для нескольких приложений.

## Важный нюанс

Старое поведение `listenUserChanges()` было неявным, из-за чего `cacheFor()` делал сразу две разные вещи:

- включал keep-alive
- подписывался на auth-события

Теперь эти ответственности разделены:

- `cacheFor()` отвечает только за кэш
- приложение само решает, какие провайдеры инвалидировать при смене auth state
