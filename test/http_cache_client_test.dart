import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http_cache_client/http_cache_client.dart';
import 'package:mockito/mockito.dart';

import 'mocks.dart';

void main() {
  final uri = Uri.parse("http://google.de");

  group('test HttpCacheClient ', () {
    test('ignore cache on POST requests', () async {
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

    test('ignore cache on DELETE requests', () async {
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

    test('ignore cache on PUT requests', () async {
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

    test('ignore cache on HEAD requests', () async {
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

    test('ignore cache on PATCH requests', () async {
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
  });
}
