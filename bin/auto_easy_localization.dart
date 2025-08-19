import 'dart:io';

import 'package:auto_easy_localization/src/config.dart';
import 'package:auto_easy_localization/src/generator.dart';
import 'package:auto_easy_localization/src/pubspec_read.dart';

void main(List<String> arguments) async {
  try {
    final config = await _loadConfiguration();
    final generator = AutoLocalizationGenerator(config);

    print('🚀 Starting Smart Translation Mode...');
    await generator.smartGenerate();
  } catch (e) {
    print('\n❌ Error: $e');
    exit(1);
  }
}

Future<TranslationConfig> _loadConfiguration() async {
  try {
    // Load from pubspec.yaml
    final configReader = PubspecConfigReader();
    final pubspecConfig = await configReader.loadConfig('pubspec.yaml');

    if (pubspecConfig == null) {
      print(
        "⚠️ Warning: No auto_easy_localization configuration found in pubspec.yaml",
      );
      print("Using default configuration...");
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

    return TranslationConfig(
      translationsPath: pubspecConfig.translationsPath,
      excludedKeysPath:
          pubspecConfig.excludedKeysPath ?? 'assets/excluded_keys.json',
      sourceLocale: pubspecConfig.sourceLocale,
      targetLocales: pubspecConfig.targetLocales,
      overwriteExisting: false,
      delayBetweenRequests: pubspecConfig.delayBetweenRequests,
      maxRetries: pubspecConfig.maxRetries,
    );
  } catch (e) {
    print('❌ Error loading pubspec.yaml: $e');
    print("Using default configuration...");

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

class PubspecException implements Exception {
  final String message;
  PubspecException(this.message);

  @override
  String toString() => 'PubspecException: $message';
}
