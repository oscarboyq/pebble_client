/// Minimal HTML-to-text helper for rendering backend content without a
/// dedicated HTML widget. Handles paragraphs, line breaks and common entities.
String stripHtml(String html) {
  if (html.isEmpty) return '';
  var text = html
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n')
      .replaceAll(RegExp(r'<li>', caseSensitive: false), '• ')
      .replaceAll(RegExp(r'</li>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'<[^>]+>'), '');
  const entities = {
    '&nbsp;': ' ',
    '&amp;': '&',
    '&lt;': '<',
    '&gt;': '>',
    '&quot;': '"',
    '&#39;': "'",
    '&apos;': "'",
    '&mdash;': '—',
    '&ndash;': '–',
  };
  entities.forEach((key, value) => text = text.replaceAll(key, value));
  return text.replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
}
