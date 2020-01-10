import 'package:http/http.dart';
import 'package:http_cache_client/src/cache_control.dart';

class CacheMetaData {
  final String eTag;
  final DateTime timestamp;
  final Duration maxAge;

  final Map<String, String> headers;

  CacheMetaData({
    this.timestamp,
    this.eTag,
    this.maxAge,
    this.headers,
  });

  factory CacheMetaData.fromResponse(BaseResponse response) {
    final serverCacheControl = ServerCacheControl.fromResponse(response);
    return CacheMetaData(
      timestamp: DateTime.now(),
      headers: response.headers,
      eTag: serverCacheControl.eTag,
      maxAge: serverCacheControl.maxAge,
    );
  }

  factory CacheMetaData.fromMap(Map map) {
    return CacheMetaData(
      timestamp: DateTime.parse(map['timestamp']),
      headers: (map['headers'] as Map).cast<String, String>(),
      eTag: map['eTag'],
      maxAge: Duration(milliseconds: map['maxAge']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'eTag': eTag,
      'maxAge': maxAge?.inMilliseconds ?? 0,
      'headers': headers
    };
  }

  bool isValid(DateTime now, ClientCacheControl clientCacheControl) {
    if (clientCacheControl.noCache) {
      return false;
    }
    if (clientCacheControl.onlyIfCached) {
      return true;
    }
    if (clientCacheControl.maxStale != null) {
      return now.difference(timestamp).inMilliseconds <
          clientCacheControl.maxStale.inMilliseconds;
    }
    if (maxAge != null) {
      return now.difference(timestamp).inMilliseconds < maxAge.inMilliseconds;
    }
    return false;
  }
}
