import 'package:http/http.dart';
import 'package:http_cache_client/http_cache_client.dart';

extension HttpCacheClientExtension on Client {
  Client withDiskCache(DiskCache cache) {
    return HttpCacheClient(this, cache);
  }
}
