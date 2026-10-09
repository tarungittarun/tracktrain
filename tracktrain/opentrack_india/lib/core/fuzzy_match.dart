import 'dart:math' as math;

/// Typo-tolerant matching used to re-rank FTS5 / LIKE candidate rows in Dart.
///
/// SQLite FTS5 performs the fast prefix/token filtering; this layer adds
/// Levenshtein-based resilience so misspelled queries such as "bopal jn" or
/// "rajdhni" still surface the right rows instantly.
class FuzzyMatch {
  FuzzyMatch._();

  /// Classic Wagner–Fischer edit distance with two rolling rows (O(min(m,n))
  /// memory).
  static int levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    var previous = List<int>.generate(b.length + 1, (i) => i);
    final current = List<int>.filled(b.length + 1, 0);

    for (var i = 1; i <= a.length; i++) {
      current[0] = i;
      final ca = a.codeUnitAt(i - 1);
      for (var j = 1; j <= b.length; j++) {
        final cost = ca == b.codeUnitAt(j - 1) ? 0 : 1;
        current[j] = math.min(
          math.min(current[j - 1] + 1, previous[j] + 1),
          previous[j - 1] + cost,
        );
      }
      final swap = List<int>.of(current);
      previous = swap;
    }
    return previous[b.length];
  }

  /// Normalized similarity in [0,1]; 1 means identical.
  static double similarity(String a, String b) {
    if (a.isEmpty && b.isEmpty) return 1.0;
    final distance = levenshtein(a.toLowerCase(), b.toLowerCase());
    return 1.0 - distance / math.max(a.length, b.length);
  }

  /// Best per-token similarity between [query] and [candidate], so a query
  /// like "chennai" matches "MGR Chennai Central" through one token.
  static double bestTokenScore(String query, String candidate) {
    final queryTokens = query.toLowerCase().split(RegExp(r'\s+'))
      ..removeWhere((t) => t.isEmpty);
    final candidateTokens = candidate.toLowerCase().split(RegExp(r'\s+'))
      ..removeWhere((t) => t.isEmpty);
    if (queryTokens.isEmpty || candidateTokens.isEmpty) return 0.0;

    var best = 0.0;
    for (final q in queryTokens) {
      var tokenBest = 0.0;
      for (final c in candidateTokens) {
        var score = similarity(q, c);
        if (c.startsWith(q)) {
          score = math.max(score, 0.95);
        }
        tokenBest = math.max(tokenBest, score);
      }
      best += tokenBest;
    }
    return best / queryTokens.length;
  }

  /// Combined ranking score used by repositories: token similarity blended
  /// with a boost when the whole candidate starts with the query.
  static double combinedScore(String query, String candidate) {
    final q = query.trim().toLowerCase();
    final c = candidate.trim().toLowerCase();
    if (q.isEmpty) return 0.0;
    var score = bestTokenScore(q, c);
    if (c.startsWith(q)) score = math.max(score, 0.98);
    return score;
  }
}
