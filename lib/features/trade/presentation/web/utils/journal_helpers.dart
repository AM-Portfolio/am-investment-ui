/// Helper utilities for journal entry processing
class JournalHelpers {
  /// Extracts plain text from HTML content
  static String extractPlainText(String? html) {
    if (html == null || html.isEmpty) return '';

    // Remove HTML tags
    var text = html.replaceAll(RegExp('<[^>]*>'), '');

    // Decode common HTML entities
    text = text
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");

    // Trim and normalize whitespace
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Limits text to a specified number of words
  static String limitToWords(String text, int wordLimit) {
    if (text.isEmpty) return '';

    final words = text.split(RegExp(r'\s+'));
    if (words.length <= wordLimit) return text;

    return '${words.take(wordLimit).join(' ')}...';
  }
}
