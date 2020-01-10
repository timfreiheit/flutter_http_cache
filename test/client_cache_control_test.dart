import 'package:http/http.dart';
import 'package:http_cache_client/src/cache_control.dart';
import 'package:test/test.dart';

void main() {
  group('test client cache control ', () {

    test('parse basic', () {
      final cacheControl = ClientCacheControl.fromRequest(Request('GET', Uri.http('google.de', '')));
      assert(cacheControl.noCache == false);
      assert(cacheControl.onlyIfCached == false);
      assert(cacheControl.maxStale == null);
    });

    test('parse noCache', () {
      final cacheControl = ClientCacheControl.fromRequest(Request('GET', Uri.http('google.de', ''))..headers["cache-control"] = "no-cache");
      assert(cacheControl.noCache == true);
      assert(cacheControl.onlyIfCached == false);
      assert(cacheControl.maxStale == null);
    });

    test('parse noCache case insensitive', () {
      final cacheControl = ClientCacheControl.fromRequest(Request('GET', Uri.http('google.de', ''))..headers["cAcHE-coNTRol"] = "nO-caCHE");
      assert(cacheControl.noCache == true);
      assert(cacheControl.onlyIfCached == false);
      assert(cacheControl.maxStale == null);
    });

    test('parse only-if-cached', () {
      final cacheControl = ClientCacheControl.fromRequest(Request('GET', Uri.http('google.de', ''))..headers["cache-control"] = "only-if-cached");
      assert(cacheControl.noCache == false);
      assert(cacheControl.onlyIfCached == true);
      assert(cacheControl.maxStale == null);
    });

    test('parse only-if-cached case insensitive', () {
      final cacheControl = ClientCacheControl.fromRequest(Request('GET', Uri.http('google.de', ''))..headers["cAChe-cONtroL"] = "oNlY-iF-caCHEd");
      assert(cacheControl.noCache == false);
      assert(cacheControl.onlyIfCached == true);
      assert(cacheControl.maxStale == null);
    });

    test('parse maxStale', () {
      final cacheControl = ClientCacheControl.fromRequest(Request('GET', Uri.http('google.de', ''))..headers["cache-control"] = "max-stale=100");
      assert(cacheControl.noCache == false);
      assert(cacheControl.onlyIfCached == false);
      assert(cacheControl.maxStale == Duration(seconds: 100));
    });

    test('parse maxStale case insensitive', () {
      final cacheControl = ClientCacheControl.fromRequest(Request('GET', Uri.http('google.de', ''))..headers["cache-cONtrol"] = "mAX-STale=100");
      assert(cacheControl.noCache == false);
      assert(cacheControl.onlyIfCached == false);
      assert(cacheControl.maxStale == Duration(seconds: 100));
    });

    test('parse combined', () {
      final cacheControl = ClientCacheControl.fromRequest(Request('GET', Uri.http('google.de', ''))..headers["cache-control"] = "no-cache, only-if-cached, max-stale=100");
      assert(cacheControl.noCache == true);
      assert(cacheControl.onlyIfCached == true);
      assert(cacheControl.maxStale == Duration(seconds: 100));
    });
  });
}
