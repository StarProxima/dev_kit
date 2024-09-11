// ignore_for_file: avoid_print, prefer-correct-identifier-length, prefer-static-class, prefer-named-parameters

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:update_check/src/parser/update_config_parser.dart';

// Генерация случайных релизов, некоторые будут корректными, некоторые нет
List<Map<String, dynamic>> generateReleases(
  int count, {
  int incorrectRatio = 5,
}) {
  final releases = <Map<String, dynamic>>[];
  final random = Random();

  for (int i = 0; i < count; i++) {
    if (i % incorrectRatio == 0) {
      releases.add({
        'version': 'incorrect_version',
        'build_number': 'invalid-build-number',
        'status': 'active',
      });
    } else {
      releases.add({
        // ignore: prefer-moving-to-variable
        'version': '${random.nextInt(10)}.${random.nextInt(10)}.${random.nextInt(10)}',
        'build_number': random.nextInt(100),
        'status': 'active',
      });
    }
  }

  return releases;
}

// Функция для сохранения данных бенчмарка в JSON
Future<void> saveBenchmarkResults(
  Map<String, dynamic> results,
  String filename,
) async {
  final file = File(filename);
  final isExists = file.existsSync();

  List<Map<String, dynamic>> pastResults = [];
  if (isExists) {
    final jsonContent = await file.readAsString();
    pastResults = List<Map<String, dynamic>>.from(json.decode(jsonContent));
  }

  pastResults.add(results);
  await file.writeAsString(json.encode(pastResults));
}

// Бенчмарк-класс с прогревом и итерациями
class ParsingBenchmark extends BenchmarkBase {
  final int releaseCount;
  final List<Map<String, dynamic>> releases;
  final int iterations;

  int? timeTakenMicros;

  ParsingBenchmark(
    super.name,
    this.releaseCount,
    this.releases,
    this.iterations,
  );

  @override
  void run() {
    const parser = UpdateConfigParser();

    final configMap = {
      'release_settings': {
        'title': {
          'en': 'New version available',
        },
        'description': 'Update to the latest version!',
      },
      'stores': [
        {
          'name': 'googlePlay',
          'url': 'https://play.google.com',
        },
      ],
      'releases': releases,
      'customField': 'customValue',
    };

    try {
      parser.parseConfig(configMap, isDebug: false);
    } catch (e) {
      // Ошибка при парсинге некорректных данных
      print('Error during parsing: $e');
    }
  }

  @override
  void warmup() {
    print('Warming up with $releaseCount releases...');
    // Выполним прогрев 5 раз, результат не сохраняем
    for (int i = 0; i < 5; i++) {
      run();
    }
    print('Warmup complete.');
  }

  void measureIterations() {
    print('Starting $iterations iterations for $releaseCount releases...');
    final times = <double>[];
    for (int i = 0; i < iterations; i++) {
      setup();
      // ignore: move-variable-outside-iteration
      final timeTaken = measure(); // измеряем время выполнения
      times.add(timeTaken);
      teardown();
    }
    // ignore: avoid-unsafe-reduce
    final averageTime = times.reduce((a, b) => a + b) / times.length;
    timeTakenMicros = averageTime.toInt();
    print('Average time for $releaseCount releases: $averageTime µs');
  }
}

void main() async {
  const releaseCounts = [100, 500, 1000, 2000, 5000];
  const iterations = 10; // Количество итераций для каждого набора
  final now = DateTime.now();

  for (final releaseCount in releaseCounts) {
    final releases = generateReleases(releaseCount);

    final benchmark = ParsingBenchmark(
      'Parsing $releaseCount releases',
      releaseCount,
      releases,
      iterations,
    );

    benchmark.warmup(); // Выполняем прогрев
    benchmark.measureIterations(); // Выполняем несколько итераций

    final results = {
      'date': now.toIso8601String(),
      'releaseCount': releaseCount,
      'iterations': iterations,
      'averageTimeTakenMicros': benchmark.timeTakenMicros,
    };
    await saveBenchmarkResults(results, 'benchmark_results.json');
  }
}
