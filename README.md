# Auto Easy Localization

🌐 A powerful Dart/Flutter tool for automated translation and localization management using Google Translate's free API.

## Features

- ✨ **Smart Translation Mode**: Only translates missing keys, preserving existing translations
- 🚀 **Batch Processing**: Efficient batch translation with configurable delays
- 📊 **Progress Tracking**: Real-time progress bar with ETA and statistics
- 🔄 **Auto-retry**: Configurable retry mechanism for failed translations
- 📁 **JSON Support**: Works with nested JSON translation files
- ⚙️ **Flexible Configuration**: Command-line arguments or pubspec.yaml configuration
- 🌍 **70+ Languages**: Support for all Google Translate supported languages
- 🛡️ **Error Handling**: Robust error handling with fallback to original text

## Installation

### As a Development Dependency

Add to your `pubspec.yaml`:

```yaml
dev_dependencies:
  auto_easy_localization: ^0.0.1
```

## Quick Start

1. **Create your source translation file** (`assets/translations/en.json`):
```json
{
  "navigation": {
    "home": "Home",
    "profile": "Profile",
    "settings": "Settings"
  },
  "forms": {
    "validation": {
      "required": "This field is required",
      "email": "Please enter a valid email"
    }
  }
}
```

2. **Run the tool**:
```bash
dart run auto_easy_localization
```

3. **Generated files** will be created automatically:
    - `assets/translations/es.json` (Spanish)
    - `assets/translations/fr.json` (French)
    - `assets/translations/de.json` (German)
    - `assets/translations/tr.json` (Turkish)

## Usage

### Command Line Options

```bash
# Smart mode with default settings
dart run auto_easy_localization

# Specify target locales
dart run auto_easy_localization --locales tr,es,fr,de,it

# Custom source locale and path
dart run auto_easy_localization --source en --path assets/i18n

# Custom pubspec.yaml location
dart run auto_easy_localization --config my_pubspec.yaml

# Show help
dart run auto_easy_localization --help
```

### Configuration via pubspec.yaml

Add configuration to your `pubspec.yaml`:

```yaml
auto_easy_localization:
  source_locale: en
  target_locales: [tr, es, fr, de, it, pt, ru, ja, ko, zh, ar]
  translations_path: assets/translations
  delay_between_requests: 100  # milliseconds
  max_retries: 3
```

## Preset Configurations

The tool includes predefined locale sets:

### European Languages
```dart
TranslationConfig.european(
  translationsPath: 'assets/translations',
)
// Includes: es, fr, de, it, pt, nl, sv, da, no
```

### Global Languages
```dart
TranslationConfig.global(
  translationsPath: 'assets/translations',
)
// Includes: es, fr, de, it, pt, ru, ja, ko, zh, ar, hi
```

### Asian Languages
```dart
TranslationConfig.asian(
  translationsPath: 'assets/translations',
)
// Includes: zh, ja, ko, th, vi, id, ms, hi, bn
```

## Advanced Features

### Smart Translation Mode

The tool automatically detects:
- Missing locale files and creates them
- Missing translation keys in existing files and adds them
- Preserves existing translations to avoid overwriting manual edits

### Progress Tracking

Real-time progress display shows:
- Current locale being processed
- Completion percentage
- Elapsed time and ETA
- Number of keys processed
- Animated spinner for visual feedback

### Error Handling

- Automatic retry with exponential backoff
- Fallback to original text if translation fails
- Detailed error messages and validation
- Service availability checking

## Supported Languages

The tool supports 70+ languages including:

| Code | Language | Code | Language | Code | Language |
|------|----------|------|----------|------|----------|
| en | English | es | Spanish | fr | French |
| de | German | it | Italian | pt | Portuguese |
| ru | Russian | ja | Japanese | ko | Korean |
| zh | Chinese | ar | Arabic | hi | Hindi |
| tr | Turkish | nl | Dutch | sv | Swedish |

[View full language list](https://cloud.google.com/translate/docs/languages)

## File Structure

```
assets/
└── translations/
    ├── en.json          # Source locale
    ├── es.json          # Auto-generated
    ├── fr.json          # Auto-generated
    ├── de.json          # Auto-generated
    └── tr.json          # Auto-generated
```

## JSON Structure Support

The tool handles nested JSON structures:

```json
{
  "app": {
    "title": "My App",
    "navigation": {
      "home": "Home",
      "settings": "Settings"
    }
  },
  "errors": {
    "network": "Network error occurred",
    "validation": {
      "required": "This field is required",
      "email": "Invalid email format"
    }
  }
}
```

## Performance & Rate Limiting

- **Default delay**: 100ms between requests
- **Configurable retries**: 3 attempts by default
- **Batch processing**: Processes all keys for each locale
- **Intelligent waiting**: Respects Google's rate limits

## Examples

### Basic Usage
```bash
# Translate to common European languages
dart run auto_easy_localization --locales es,fr,de,it
```

### Advanced Configuration
```yaml
# pubspec.yaml
auto_easy_localization:
  source_locale: en
  target_locales: [es, fr, de, it, pt, ru, ja, zh]
  translations_path: lib/l10n
  delay_between_requests: 1500
  max_retries: 5
```

### Custom Source Locale
```bash
# Use Spanish as source, translate to other languages
dart run auto_easy_localization --source es --locales en,fr,de,pt
```

## Troubleshooting

### Common Issues

1. **"Source locale file not found"**
    - Ensure your source locale file exists (e.g., `assets/translations/en.json`)
    - Check the translations path is correct

2. **"Google Translate service not available"**
    - Check internet connection
    - Verify you're not being rate limited
    - Try increasing delay between requests

3. **"Translation failed"**
    - Tool automatically falls back to original text
    - Check logs for specific error details
    - Verify target language codes are valid

### Rate Limiting

If you encounter rate limiting:
```yaml
auto_easy_localization:
  delay_between_requests: 2000  # Increase delay
  max_retries: 5                # More retry attempts
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Uses Google Translate's free API
- Built for Flutter/Dart localization workflows
- Inspired by the need for automated translation tools

---

Made with ❤️ for the Flutter community
