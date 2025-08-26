part of '../rule_resolver_test_group.dart';

void runTemporalMatchingTests() {
  group('UpdateRuleResolver - Temporal matching', () {
    const resolver = UpdateRuleResolver();

    group('date only (без delay/rollout)', () {
      test('Активно начиная с baseDate (включительно)', () {
        final baseDate = DateTime(2024, 1, 1, 12);
        final rules = [
          createTestRule(date: UpdateDate(baseDate), title: 'ok'),
        ];

        // До даты — не подходит
        expect(
          () => resolver.resolve(
            searchData: createTestSearchData(
                currentDate: baseDate.subtract(const Duration(hours: 1))),
            rules: rules,
          ),
          throwsA(isA<Exception>()),
        );

        // Ровно в дату — подходит
        final res = resolver.resolve(
          searchData: createTestSearchData(currentDate: baseDate),
          rules: rules,
        );
        expect(res.title, 'ok');
      });

      test(
          'Dynamic date: отсутствует localReleaseDate => правило не применяется',
          () {
        final rules = [
          createTestRule(date: UpdateDate.localReleaseDate, title: 'bad'),
        ];

        expect(
          () => resolver.resolve(
              searchData: createTestSearchData(), rules: rules),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
