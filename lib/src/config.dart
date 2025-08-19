class TranslationConfig {
  final String translationsPath;
  final String excludedKeysPath;
  final String sourceLocale;
  final List<String> targetLocales;
  final bool overwriteExisting;
  final int delayBetweenRequests;
  final int maxRetries;

  const TranslationConfig({
    required this.translationsPath,
    this.excludedKeysPath = 'assets/excluded_keys.json',
    required this.sourceLocale,
    required this.targetLocales,
    this.overwriteExisting = false,
    this.delayBetweenRequests = 100,
    this.maxRetries = 3,
  });

  List<String> validate() {
    final errors = <String>[];

    if (translationsPath.isEmpty) {
      errors.add('Translation path cannot be empty');
    }

    if (sourceLocale.isEmpty) {
      errors.add('Source locale cannot be empty');
    }

    if (targetLocales.isEmpty) {
      errors.add('Target locales cannot be empty');
    }

    if (targetLocales.contains(sourceLocale)) {
      errors.add('Target locales cannot contain the source locale');
    }

    if (delayBetweenRequests < 100) {
      errors.add(
        'Delay between requests should be at least 100ms to avoid rate limiting',
      );
    }

    if (maxRetries < 1 || maxRetries > 10) {
      errors.add('Max retries should be between 1 and 10');
    }

    return errors;
  }

  bool get isValid => validate().isEmpty;

  @override
  String toString() {
    return '''TranslationConfig(
  sourceLocale: $sourceLocale,
  targetLocales: ${targetLocales.join(', ')},
  translationsPath: $translationsPath,
  overwriteExisting: $overwriteExisting,
  delayBetweenRequests: ${delayBetweenRequests}ms,
  maxRetries: $maxRetries
)''';
  }

  TranslationConfig copyWith({
    String? translationsPath,
    String? sourceLocale,
    List<String>? targetLocales,
    bool? overwriteExisting,
    int? delayBetweenRequests,
    String? excludedKeysPath,
    int? maxRetries,
  }) {
    return TranslationConfig(
      translationsPath: translationsPath ?? this.translationsPath,
      excludedKeysPath: excludedKeysPath ?? this.excludedKeysPath,
      sourceLocale: sourceLocale ?? this.sourceLocale,
      targetLocales: targetLocales ?? this.targetLocales,
      overwriteExisting: overwriteExisting ?? this.overwriteExisting,
      delayBetweenRequests: delayBetweenRequests ?? this.delayBetweenRequests,
      maxRetries: maxRetries ?? this.maxRetries,
    );
  }
}
