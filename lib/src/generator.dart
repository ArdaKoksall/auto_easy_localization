import 'dart:io';

import 'package:auto_easy_localization/src/progress_bar.dart';
import 'package:auto_easy_localization/src/translate_service.dart';

import 'config.dart';
import 'excluded_keys_handler.dart';
import 'locale_file_handler.dart';

class AutoLocalizationGenerator {
  final TranslationConfig _config;
  late final GoogleTranslateService _translateService;
  late final LocaleFileHandler _fileHandler;
  late final ExcludedKeysHandler _excludedKeysHandler;

  AutoLocalizationGenerator(this._config) {
    _translateService = GoogleTranslateService(
      delayBetweenRequests: _config.delayBetweenRequests,
      maxRetries: _config.maxRetries,
    );
    _fileHandler = LocaleFileHandler(_config.translationsPath);
    _excludedKeysHandler = ExcludedKeysHandler(_config.excludedKeysPath);
  }


  Future<void> smartGenerate() async {
    try {
      await _validateSetup();
      
      // Load excluded keys
      await _excludedKeysHandler.loadExcludedKeys();

      final sourceTranslations = await _fileHandler.readLocaleFile(_config.sourceLocale);
      final existingLocales = await _fileHandler.getExistingLocales();

      final missingLocales = _config.targetLocales
          .where((locale) => !existingLocales.contains(locale))
          .toList();

      final existingTargetLocales = _config.targetLocales
          .where((locale) => existingLocales.contains(locale))
          .toList();

      final totalOperations = missingLocales.length + existingTargetLocales.length;
      if (totalOperations == 0) {
        print('✅ All translations are up to date!');
        return;
      }

      final progressBar = ProgressBar(totalOperations);
      int completed = 0;

      // Create missing locale files
      for (final locale in missingLocales) {
        progressBar.update(completed + 1, locale);
        await _generateSingleLocale(sourceTranslations, locale);
        completed++;
      }

      // Update existing locales with missing keys
      for (final locale in existingTargetLocales) {
        progressBar.update(completed + 1, locale);
        await _updateExistingLocale(sourceTranslations, locale);
        completed++;
      }

      progressBar.complete();
    } catch (e) {
      print('\n❌ Error: $e');
      rethrow;
    }
  }

  Future<List<String>> getMissingLocales() async {
    await _fileHandler.validateTranslationsDirectory();
    final existingLocales = await _fileHandler.getExistingLocales();
    return _config.targetLocales
        .where((locale) => !existingLocales.contains(locale))
        .toList();
  }

  Future<LocalizationStats> getStats() async {
    final existingLocales = await _fileHandler.getExistingLocales();
    final missingLocales = await getMissingLocales();

    int totalKeys = 0;
    if (existingLocales.contains(_config.sourceLocale)) {
      final sourceTranslations = await _fileHandler.readLocaleFile(_config.sourceLocale);
      totalKeys = sourceTranslations.length;
    }

    return LocalizationStats(
      sourceLocale: _config.sourceLocale,
      targetLocales: _config.targetLocales,
      existingLocales: existingLocales,
      missingLocales: missingLocales,
      totalTranslationKeys: totalKeys,
    );
  }

  Future<bool> validateService() async {
    return await _translateService.validateService();
  }

  Map<String, String> getSupportedLanguages() {
    return _translateService.getSupportedLanguages();
  }

  Future<void> _validateSetup() async {
    await _fileHandler.validateTranslationsDirectory();
    if (!await _fileHandler.localeFileExists(_config.sourceLocale)) {
      throw FileSystemException(
        'Source locale file not found: ${_config.sourceLocale}.json',
      );
    }

    if (!await _translateService.validateService()) {
      throw Exception('Google Translate service is not available');
    }
  }

  Future<void> _updateExistingLocale(
      Map<String, String> sourceTranslations,
      String targetLocale,
      ) async {
    final existingTranslations = await _fileHandler.readLocaleFile(targetLocale);

    final missingKeys = <String, String>{};
    for (final entry in sourceTranslations.entries) {
      if (!existingTranslations.containsKey(entry.key)) {
        missingKeys[entry.key] = entry.value;
      }
    }

    if (missingKeys.isEmpty) return;

    // Filter out excluded keys from translation but keep them in the final file
    final keysToTranslate = _excludedKeysHandler.filterExcludedKeys(missingKeys);
    final excludedKeysInMissing = <String, String>{};
    
    // Collect excluded keys that should not be translated
    for (final entry in missingKeys.entries) {
      if (_excludedKeysHandler.isKeyExcluded(entry.key)) {
        excludedKeysInMissing[entry.key] = entry.value; // Keep original value
      }
    }

    // Translate only non-excluded keys
    final translatedKeys = keysToTranslate.isNotEmpty 
        ? await _translateService.translateBatch(
            keysToTranslate,
            _config.sourceLocale,
            targetLocale,
          )
        : <String, String>{};

    // Combine translated keys with excluded keys (keeping original values)
    final updatedTranslations = {
      ...existingTranslations, 
      ...translatedKeys,
      ...excludedKeysInMissing,
    };

    await _fileHandler.writeLocaleFile(
      targetLocale,
      updatedTranslations,
      overwrite: true,
    );
  }

  Future<void> _generateSingleLocale(
      Map<String, String> sourceTranslations,
      String targetLocale,
      ) async {
    if (await _fileHandler.localeFileExists(targetLocale) && !_config.overwriteExisting) {
      return;
    }

    // Filter out excluded keys from translation but keep them in the final file
    final keysToTranslate = _excludedKeysHandler.filterExcludedKeys(sourceTranslations);
    final excludedKeys = <String, String>{};
    
    // Collect excluded keys that should not be translated
    for (final entry in sourceTranslations.entries) {
      if (_excludedKeysHandler.isKeyExcluded(entry.key)) {
        excludedKeys[entry.key] = entry.value; // Keep original value
      }
    }

    // Translate only non-excluded keys
    final translatedKeys = keysToTranslate.isNotEmpty 
        ? await _translateService.translateBatch(
            keysToTranslate,
            _config.sourceLocale,
            targetLocale,
          )
        : <String, String>{};

    // Combine translated keys with excluded keys (keeping original values)
    final finalTranslations = {
      ...translatedKeys,
      ...excludedKeys,
    };

    await _fileHandler.writeLocaleFile(
      targetLocale,
      finalTranslations,
      overwrite: _config.overwriteExisting,
    );
  }
}

class LocalizationStats {
  final String sourceLocale;
  final List<String> targetLocales;
  final List<String> existingLocales;
  final List<String> missingLocales;
  final int totalTranslationKeys;

  const LocalizationStats({
    required this.sourceLocale,
    required this.targetLocales,
    required this.existingLocales,
    required this.missingLocales,
    required this.totalTranslationKeys,
  });

  @override
  String toString() {
    return '''
📊 Localization Statistics:
   Source Locale: $sourceLocale
   Target Locales: ${targetLocales.join(', ')}
   Existing Locales: ${existingLocales.join(', ')}
   Missing Locales: ${missingLocales.join(', ')}
   Total Translation Keys: $totalTranslationKeys
   Completion: ${((existingLocales.length / (targetLocales.length + 1)) * 100).toStringAsFixed(1)}%
''';
  }
}