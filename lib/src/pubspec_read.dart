import 'dart:io';

import 'package:yaml/yaml.dart';

class PubspecConfigReader {
  Future<PubspecTranslationConfig?> loadConfig(String pubspecPath) async {
    try {
      final file = File(pubspecPath);
      if (!await file.exists()) return null;

      final content = await file.readAsString();
      final yamlDoc = loadYaml(content);
      final config = yamlDoc['auto_easy_localization'];

      if (config == null) return null;

      return PubspecTranslationConfig(
        sourceLocale: config['source_locale']?.toString() ?? 'en',
        targetLocales:
            (config['target_locales'] as List?)?.cast<String>() ?? [],
        translationsPath:
            config['translations_path']?.toString() ?? 'assets/translations',
        delayBetweenRequests: config['delay_between_requests'] ?? 100,
        maxRetries: config['max_retries'] ?? 3,
      );
    } catch (e) {
      return null;
    }
  }
}

class PubspecTranslationConfig {
  final String sourceLocale;
  final String? excludedKeysPath;
  final List<String> targetLocales;
  final String translationsPath;
  final int delayBetweenRequests;
  final int maxRetries;

  const PubspecTranslationConfig({
    required this.sourceLocale,
    this.excludedKeysPath,
    required this.targetLocales,
    required this.translationsPath,
    required this.delayBetweenRequests,
    required this.maxRetries,
  });
}
