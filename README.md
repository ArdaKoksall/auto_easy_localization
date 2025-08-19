# Auto Easy Localization

🌐 A powerful Dart/Flutter tool for automated translation and localization management using Google Translate's free API.

## Features

- ✨ **Smart Translation Mode**: Only translates missing keys, preserving existing translations
- 🚀 **Batch Processing**: Efficient batch translation with configurable delays
- 📊 **Progress Tracking**: Real-time progress bar with ETA and statistics
- 🔄 **Auto-retry**: Configurable retry mechanism for failed translations
- 📁 **JSON Support**: Works with nested JSON translation files
- ⚙️ **pubspec.yaml Configuration**: All configuration is managed through pubspec.yaml
- 🌍 **70+ Languages**: Support for all Google Translate supported languages
- 🛡️ **Error Handling**: Robust error handling with fallback to original text

## Installation

### As a Development Dependency

Add to your `pubspec.yaml`:

```yaml
dev_dependencies:
  auto_easy_localization: ^0.0.4
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

2. **Configure in pubspec.yaml**:

```yaml
auto_easy_localization:
  source_locale: en
  target_locales: [es, fr, de, tr]
  translations_path: assets/translations
  delay_between_requests: 100
  max_retries: 3
```

3. **Run the tool**:

```bash
dart run auto_easy_localization
```

4. **Generated files** will be created automatically:
   - `assets/translations/es.json` (Spanish)
   - `assets/translations/fr.json` (French)
   - `assets/translations/de.json` (German)
   - `assets/translations/tr.json` (Turkish)

## Configuration

All configuration is managed through your `pubspec.yaml` file. Add the `auto_easy_localization` section with your desired settings:

```yaml
auto_easy_localization:
  source_locale: en # Source language (required)
  target_locales: [tr, es, fr, de, it] # Target languages (required)
  translations_path: assets/translations # Path to translation files (optional, default: assets/translations)
  delay_between_requests: 100 # Delay between API calls in ms (optional, default: 100)
  max_retries: 3 # Maximum retry attempts (optional, default: 3)
```

### Configuration Options

| Option                   | Type         | Required | Default                     | Description                                              |
| ------------------------ | ------------ | -------- | --------------------------- | -------------------------------------------------------- |
| `source_locale`          | String       | ✅       | `en`                        | The source language code                                 |
| `target_locales`         | List<String> | ✅       | `[tr, es, fr, de]`          | List of target language codes                            |
| `translations_path`      | String       | ❌       | `assets/translations`       | Path to translation files directory                      |
| `delay_between_requests` | int          | ❌       | `100`                       | Delay between API requests (milliseconds)                |
| `max_retries`            | int          | ❌       | `3`                         | Maximum number of retry attempts for failed translations |
| `excluded_keys_path`     | String       | ❌       | `assets/excluded_keys.json` | Path to excluded keys file                               |

### Default Configuration

If no configuration is found in pubspec.yaml, the tool will use these defaults:

```yaml
auto_easy_localization:
  source_locale: en
  target_locales: [tr, es, fr, de]
  translations_path: assets/translations
  delay_between_requests: 100
  max_retries: 3
  excluded_keys_path: assets/excluded_keys.json
```

## Preset Configurations

The tool includes predefined locale sets for common use cases. You can use these presets directly in your configuration:

### European Languages

```yaml
auto_easy_localization:
  source_locale: en
  target_locales: [es, fr, de, it, pt, nl, sv, da, no, tr]
  translations_path: assets/translations
```

### Global Languages

```yaml
auto_easy_localization:
  source_locale: en
  target_locales: [es, fr, de, it, pt, ru, ja, ko, zh, ar, hi, tr]
  translations_path: assets/translations
```

### Asian Languages

```yaml
auto_easy_localization:
  source_locale: en
  target_locales: [zh, ja, ko, th, vi, id, ms, hi, bn]
  translations_path: assets/translations
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

| Code | Language | Code | Language | Code | Language   |
| ---- | -------- | ---- | -------- | ---- | ---------- |
| en   | English  | es   | Spanish  | fr   | French     |
| de   | German   | it   | Italian  | pt   | Portuguese |
| ru   | Russian  | ja   | Japanese | ko   | Korean     |
| zh   | Chinese  | ar   | Arabic   | hi   | Hindi      |
| tr   | Turkish  | nl   | Dutch    | sv   | Swedish    |

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
# Run with pubspec.yaml configuration
dart run auto_easy_localization
```

### Configuration Examples

#### Minimal Configuration

```yaml
# pubspec.yaml
auto_easy_localization:
  source_locale: en
  target_locales: [es, fr, de, it]
```

#### Advanced Configuration

```yaml
# pubspec.yaml
auto_easy_localization:
  source_locale: en
  target_locales: [es, fr, de, it, pt, ru, ja, zh]
  translations_path: lib/l10n
  delay_between_requests: 1500
  max_retries: 5
```

#### Custom Source Locale

```yaml
# pubspec.yaml
auto_easy_localization:
  source_locale: es
  target_locales: [en, fr, de, pt]
  translations_path: assets/translations
```

## Troubleshooting

### Common Issues

1. **"Source locale file not found"**

   - Ensure your source locale file exists (e.g., `assets/translations/en.json`)
   - Check the `translations_path` in your pubspec.yaml configuration

2. **"No auto_easy_localization configuration found"**

   - Add the `auto_easy_localization` section to your pubspec.yaml
   - Ensure proper YAML indentation and syntax

3. **"Google Translate service not available"**

   - Check internet connection
   - Verify you're not being rate limited
   - Try increasing `delay_between_requests` in your configuration

4. **"Translation failed"**
   - Tool automatically falls back to original text
   - Check logs for specific error details
   - Verify target language codes are valid

### Rate Limiting

If you encounter rate limiting, adjust your configuration:

```yaml
auto_easy_localization:
  delay_between_requests: 2000 # Increase delay
  max_retries: 5 # More retry attempts
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
