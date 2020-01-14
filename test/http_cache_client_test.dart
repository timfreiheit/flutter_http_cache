import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http_cache_client/http_cache_client.dart';
import 'package:http_cache_client/src/cache_meta_data.dart';
import 'package:mockito/mockito.dart';

import 'mocks.dart';

void main() {
  final uri = Uri.parse("http://google.de");

  group('test HttpCacheClient ignore cache', () {
    test('on POST requests', () async {
      final mockCache = MockDiskCache();
      final mockClient = MockHttpClient();
      final client = HttpCacheClient(mockClient, mockCache);

      when(mockClient.send(any)).thenAnswer(
          (_) => Future.value(StreamedResponse(Stream.empty(), 200)));

      final request = Request("post", uri)..body = "";
      await client.send(request);
      verifyZeroInteractions(mockCache);
      verify(mockClient.send(request)).called(1);
    });

    test('on DELETE requests', () async {
      final mockCache = MockDiskCache();
      final mockClient = MockHttpClient();
      final client = HttpCacheClient(mockClient, mockCache);

      when(mockClient.send(any)).thenAnswer(
          (_) => Future.value(StreamedResponse(Stream.empty(), 200)));

      final request = Request("delete", uri)..body = "";
      await client.send(request);
      verifyZeroInteractions(mockCache);
      verify(mockClient.send(request)).called(1);
    });

    test('on PUT requests', () async {
      final mockCache = MockDiskCache();
      final mockClient = MockHttpClient();
      final client = HttpCacheClient(mockClient, mockCache);

      when(mockClient.send(any)).thenAnswer(
          (_) => Future.value(StreamedResponse(Stream.empty(), 200)));

      final request = Request("put", uri)..body = "";
      await client.send(request);
      verifyZeroInteractions(mockCache);
      verify(mockClient.send(request)).called(1);
    });

    test('on HEAD requests', () async {
      final mockCache = MockDiskCache();
      final mockClient = MockHttpClient();
      final client = HttpCacheClient(mockClient, mockCache);

      when(mockClient.send(any)).thenAnswer(
          (_) => Future.value(StreamedResponse(Stream.empty(), 200)));

      final request = Request("head", uri);
      await client.send(request);
      verifyZeroInteractions(mockCache);
      verify(mockClient.send(request)).called(1);
    });

    test('on PATCH requests', () async {
      final mockCache = MockDiskCache();
      final mockClient = MockHttpClient();
      final client = HttpCacheClient(mockClient, mockCache);

      when(mockClient.send(any)).thenAnswer(
          (_) => Future.value(StreamedResponse(Stream.empty(), 200)));

      final request = Request("patch", uri);
      await client.send(request);
      verifyZeroInteractions(mockCache);
      verify(mockClient.send(request)).called(1);
    });

    test("when client request noCache", () async {
      final mockCache = MockDiskCache();
      final mockClient = MockHttpClient();
      final client = HttpCacheClient(mockClient, mockCache);

      when(mockClient.send(any)).thenAnswer(
          (_) => Future.value(StreamedResponse(Stream.empty(), 200)));

      final request = Request("get", uri)
        ..headers["cache-control"] = "no-cache";
      await client.send(request);
      verifyZeroInteractions(mockCache);
      verify(mockClient.send(request)).called(1);
    });
  });

  group("test HttpCacheClient", () {
    test("response not cached when status code is not in range 200 until 300",
        () async {
      final mockCache = MockDiskCache();
      when(mockCache.getCacheMetaData(any))
          .thenAnswer((_) => Future.value(null));
      final mockClient = MockHttpClient();

      final client = HttpCacheClient(mockClient, mockCache);

      when(mockClient.send(any)).thenAnswer((_) => Future.value(
          StreamedResponse(Stream.empty(), 199, headers: {"etag": "124"})));
      await client.get(uri);

      when(mockClient.send(any)).thenAnswer((_) => Future.value(
          StreamedResponse(Stream.empty(), 300, headers: {"etag": "124"})));
      await client.get(uri);

      when(mockClient.send(any)).thenAnswer((_) => Future.value(
          StreamedResponse(Stream.empty(), 422, headers: {"etag": "124"})));
      await client.get(uri);

      when(mockClient.send(any)).thenAnswer((_) => Future.value(
          StreamedResponse(Stream.empty(), 444, headers: {"etag": "124"})));
      await client.get(uri);

      verifyNever(mockCache.save(any, any));
    });

    test("read cache when server responses with 304 and cache has valid data",
        () async {
      final mockCacheMetaData = MockCacheMetaData();
      when(mockCacheMetaData.isValid(any, any)).thenReturn(true);

      final mockCache = MockDiskCache();
      when(mockCache.getCacheMetaData(any))
          .thenAnswer((_) => Future.value(mockCacheMetaData));
      when(mockCache.getCachedStream(any))
          .thenAnswer((_) => Future.value(Stream.empty()));

      final mockClient = MockHttpClient();
      when(mockClient.send(any)).thenAnswer(
          (_) => Future.value(StreamedResponse(Stream.empty(), 304)));

      final client = HttpCacheClient(mockClient, mockCache);
      await client.get(uri);

      verifyNever(mockCache.save(any, any));
      verify(mockCache.getCachedStream(any)).called(1);
    });

    test(
        "do not read cache when server responses with 304 and cache has no valid data",
        () async {
      final mockCache = MockDiskCache();
      when(mockCache.getCacheMetaData(any))
          .thenAnswer((_) => Future.value(null));
      when(mockCache.getCachedStream(any))
          .thenAnswer((_) => Future.value(Stream.empty()));

      final mockClient = MockHttpClient();
      when(mockClient.send(any)).thenAnswer(
          (_) => Future.value(StreamedResponse(Stream.empty(), 304)));

      final client = HttpCacheClient(mockClient, mockCache);
      await client.get(uri);

      verifyNever(mockCache.save(any, any));
      verifyNever(mockCache.getCachedStream(any));
    });

    test("cache response when response is cachable", () async {
      final mockCache = MockDiskCache();
      when(mockCache.getCacheMetaData(any))
          .thenAnswer((_) => Future.value(null));
      when(mockCache.getCachedStream(any))
          .thenAnswer((_) => Future.value(Stream.empty()));

      final mockClient = MockHttpClient();
      when(mockClient.send(any)).thenAnswer((_) => Future.value(
          StreamedResponse(Stream.empty(), 200, headers: {"etag": "1234"})));

      final client = HttpCacheClient(mockClient, mockCache);
      await client.get(uri);

      verify(mockCache.save(any, any)).called(1);
    });

    test("do not cache response when response is not cachable", () async {
      final mockCache = MockDiskCache();
      when(mockCache.getCacheMetaData(any))
          .thenAnswer((_) => Future.value(null));
      when(mockCache.getCachedStream(any))
          .thenAnswer((_) => Future.value(Stream.empty()));

      final mockClient = MockHttpClient();
      when(mockClient.send(any)).thenAnswer(
          (_) => Future.value(StreamedResponse(Stream.empty(), 200)));

      final client = HttpCacheClient(mockClient, mockCache);
      await client.get(uri);

      verifyNever(mockCache.save(any, any));
    });

    test("add if-none-match header when cached response had etag", () async {
      final cacheMetaData = CacheMetaData(eTag: "1234");

      final mockCache = MockDiskCache();
      when(mockCache.getCacheMetaData(any))
          .thenAnswer((_) => Future.value(cacheMetaData));
      when(mockCache.getCachedStream(any))
          .thenAnswer((_) => Future.value(Stream.empty()));

      final mockClient = MockHttpClient();
      when(mockClient.send(any)).thenAnswer(
          (_) => Future.value(StreamedResponse(Stream.empty(), 304)));

      final client = HttpCacheClient(mockClient, mockCache);
      await client.get(uri);

      verify(mockClient.send(argThat(predicate((BaseRequest request) => request.headers["If-None-Match"] == "1234"))));

      verifyNever(mockCache.save(any, any));
      verify(mockCache.getCachedStream(any)).called(1);
    });
  });
}
