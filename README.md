# http_cache_client

http_cache_client is a disk cache library for the [dart http package](https://pub.dev/packages/http)
It stores responses in an [LRU Disk Cache](https://pub.dev/packages/disk_lru_cache) depending on the http cache headers.

The supported server values inside of the http cache-control are
- max-age
- no-store

As well as the etag header.

The supported client values inside of the http cache-control are
- only-if-cached
- no-cache
- max-stale

## Usage

Instead of using the generic `http.get` method create an explicit http.Client which will be wrapped by the HttpCacheClient

```dart
import 'package:http_cache_client/http_cache_client.dart';
import 'package:http/http.dart' as http;

final dir = Directory((await getTemporaryDirectory()).path + "/http");
final client = http.Client().withDiskCache(DiskCache(directory: dir));
```

The created client should be reused on every request.

## Advanced usage

Specify the DiskCache
```dart
final cache = DiskCache(
    directory,
    20 * 1024 * 1024 // 20 MB cache size
);
```

Force reading response from cache 
```dart
client.get(uri, headers: {
  "cache-control": "only-if-cached"
})
```

Force reading response from network 
```dart
client.get(uri, headers: {
  "cache-control": "no-cache"
})
```
