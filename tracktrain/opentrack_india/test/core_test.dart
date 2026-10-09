import 'package:flutter_test/flutter_test.dart';
import 'package:opentrack_india/core/csv.dart';
import 'package:opentrack_india/core/fuzzy_match.dart';
import 'package:opentrack_india/core/geo_utils.dart';
import 'package:opentrack_india/data/models/train.dart';

void main() {
  group('GeoUtils', () {
    test('haversine: New Delhi to Bhopal is roughly 620 km', () {
      final meters = GeoUtils.haversineMeters(
        28.6430,
        77.2190,
        23.2680,
        77.4020,
      );
      expect(meters / 1000, inInclusiveRange(590, 650));
    });

    test('haversine of identical points is zero', () {
      expect(GeoUtils.haversineMeters(13.08, 80.27, 13.08, 80.27), 0.0);
    });

    test('bearing: due north is 0 degrees', () {
      final bearing = GeoUtils.bearingDegrees(10, 77, 11, 77);
      expect(bearing, closeTo(0, 0.5));
    });

    test('cardinal buckets', () {
      expect(GeoUtils.cardinal(0), 'N');
      expect(GeoUtils.cardinal(90), 'E');
      expect(GeoUtils.cardinal(260), 'W');
    });

    test('ETA floors speed so a stopped train still projects arrival', () {
      final eta = GeoUtils.etaForDistance(50000, speedKmh: 0);
      expect(eta.inMinutes, 120); // 50 km at the 25 km/h floor
    });

    test('rail route factor inflates straight-line distance', () {
      expect(GeoUtils.railDistanceMeters(1000), 1200);
    });

    test('distance formatting', () {
      expect(GeoUtils.formatDistance(850), '850 m');
      expect(GeoUtils.formatDistance(12400), '12.4 km');
      expect(GeoUtils.formatDistance(150000), '150 km');
    });
  });

  group('FuzzyMatch (typo tolerance)', () {
    test('identical strings score 1.0', () {
      expect(FuzzyMatch.similarity('Chennai', 'Chennai'), 1.0);
    });

    test('misspelled "rajdhni" still matches "Rajdhani"', () {
      final score = FuzzyMatch.combinedScore('rajdhni', 'Mumbai Rajdhani');
      expect(score, greaterThan(0.7));
    });

    test('misspelled "bopal jn" matches "Bhopal Jn"', () {
      final score = FuzzyMatch.combinedScore('bopal jn', 'Bhopal Jn');
      expect(score, greaterThan(0.75));
    });

    test('prefix query gets a strong boost', () {
      final score = FuzzyMatch.combinedScore('chen', 'MGR Chennai Central');
      expect(score, greaterThan(0.85));
    });

    test('unrelated strings score low', () {
      final score = FuzzyMatch.combinedScore('xyzzy', 'Mumbai Rajdhani');
      expect(score, lessThan(0.5));
    });

    test('levenshtein edit distances', () {
      expect(FuzzyMatch.levenshtein('kitten', 'sitting'), 3);
      expect(FuzzyMatch.levenshtein('NDLS', 'NDLS'), 0);
      expect(FuzzyMatch.levenshtein('', 'abc'), 3);
    });
  });

  group('Csv parser', () {
    test('parses headers, rows and quoted fields', () {
      const raw =
          'code,name,note\nNDLS,New Delhi,"capital, India"\nMAS,Chennai,';
      final (headers, rows) = Csv.parse(raw);
      expect(headers, ['code', 'name', 'note']);
      expect(rows, hasLength(2));
      expect(rows[0]['name'], 'New Delhi');
      expect(rows[0]['note'], 'capital, India');
      expect(rows[1]['note'], '');
    });

    test('skips blank lines', () {
      const raw = 'a,b\n1,2\n\n3,4\n';
      final (_, rows) = Csv.parse(raw);
      expect(rows, hasLength(2));
    });
  });

  group('Train model', () {
    test('days summary handles daily and weekly patterns', () {
      const daily = Train(
        id: 1,
        number: '12951',
        name: 'Mumbai Rajdhani',
        sourceCode: 'MMCT',
        destinationCode: 'NDLS',
        daysBitmask: '1111111',
        type: 'Rajdhani',
      );
      expect(daily.runsDaily, isTrue);
      expect(daily.daysSummary, 'Daily');

      const weekdays = Train(
        id: 2,
        number: '12001',
        name: 'Bhopal Shatabdi',
        sourceCode: 'NDLS',
        destinationCode: 'BPL',
        daysBitmask: '1111110',
        type: 'Shatabdi',
      );
      expect(weekdays.runsDaily, isFalse);
      expect(weekdays.daysSummary, contains('days/week'));
      expect(weekdays.routeLabel, 'NDLS → BPL');
    });
  });
}
