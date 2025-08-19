import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

class LocaleFileHandler {
  final String translationsPath;

  LocaleFileHandler(this.translationsPath);

  Future<Map<String, String>> readLocaleFile(String locale) async {
    final file = File(path.join(translationsPath, '$locale.json'));

    if (!await file.exists()) {
      throw FileSystemException('Locale file not found: ${file.path}');
    }

    try {
      final content = await file.readAsString();
      final data = jsonDecode(content);
      return _flattenJson(data);
    } catch (e) {
      throw Exception('Failed to parse locale file $locale.json: $e');
    }
  }

  Future<void> writeLocaleFile(
    String locale,
    Map<String, String> translations, {
    bool overwrite = false,
  }) async {
    final file = File(path.join(translationsPath, '$locale.json'));

    if (await file.exists() && !overwrite) {
      return;
    }

    await file.parent.create(recursive: true);

    final nestedData = _unflattenJson(translations);
    final jsonString = JsonEncoder.withIndent('  ').convert(nestedData);
    await file.writeAsString(jsonString);
  }

  Future<bool> localeFileExists(String locale) async {
    final file = File(path.join(translationsPath, '$locale.json'));
    return await file.exists();
  }

  Future<List<String>> getExistingLocales() async {
    final directory = Directory(translationsPath);

    if (!await directory.exists()) {
      return [];
    }

    final files = await directory
        .list()
        .where((entity) => entity is File && entity.path.endsWith('.json'))
        .cast<File>()
        .toList();

    return files
        .map((file) => path.basenameWithoutExtension(file.path))
        .toList();
  }

  Future<void> validateTranslationsDirectory() async {
    final directory = Directory(translationsPath);

    if (!await directory.exists()) {
      throw DirectorySystemException(
        'Translations directory not found: $translationsPath',
      );
    }
  }

  Map<String, String> _flattenJson(dynamic json, [String prefix = '']) {
    final Map<String, String> result = {};

    if (json is Map<String, dynamic>) {
      json.forEach((key, value) {
        final newKey = prefix.isEmpty ? key : '$prefix.$key';
        if (value is Map<String, dynamic>) {
          result.addAll(_flattenJson(value, newKey));
        } else {
          result[newKey] = value.toString();
        }
      });
    } else {
      result[prefix] = json.toString();
    }

    return result;
  }

  Map<String, dynamic> _unflattenJson(Map<String, String> flatMap) {
    final Map<String, dynamic> result = {};

    for (final entry in flatMap.entries) {
      final keys = entry.key.split('.');
      dynamic current = result;

      for (int i = 0; i < keys.length - 1; i++) {
        current[keys[i]] ??= <String, dynamic>{};
        current = current[keys[i]];
      }

      current[keys.last] = entry.value;
    }

    return result;
  }
}

class DirectorySystemException implements Exception {
  final String message;

  DirectorySystemException(this.message);

  @override
  String toString() => 'DirectorySystemException: $message';
}
