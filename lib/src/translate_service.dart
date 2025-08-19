import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;

class GoogleTranslateService {
  final int _delayBetweenRequests;
  final int _maxRetries;
  static const int _defaultDelay = 100;

  final List<String> _userAgents = [
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
  ];

  GoogleTranslateService({
    int delayBetweenRequests = _defaultDelay,
    int maxRetries = 3,
  }) : _delayBetweenRequests = delayBetweenRequests,
       _maxRetries = maxRetries;

  Future<String> translateText(
    String text,
    String sourceLanguage,
    String targetLanguage,
  ) async {
    if (text.trim().isEmpty) return text;

    for (int attempt = 0; attempt < _maxRetries; attempt++) {
      try {
        final translatedText = await _translateWithGoogleFree(
          text,
          sourceLanguage,
          targetLanguage,
        );
        await Future.delayed(Duration(milliseconds: _delayBetweenRequests));
        return translatedText;
      } catch (e) {
        if (attempt == _maxRetries - 1) {
          return text; // Return original text if all attempts fail
        }
        await Future.delayed(Duration(seconds: (attempt + 1) * 2));
      }
    }
    return text;
  }

  Future<String> _translateWithGoogleFree(
    String text,
    String sourceLanguage,
    String targetLanguage,
  ) async {
    final encodedText = Uri.encodeComponent(text);
    final url =
        'https://translate.googleapis.com/translate_a/single?client=gtx&sl=$sourceLanguage&tl=$targetLanguage&dt=t&q=$encodedText';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'User-Agent': _userAgents[Random().nextInt(_userAgents.length)],
        'Accept': 'application/json',
        'Accept-Language': 'en-US,en;q=0.9',
      },
    );

    if (response.statusCode == 200) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is List && decoded.isNotEmpty && decoded[0] is List) {
          final translations = decoded[0] as List;
          final buffer = StringBuffer();

          for (var translation in translations) {
            if (translation is List && translation.isNotEmpty) {
              buffer.write(translation[0].toString());
            }
          }

          final result = buffer.toString();
          if (result.isNotEmpty) {
            return result;
          }
        }
      } catch (e) {
        throw Exception('Failed to parse Google Translate response: $e');
      }
    }

    throw HttpException(
      'Google Translate request failed with status: ${response.statusCode}',
    );
  }

  Future<Map<String, String>> translateBatch(
    Map<String, String> texts,
    String sourceLanguage,
    String targetLanguage,
  ) async {
    final Map<String, String> translations = {};

    for (final entry in texts.entries) {
      if (entry.value.trim().isEmpty) {
        translations[entry.key] = entry.value;
        continue;
      }

      try {
        final translatedText = await translateText(
          entry.value,
          sourceLanguage,
          targetLanguage,
        );
        translations[entry.key] = translatedText;
      } catch (e) {
        translations[entry.key] = entry.value; // Keep original text
      }
    }

    return translations;
  }

  Future<bool> validateService() async {
    try {
      final result = await translateText('Hello', 'en', 'es');
      return result.isNotEmpty && result.toLowerCase() != 'hello';
    } catch (e) {
      return false;
    }
  }

  Map<String, String> getSupportedLanguages() {
    return _googleLanguageCodes;
  }

  bool isLanguageSupported(String languageCode) {
    return _googleLanguageCodes.containsKey(languageCode.toLowerCase());
  }

  String? getLanguageName(String languageCode) {
    return _googleLanguageCodes[languageCode.toLowerCase()];
  }

  static const Map<String, String> _googleLanguageCodes = {
    'af': 'Afrikaans',
    'sq': 'Albanian',
    'am': 'Amharic',
    'ar': 'Arabic',
    'hy': 'Armenian',
    'az': 'Azerbaijani',
    'eu': 'Basque',
    'be': 'Belarusian',
    'bn': 'Bengali',
    'bs': 'Bosnian',
    'bg': 'Bulgarian',
    'ca': 'Catalan',
    'ceb': 'Cebuano',
    'zh': 'Chinese (Simplified)',
    'zh-cn': 'Chinese (Simplified)',
    'zh-tw': 'Chinese (Traditional)',
    'co': 'Corsican',
    'hr': 'Croatian',
    'cs': 'Czech',
    'da': 'Danish',
    'nl': 'Dutch',
    'en': 'English',
    'eo': 'Esperanto',
    'et': 'Estonian',
    'fi': 'Finnish',
    'fr': 'French',
    'fy': 'Frisian',
    'gl': 'Galician',
    'ka': 'Georgian',
    'de': 'German',
    'el': 'Greek',
    'gu': 'Gujarati',
    'ht': 'Haitian Creole',
    'ha': 'Hausa',
    'haw': 'Hawaiian',
    'he': 'Hebrew',
    'hi': 'Hindi',
    'hmn': 'Hmong',
    'hu': 'Hungarian',
    'is': 'Icelandic',
    'ig': 'Igbo',
    'id': 'Indonesian',
    'ga': 'Irish',
    'it': 'Italian',
    'ja': 'Japanese',
    'jw': 'Javanese',
    'kn': 'Kannada',
    'kk': 'Kazakh',
    'km': 'Khmer',
    'rw': 'Kinyarwanda',
    'ko': 'Korean',
    'ku': 'Kurdish',
    'ky': 'Kyrgyz',
    'lo': 'Lao',
    'lv': 'Latvian',
    'lt': 'Lithuanian',
    'lb': 'Luxembourgish',
    'mk': 'Macedonian',
    'mg': 'Malagasy',
    'ms': 'Malay',
    'ml': 'Malayalam',
    'mt': 'Maltese',
    'mi': 'Maori',
    'mr': 'Marathi',
    'mn': 'Mongolian',
    'my': 'Myanmar (Burmese)',
    'ne': 'Nepali',
    'no': 'Norwegian',
    'ny': 'Nyanja (Chichewa)',
    'or': 'Odia (Oriya)',
    'ps': 'Pashto',
    'fa': 'Persian',
    'pl': 'Polish',
    'pt': 'Portuguese',
    'pa': 'Punjabi',
    'ro': 'Romanian',
    'ru': 'Russian',
    'sm': 'Samoan',
    'gd': 'Scots Gaelic',
    'sr': 'Serbian',
    'st': 'Sesotho',
    'sn': 'Shona',
    'sd': 'Sindhi',
    'si': 'Sinhala (Sinhalese)',
    'sk': 'Slovak',
    'sl': 'Slovenian',
    'so': 'Somali',
    'es': 'Spanish',
    'su': 'Sundanese',
    'sw': 'Swahili',
    'sv': 'Swedish',
    'tl': 'Tagalog (Filipino)',
    'tg': 'Tajik',
    'ta': 'Tamil',
    'tt': 'Tatar',
    'te': 'Telugu',
    'th': 'Thai',
    'tr': 'Turkish',
    'tk': 'Turkmen',
    'uk': 'Ukrainian',
    'ur': 'Urdu',
    'ug': 'Uyghur',
    'uz': 'Uzbek',
    'vi': 'Vietnamese',
    'cy': 'Welsh',
    'xh': 'Xhosa',
    'yi': 'Yiddish',
    'yo': 'Yoruba',
    'zu': 'Zulu',
  };
}
