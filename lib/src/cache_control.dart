import 'package:http/http.dart';

/// https://developer.mozilla.org/de/docs/Web/HTTP/Headers/Cache-Control

class ServerCacheControl {
  final String eTag;
  final Duration maxAge;
  final bool noStore;

  ServerCacheControl({
    this.eTag,
    this.maxAge,
    this.noStore = false,
  });

  factory ServerCacheControl.fromResponse(BaseResponse response) {
    String eTag;
    String cacheControlHeader;

    response.headers.forEach((key, value) {
      switch (key.toLowerCase()) {
        case 'etag':
          eTag = value;
          break;
        case 'cache-control':
          cacheControlHeader = value;
          break;
      }
    });

    final cacheControlMap = _cacheControlMap(cacheControlHeader);
    return ServerCacheControl(
      eTag: eTag,
      maxAge: _maxAgeFromCacheControl(cacheControlHeader),
      noStore: cacheControlMap['no-store'] == 'true'
    );
  }

  bool canBeCached() {
    return !noStore && (eTag != null || maxAge != null);
  }
}

class ClientCacheControl {
  final bool onlyIfCached;
  final bool noCache;
  final Duration maxStale;

  ClientCacheControl({
    this.onlyIfCached = false,
    this.noCache = false,
    this.maxStale,
  });

  factory ClientCacheControl.fromRequest(Request request) {
    String cacheControlHeader;

    request.headers.forEach((key, value) {
      switch (key.toLowerCase()) {
        case 'cache-control':
          cacheControlHeader = value;
          break;
      }
    });

    final cacheControls = _cacheControlMap(cacheControlHeader);
    return ClientCacheControl(
      maxStale: _maxStaleFromCacheControl(cacheControlHeader),
      onlyIfCached: cacheControls['only-if-cached'] == 'true',
      noCache: cacheControls['no-cache'] == 'true',
    );
  }
}

Map<String, String> _cacheControlMap(String cacheControlHeader) {
  if (cacheControlHeader == null) {
    return <String, String>{};
  }
  final map = <String, String>{};
  for (var value in cacheControlHeader.split(',')) {
    final keyValue = value.split('=');
    if (keyValue.length > 1) {
      map[keyValue[0].toLowerCase().trim()] = keyValue[1].toLowerCase().trim();
    } else {
      map[keyValue[0].toLowerCase().trim()] = 'true';
    }
  }
  return map;
}

Duration _maxAgeFromCacheControl(String cacheControlHeader) {
  final maxAge = _cacheControlMap(cacheControlHeader)['max-age'];
  if (maxAge == null) {
    return null;
  }
  try {
    return Duration(seconds: int.tryParse(maxAge));
  } catch (e) {
    return null;
  }
}

Duration _maxStaleFromCacheControl(String cacheControlHeader) {
  final maxStale = _cacheControlMap(cacheControlHeader)['max-stale'];
  if (maxStale == null) {
    return null;
  }
  try {
    return Duration(seconds: int.tryParse(maxStale));
  } catch (e) {
    return null;
  }
}
