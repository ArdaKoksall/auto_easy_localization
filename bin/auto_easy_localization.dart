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

    if (pubspecConfig == null) {
      throw PubspecException('Failed to load pubspec.yaml config');
    }
    //todo check fields


    return TranslationConfig(
      translationsPath:
          results['translations_path'] ??
          pubspecConfig.translationsPath ??
          'assets/translations',
      excludedKeysPath: results['excludedKeysPath'] ??
          pubspecConfig.excludedKeysPath ?? 'assets/excluded_keys.json',
      sourceLocale: results['source_locale'] ?? pubspecConfig.sourceLocale ?? 'en',
      targetLocales: results['target_locales'].cast<String>().isNotEmpty
          ? results['target_locales'].cast<String>()
          : pubspecConfig.targetLocales,
      overwriteExisting: false,
      delayBetweenRequests: pubspecConfig.delayBetweenRequests,
      maxRetries: pubspecConfig.maxRetries,
    );
  } catch (e) {
    if( e is! PubspecException) {
      print('❌ Error loading pubspec.yaml: $e');
    } else {
      print("⚠️ Warning: Running with default configuration");
    }

    return TranslationConfig(
      translationsPath: 'assets/translations',
      sourceLocale: 'en',
      excludedKeysPath: 'assets/excluded_keys.json',
      targetLocales: ['tr', 'es', 'fr', 'de'],
      overwriteExisting: false,
      delayBetweenRequests: 100,
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
  # Smart mode (default) - only translate missing keys - with default locales
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
  delay_between_requests: 100
  max_retries: 3
''');
}

class PubspecException implements Exception {
  final String message;
  PubspecException(this.message);

  @override
  String toString() => 'PubspecException: $message';
}
