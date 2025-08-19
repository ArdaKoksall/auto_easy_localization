class ProgressBar {
  final int total;
  final int barWidth;
  int current = 0;
  late DateTime _startTime;
  String _currentLocale = '';
  int _currentKeysCount = 0;
  int _totalKeysProcessed = 0;
  bool _isCompleted = false;

  static const String _filled = '█';
  static const String _empty = '░';
  static const String _spinnerFrames = '⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏';
  int _spinnerIndex = 0;

  ProgressBar(this.total, {this.barWidth = 40}) {
    _startTime = DateTime.now();
    print('🚀 Starting translation process...');
  }

  void update(int progress, String locale, {int keysCount = 0}) {
    if (_isCompleted) return;

    current = progress;
    _currentLocale = locale;
    _currentKeysCount = keysCount;
    _totalKeysProcessed += keysCount;
    _spinnerIndex = (_spinnerIndex + 1) % _spinnerFrames.length;

    _printProgress();
  }

  void updateKeyProgress(int processedKeys, int totalKeys) {
    if (_isCompleted) return;
    _currentKeysCount = totalKeys;
    _printProgress();
  }

  void complete() {
    if (_isCompleted) return;
    _isCompleted = true;

    final duration = DateTime.now().difference(_startTime);
    print('\n${_buildCompletionMessage(duration)}');
  }

  void _printProgress() {
    final percentage = (current / total * 100);
    final filled = (barWidth * current / total).round();

    final bar = _filled * filled + _empty * (barWidth - filled);
    final spinner = _spinnerFrames[_spinnerIndex];

    final elapsed = DateTime.now().difference(_startTime);
    final avgTimePerLocale = current > 0 ? elapsed.inSeconds / current : 0;
    final remainingLocales = total - current;
    final estimatedRemaining = Duration(
      seconds: (avgTimePerLocale * remainingLocales).round(),
    );

    final elapsedStr = _formatDuration(elapsed);
    final etaStr = current > 0 ? _formatDuration(estimatedRemaining) : '--:--';
    final keysInfo = _currentKeysCount > 0 ? ' • $_currentKeysCount keys' : '';

    // Simple single-line output
    final output =
        '$spinner $_currentLocale ${percentage.toStringAsFixed(1)}% [$bar] $current/$total • $elapsedStr • ETA: $etaStr$keysInfo';

    // Use carriage return to overwrite the line
    print('\r$output');
  }

  String _buildCompletionMessage(Duration duration) {
    final durationStr = _formatDuration(duration);
    final avgTime = total > 0
        ? (duration.inMilliseconds / total / 1000).toStringAsFixed(1)
        : '0';

    return '''
✨ Translation completed successfully!
📊 Statistics:
   • Total locales: $total
   • Duration: $durationStr
   • Average per locale: ${avgTime}s
   • Total keys processed: $_totalKeysProcessed''';
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void showError(String message) {
    print('\n❌ Error: $message');
    _isCompleted = true;
  }

  void showWarning(String message) {
    print('\n⚠️  Warning: $message');
  }
}
