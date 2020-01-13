import 'package:http/http.dart';
import 'package:http_cache_client/http_cache_client.dart';
import 'package:http_cache_client/src/cache_meta_data.dart';
import 'package:mockito/mockito.dart';

class MockDiskCache extends Mock implements DiskCache {}
class MockHttpClient extends Mock implements Client {}
class MockCacheMetaData extends Mock implements CacheMetaData {}