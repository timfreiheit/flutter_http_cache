import 'package:http_cache_client/src/cache_control.dart';
import 'package:http_cache_client/src/cache_meta_data.dart';
import 'package:test/test.dart';

void main() {
  group('test CacheMetaData ', () {
    test('is invalid when data is empty', () {
      final metaData = CacheMetaData(
        timestamp: DateTime(2020, 1, 1),
      );

      assert(metaData.isValid(DateTime(2020, 1, 1), ClientCacheControl()) ==
          false);
    });

    test('is invalid when client requests no-cache', () {
      final metaData = CacheMetaData(
        timestamp: DateTime(2020, 1, 1),
      );

      assert(metaData.isValid(
              DateTime(2020, 1, 1), ClientCacheControl(noCache: true)) ==
          false);
    });

    test('is valid when client requests only-if-cached', () {
      final metaData = CacheMetaData(
        timestamp: DateTime(2020, 1, 1),
      );

      assert(metaData.isValid(
              DateTime(2020, 1, 1), ClientCacheControl(onlyIfCached: true)) ==
          true);
    });

    test('is valid when max-age has not expired', () {
      final metaData = CacheMetaData(
          timestamp: DateTime(2020, 1, 1), maxAge: Duration(days: 2));

      assert(
          metaData.isValid(DateTime(2020, 1, 2), ClientCacheControl()) == true);
    });

    test('is invalid when max-age has expired', () {
      final metaData = CacheMetaData(
          timestamp: DateTime(2020, 1, 1), maxAge: Duration(days: 2));

      assert(
      metaData.isValid(DateTime(2020, 1, 4), ClientCacheControl()) == false);
    });

    test('is valid when max-stale is within age range', () {
      final metaData = CacheMetaData(
        timestamp: DateTime(2020, 1, 1),
        maxAge: Duration(milliseconds: 1),
      );

      assert(metaData.isValid(DateTime(2020, 1, 2),
              ClientCacheControl(maxStale: Duration(days: 2))) ==
          true);
    });

    test('is invalid when max-stale is not within age range', () {
      final metaData = CacheMetaData(
        timestamp: DateTime(2020, 1, 1),
        maxAge: Duration(milliseconds: 1),
      );

      assert(metaData.isValid(DateTime(2020, 1, 4),
          ClientCacheControl(maxStale: Duration(days: 2))) ==
          false);
    });
  });
}
