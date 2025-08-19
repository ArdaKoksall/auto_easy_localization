import 'dart:convert';
import 'dart:io';

class ExcludedKeysHandler {
  final String excludedKeysPath;
  List<String> _excludedKeys = [];

  ExcludedKeysHandler(this.excludedKeysPath);

  /// Loads excluded keys from assets/excluded_keys.json if it exists
  Future<void> loadExcludedKeys() async {
    final file = File(excludedKeysPath);
    
    if (!await file.exists()) {
      _excludedKeys = [];
      return;
    }

    try {
      final content = await file.readAsString();
      final data = jsonDecode(content);
      
      if (data is List) {
        _excludedKeys = data.cast<String>();
      } else if (data is Map<String, dynamic> && data.containsKey('excluded_keys')) {
        _excludedKeys = (data['excluded_keys'] as List).cast<String>();
      } else {
        throw FormatException('Invalid excluded_keys.json format. Expected array of strings or object with "excluded_keys" property.');
      }
      
      print('📌 Loaded ${_excludedKeys.length} excluded keys from ${file.path}');
    } catch (e) {
      print('⚠️  Warning: Failed to load excluded keys from ${file.path}: $e');
      _excludedKeys = [];
    }
  }

  /// Checks if a key should be excluded from translation
  bool isKeyExcluded(String key) {
    return _excludedKeys.contains(key);
  }

  /// Filters out excluded keys from a translation map
  Map<String, String> filterExcludedKeys(Map<String, String> translations) {
    final filtered = <String, String>{};
    
    for (final entry in translations.entries) {
      if (!isKeyExcluded(entry.key)) {
        filtered[entry.key] = entry.value;
      }
    }
    
    return filtered;
  }

  /// Gets all excluded keys
  List<String> get excludedKeys => List.unmodifiable(_excludedKeys);

  /// Checks if there are any excluded keys loaded
  bool get hasExcludedKeys => _excludedKeys.isNotEmpty;
}
