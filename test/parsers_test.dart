import 'package:flutter_test/flutter_test.dart';
import 'package:tango/utils/parsers.dart';

void main() {
  group('parseNullableString', () {
    test('returns null for "nan" or "ー"', () {
      expect(parseNullableString('nan'), isNull);
      expect(parseNullableString('ー'), isNull);
    });

    test('returns string for others', () {
      expect(parseNullableString('hello'), 'hello');
    });
  });

  group('parseDouble', () {
    test('parses num and string', () {
      expect(parseDouble(2), 2.0);
      expect(parseDouble('3.5'), 3.5);
    });

    test('returns 0.0 for invalid', () {
      expect(parseDouble('abc'), 0.0);
    });
  });

  group('parseStringList', () {
    test('parses list and comma string', () {
      expect(parseStringList(['a', 'b']), ['a', 'b']);
      expect(parseStringList('a,b'), ['a', 'b']);
    });

    test('handles null and "nan"', () {
      expect(parseStringList(null), isNull);
      expect(parseStringList('nan'), isNull);
    });
  });

  group('parseDate', () {
    test('parses DateTime and ISO string', () {
      final now = DateTime.now();
      expect(parseDate(now), now);
      final iso = now.toIso8601String();
      expect(parseDate(iso)?.toIso8601String(), iso);
    });

    test('returns null for invalid', () {
      expect(parseDate('bad'), isNull);
    });
  });
}
