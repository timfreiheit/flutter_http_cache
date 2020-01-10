import 'package:crypto/crypto.dart';
import 'package:http/http.dart';
import 'package:http_cache_client/src/cache_control.dart';
import 'package:http_cache_client/src/disk_cache.dart';

class HttpCacheClient extends BaseClient {
  final Client _inner;
  final DiskCache _diskCache;

  HttpCacheClient(this._inner, this._diskCache);

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    if (request.method.toUpperCase() != 'GET') {
      // caching is only supported in get requests
      return await _inner.send(request);
    }

    final clientCacheControl = ClientCacheControl.fromRequest(request);
    if (clientCacheControl.noCache) {
      return await _inner.send(request);
    }

    final cacheKey = _createCacheKey(request);

    final cacheMetaData = await _diskCache.getCacheMetaData(cacheKey);
    if (cacheMetaData?.isValid(DateTime.now(), clientCacheControl) == true) {
      return StreamedResponse(
        await _diskCache.getCachedStream(cacheKey),
        200,
        headers: cacheMetaData.headers,
        request: request,
      );
    }

    if (cacheMetaData?.eTag != null) {
      request.headers['If-None-Match'] = cacheMetaData.eTag;
    }

    final response = await _inner.send(request);

    if (response.statusCode == 304 && cacheMetaData != null) {
      // local cache is still valid
      return StreamedResponse(
        await _diskCache.getCachedStream(cacheKey),
        200,
        headers: response.headers,
        request: request,
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      // only cache when response is valid
      return response;
    }

    final serverCacheControl = ServerCacheControl.fromResponse(response);
    if (!serverCacheControl.canBeCached()) {
      return response;
    }
    await _diskCache.save(cacheKey, response);
    return StreamedResponse(
      await _diskCache.getCachedStream(cacheKey),
      200,
      headers: response.headers,
      request: request,
      isRedirect: response.isRedirect,
      contentLength: response.contentLength,
      reasonPhrase: response.reasonPhrase,
      persistentConnection: response.persistentConnection,
    );
  }

  String _createCacheKey(Request request) {
    return md5.convert(request.url.toString().codeUnits).toString();
  }
}
