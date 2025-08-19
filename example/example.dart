// Example usage for auto_easy_localization
// Run with: dart run example/example.dart

import 'dart:io';

import 'package:auto_easy_localization/auto_easy_localization.dart';
import 'package:path/path.dart' as p;

Future<void> main() async {
  // 1) Example directory structure.
  final translationsDir = Directory(p.join('example', 'assets', 'translations'));

  // 2) Configure generator (use a small set of targets for demo)
  final config = TranslationConfig(
    translationsPath: translationsDir.path,
    sourceLocale: 'en',
    targetLocales: const ['fr', 'es', 'de', 'it', 'tr'],
    // Keep overwriteExisting=false so we only fill missing keys in existing files
    overwriteExisting: false,
    // Adjust these for your needs
    delayBetweenRequests: 100,
    maxRetries: 3,
  );

  final validationErrors = config.validate();
  if (validationErrors.isNotEmpty) {
    stderr.writeln('Invalid configuration:');
    for (final err in validationErrors) {
      stderr.writeln(' - $err');
    }
    exit(2);
  }

  // 3) Run generator
  final generator = AutoLocalizationGenerator(config);

  stdout.writeln('Starting smart generation in: ${config.translationsPath}');
  try {
    await generator.smartGenerate();

    // 4) Print some quick stats
    final stats = await generator.getStats();
    stdout
      ..writeln(stats.toString())
      ..writeln('Example complete. Check generated *.json files under ${config.translationsPath}');
  } catch (e) {
    stderr.writeln('Generation failed: $e');
    exit(1);
  }
}

