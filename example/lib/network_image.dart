import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui show Codec;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';

class AppNetworkImage extends ImageProvider<AppNetworkImage> {

  static Client client;

  /// Creates an object that fetches the image at the given URL.
  ///
  /// The arguments must not be null.
  const AppNetworkImage(this.url, {this.scale = 1.0, this.headers})
      : assert(url != null),
        assert(scale != null);

  /// The URL from which the image will be fetched.
  final String url;

  /// The scale to place in the [ImageInfo] object of the image.
  final double scale;

  /// The HTTP headers that will be used with [HttpClient.get] to fetch image from network.
  final Map<String, String> headers;

  @override
  Future<AppNetworkImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<AppNetworkImage>(this);
  }

  @override
  ImageStreamCompleter load(AppNetworkImage key, DecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
        codec: _loadAsyncWithRetry(key, decode),
        scale: key.scale,
        informationCollector: () {
          return <DiagnosticsNode>[
            DiagnosticsProperty<AppNetworkImage>('Image provider', this),
            DiagnosticsProperty<AppNetworkImage>('Image key', key),
          ];
        })
      ..addListener(
        ImageStreamListener(
          (ImageInfo image, bool synchronousCall) {},
          onError: (exception, stack) async {
            FlutterError.dumpErrorToConsole(FlutterErrorDetails(
              exception: exception,
              stack: stack,
              context: DiagnosticsProperty<AppNetworkImage>('Image key', key,
                  description: "load image with url: $url"),
              library: 'image resource service',
            ));
          },
        ),
      );
  }

  Future<ui.Codec> _loadAsyncWithRetry(
      AppNetworkImage key, DecoderCallback decode) async {
    const maxRetries = 3;
    for (int i = 1; i <= maxRetries; i++) {
      try {
        return await _loadAsync(key, decode);
      } catch (e) {
        if (maxRetries == i) {
          rethrow;
        }
        await Future.delayed(Duration(seconds: i + 1));
      }
    }
    return null;
  }

  Future<ui.Codec> _loadAsync(
      AppNetworkImage key, DecoderCallback decode) async {
    assert(key == this);

    final Uri resolved = Uri.base.resolve(key.url);

    final response = await client.get(resolved);
    if (response.statusCode != 200) {
      throw Exception(
          'HTTP request failed, statusCode: ${response?.statusCode}, $resolved');
    }
    final Uint8List bytes = response.bodyBytes;
    return decode(bytes);
  }

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final AppNetworkImage typedOther = other;
    return url == typedOther.url && scale == typedOther.scale;
  }

  @override
  int get hashCode => hashValues(url, scale);

  @override
  String toString() => '$runtimeType("$url", scale: $scale)';
}
