import 'package:http/http.dart';
import 'package:http_cache_client/src/cache_control.dart';
import 'package:test/test.dart';

void main() {
  group('test server cache control ', () {
    test('parse basic', () {
      final cacheControl =
          ServerCacheControl.fromResponse(Response('', 200, headers: {}));
      assert(cacheControl.eTag == null);
      assert(cacheControl.maxAge == null);
      assert(cacheControl.noStore == false);
    });

    test('parse etag', () {
      final expectedEtag = '21638592671352137590';
      final cacheControl = ServerCacheControl.fromResponse(
          Response('', 200, headers: {'etag': expectedEtag}));
      assert(cacheControl.eTag == expectedEtag);
      assert(cacheControl.maxAge == null);
      assert(cacheControl.noStore == false);
    });

    test('parse etag case insensitive', () {
      final expectedEtag = '550e8400-e29b-11d4-a716-446655440000';
      final cacheControl = ServerCacheControl.fromResponse(
          Response('', 200, headers: {'EtAg': expectedEtag}));
      assert(cacheControl.eTag == expectedEtag);
      assert(cacheControl.maxAge == null);
      assert(cacheControl.noStore == false);
    });

    test('parse maxAge', () {
      final cacheControl = ServerCacheControl.fromResponse(
          Response('', 200, headers: {'cache-control': 'max-age=100'}));
      assert(cacheControl.eTag == null);
      assert(cacheControl.maxAge == Duration(seconds: 100));
      assert(cacheControl.noStore == false);
    });

    test('parse maxAge case insensitive', () {
      final cacheControl = ServerCacheControl.fromResponse(
          Response('', 200, headers: {'CaCHe-cONtrOL': 'mAx-aGE=100'}));
      assert(cacheControl.eTag == null);
      assert(cacheControl.maxAge == Duration(seconds: 100));
      assert(cacheControl.noStore == false);
    });

    test('parse noStore', () {
      final cacheControl = ServerCacheControl.fromResponse(
          Response('', 200, headers: {'cache-control': 'no-store'}));
      assert(cacheControl.eTag == null);
      assert(cacheControl.maxAge == null);
      assert(cacheControl.noStore == true);
    });

    test('parse noStore case insensitive', () {
      final cacheControl = ServerCacheControl.fromResponse(
          Response('', 200, headers: {'cAChE-conTRol': 'No-sTORe'}));
      assert(cacheControl.eTag == null);
      assert(cacheControl.maxAge == null);
      assert(cacheControl.noStore == true);
    });

    test('parse combination', () {
      final expectedEtag = '21638592671352137590';
      final cacheControl = ServerCacheControl.fromResponse(Response('', 200,
          headers: {
            'etag': expectedEtag,
            'cache-control': 'no-store,max-age=100'
          }));
      assert(cacheControl.eTag == expectedEtag);
      assert(cacheControl.maxAge == Duration(seconds: 100));
      assert(cacheControl.noStore == true);
    });

    test("canBeCached is false when server sends no caching informations", () {
      final cacheControl = ServerCacheControl();
      assert(cacheControl.canBeCached() == false);
    });

    test("canBeCached is true when server sends etag", () {
      final cacheControl = ServerCacheControl(eTag: "12345");
      assert(cacheControl.canBeCached() == true);
    });

    test("canBeCached is false when server sends noCache", () {
      var cacheControl = ServerCacheControl(
        noStore: true,
      );
      assert(cacheControl.canBeCached() == false);

      cacheControl = ServerCacheControl(
        eTag: "12345",
        noStore: true,
      );
      assert(cacheControl.canBeCached() == false);

      cacheControl = ServerCacheControl(
        maxAge: Duration(days: 1),
        noStore: true,
      );
      assert(cacheControl.canBeCached() == false);

      cacheControl = ServerCacheControl(
        maxAge: Duration(days: 1),
        eTag: "asfasf",
        noStore: true,
      );
      assert(cacheControl.canBeCached() == false);
    });

    test("canBeCached is true when server sends maxAge", () {
      final cacheControl = ServerCacheControl(
        maxAge: Duration(days: 1),
      );
      assert(cacheControl.canBeCached() == true);
    });

    test("canBeCached is true when server sends maxAge with etag", () {
      final cacheControl = ServerCacheControl(
        eTag: "asfasf",
        maxAge: Duration(days: 1),
      );
      assert(cacheControl.canBeCached() == true);
    });
  });
}
