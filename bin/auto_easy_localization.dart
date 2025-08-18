import 'dart:io';

import 'package:args/args.dart';
import 'package:auto_easy_localization/src/config.dart';
import 'package:auto_easy_localization/src/generator.dart';
import 'package:auto_easy_localization/src/pubspec_read.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag('help', abbr: 'h', defaultsTo: false, help: 'Show help')
    ..addOption(
      'config',
      abbr: 'c',
      help: 'Path to pubspec.yaml',
      defaultsTo: 'pubspec.yaml',
    )
    ..addMultiOption(
      'locales',
      abbr: 'l',
      help: 'Target locales (comma separated)',
    )
    ..addOption('source', help: 'Source locale', defaultsTo: 'en')
    ..addOption(
      'path',
      abbr: 'p',
      help: 'Translations path',
      defaultsTo: 'assets/translations',
    );

  ArgResults results;
  try {
    results = parser.parse(arguments);
  } catch (e) {
    print('❌ Error parsing arguments: $e');
    _printUsage(parser);
    exit(1);
  }

  if (results['help']) {
    _printUsage(parser);
    return;
  }

  try {
    final config = await _loadConfiguration(results);
    final generator = AutoLocalizationGenerator(config);

    print('🚀 Starting Smart Translation Mode...');
    await generator.smartGenerate();
  } catch (e) {
    print('\n❌ Error: $e');
    exit(1);
  }
}

Future<TranslationConfig> _loadConfiguration(ArgResults results) async {
  try {
    // Try to load from pubspec.yaml first
    final configReader = PubspecConfigReader();
    final pubspecConfig = await configReader.loadConfig(results['config']);

    // Override with command line arguments if provided
    final targetLocales = results['locales'].isNotEmpty
        ? results['locales'].cast<String>()
        : pubspecConfig?.targetLocales ?? ['tr', 'es', 'fr', 'de'];

    return TranslationConfig(
      translationsPath:
          results['path'] ??
          pubspecConfig?.translationsPath ??
          'assets/translations',
      sourceLocale: results['source'] ?? pubspecConfig?.sourceLocale ?? 'en',
      targetLocales: targetLocales,
      overwriteExisting: false,
      delayBetweenRequests: pubspecConfig?.delayBetweenRequests ?? 1000,
      maxRetries: pubspecConfig?.maxRetries ?? 3,
    );
  } catch (e) {
    // Fallback to defaults if pubspec reading fails
    return TranslationConfig(
      translationsPath: results['path'] ?? 'assets/translations',
      sourceLocale: results['source'] ?? 'en',
      targetLocales: results['locales'].cast<String>().isNotEmpty
          ? results['locales'].cast<String>()
          : ['tr', 'es', 'fr', 'de'],
      overwriteExisting: false,
      delayBetweenRequests: 1000,
      maxRetries: 3,
    );
  }
}

void _printUsage(ArgParser parser) {
  print('''
🌐 Auto Easy Localization Tool

Usage: dart run auto_easy_localization [options]

Options:
${parser.usage}

Examples:
  # Smart mode (default) - only translate missing keys
  dart run auto_easy_localization

  # Specify locales
  dart run auto_easy_localization --locales tr,es,fr

  # Custom config file
  dart run auto_easy_localization --config my_pubspec.yaml

Add to your pubspec.yaml:
auto_easy_localization:
  source_locale: en
  target_locales: [tr, es, fr, de, it]
  translations_path: assets/translations
  delay_between_requests: 1000
  max_retries: 3
''');
}
