import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Result of a successful live lookup.
class LiveTrainStatus {
  const LiveTrainStatus({
    required this.trainNumber,
    required this.delayMinutes,
    required this.platform,
    required this.fetchedAt,
  });

  final String trainNumber;
  final int delayMinutes;
  final String platform;
  final DateTime fetchedAt;
}

/// Live Hybrid Fallback (Internet Mode).
///
/// The app never depends on a paid key or a single third-party proxy: the
/// endpoint is user-configurable (settings screen) and speaks a tiny,
/// documented JSON contract:
///
/// ```json
/// GET {base}/train/{number}/status
/// → { "delay_minutes": 15, "platform": "4" }
/// ```
///
/// When the endpoint is empty, the network drops, or parsing fails, the
/// method returns null and callers present the offline estimate instead —
/// the graceful-fallback guarantee from the spec.
class LiveRailService {
  static const Duration requestTimeout = Duration(seconds: 6);

  Future<LiveTrainStatus?> fetchTrainStatus({
    required String baseUrl,
    required String trainNumber,
  }) async {
    final base = baseUrl.trim();
    if (base.isEmpty) return null;

    try {
      final normalized = base.endsWith('/')
          ? base.substring(0, base.length - 1)
          : base;
      final uri = Uri.parse('$normalized/train/$trainNumber/status');
      final response = await http
          .get(uri, headers: const {'accept': 'application/json'})
          .timeout(requestTimeout);
      if (response.statusCode != 200) return null;

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return null;

      return LiveTrainStatus(
        trainNumber: trainNumber,
        delayMinutes: (decoded['delay_minutes'] as num?)?.toInt() ?? 0,
        platform: (decoded['platform'] as Object?)?.toString() ?? '',
        fetchedAt: DateTime.now(),
      );
    } on TimeoutException {
      return null;
    } on FormatException {
      return null;
    } catch (_) {
      return null;
    }
  }
}
