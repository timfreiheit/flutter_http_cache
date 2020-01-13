import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http_cache_client/http_cache_client.dart';
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

      final request = Request("get", uri)..headers["cache-control"] = "no-cache";
      await client.send(request);
      verifyZeroInteractions(mockCache);
      verify(mockClient.send(request)).called(1);
    });
  });

  group("test HttpCacheClient", () {
    test("response not cached when status code is not in range 200 until 300", () async {
      final mockCache = MockDiskCache();
      when(mockCache.getCacheMetaData(any)).thenAnswer((_) => Future.value(null));
      final mockClient = MockHttpClient();

      final client = HttpCacheClient(mockClient, mockCache);

      when(mockClient.send(any)).thenAnswer((_) => Future.value(StreamedResponse(Stream.empty(), 199, headers: {"etag": "124"})));
      await client.get(uri);

      when(mockClient.send(any)).thenAnswer((_) => Future.value(StreamedResponse(Stream.empty(), 300, headers: {"etag": "124"})));
      await client.get(uri);

      when(mockClient.send(any)).thenAnswer((_) => Future.value(StreamedResponse(Stream.empty(), 422, headers: {"etag": "124"})));
      await client.get(uri);

      when(mockClient.send(any)).thenAnswer((_) => Future.value(StreamedResponse(Stream.empty(), 444, headers: {"etag": "124"})));
      await client.get(uri);

      verifyNever(mockCache.save(any, any));
    });
  });
}
