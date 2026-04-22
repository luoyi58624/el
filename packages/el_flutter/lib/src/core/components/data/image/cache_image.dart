part of 'index.dart';

/// 网络图片缓存类，此类相当于 [NetworkImage]，你需要使用 [Image] 小部件加载它，
/// 代码示例：
/// ```dart
/// Image(
///   image: ElCacheImage('url').build(),
/// ),
/// ```
class ElCacheImage {
  ElCacheImage(
    this.url, {
    this.scale = 1.0,
    this.headers,
    this.webHtmlElementStrategy = WebHtmlElementStrategy.never,
    this.expire = const Duration(days: 3),
    this.enabledCacheSize,
  }) {
    if (enabledCacheSize == true) {
      try {
        _cacheSize = ElImageStorage.storage.getItem(url, serialize: const ElSizeSerialize());
      } catch (error) {
        ElLog.e(error);
        ElImageStorage.storage.removeItem(url);
        ElImageStorage.removeCacheFile(url);
        _cacheSize = null;
      }
    }
  }

  /// 加载网络图片地址
  final String url;

  /// 设置图片缩放
  final double scale;

  /// 设置图片请求头
  final Map<String, String>? headers;

  /// 这个属性仅作用于 Web 平台，用来决定选择哪种方式渲染图片：
  /// 1. never - 仅通过字节加载图片，此方式容易遇到 CORS 跨域问题
  /// 2. fallback - 优先通过字节加载，抓取字节不可用时退回到 HTML 元素
  /// 3. prefer - 使用 HTML 标签加载图片，若加载的图片出现 CORS 跨域问题，可以指定该选项
  final WebHtmlElementStrategy webHtmlElementStrategy;

  /// 设置本地缓存过期时间
  final Duration expire;

  /// 是否将图片尺寸信息缓存到本地
  final bool? enabledCacheSize;

  /// 访问图片缓存尺寸
  Size? get cacheSize => _cacheSize;
  Size? _cacheSize;

  /// 清除图片缓存
  static Future<void> clearCache() async {
    ElImageStorage.storage.clear();

    if (!kIsWeb) {
      final imageDirectory = Directory(ElImageStorage.cachePath);
      if (imageDirectory.existsSync()) {
        imageDirectory.deleteSync(recursive: true);
      }
      Directory(ElImageStorage.cachePath).createSync();
    }
  }

  /// 构建自适应平台的 [ImageProvider] 对象，由于 Web 平台存在 CORS 问题，
  /// 所以在 Web 端返回 [NetworkImage] 对象，在客户端则返回 [_CacheImage] 对象
  ImageProvider build() {
    late ImageProvider imageProvider;

    if (kIsWeb) {
      imageProvider = NetworkImage(url, scale: scale, headers: headers, webHtmlElementStrategy: webHtmlElementStrategy);
    } else {
      imageProvider = _CacheImage(this);
    }

    if (ElImageStorage.storage.checkExpire(url)) {}
    // 将解析好的图片尺寸缓存到本地
    if (enabledCacheSize == true && cacheSize == null) {
      imageProvider.getImageInfo().then((imageInfo) {
        if (imageInfo != null) {
          setImageCache(Size(imageInfo.image.width.toDouble(), imageInfo.image.height.toDouble()));
        }
      });
    } else {
      setImageCache();
    }

    return imageProvider;
  }

  void setImageCache([Size? size]) {
    ElImageStorage.storage.setItem(url, size, serialize: const ElSizeSerialize(), expire: expire);
  }
}

class _CacheImage extends ImageProvider<_CacheImage> {
  _CacheImage(this.cacheImage);

  final ElCacheImage cacheImage;

  @override
  Future<_CacheImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<_CacheImage>(this);
  }

  @override
  @protected
  ImageStreamCompleter loadImage(_CacheImage key, ImageDecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode: decode),
      scale: cacheImage.scale,
      debugLabel: cacheImage.url,
      informationCollector: () => <DiagnosticsNode>[
        DiagnosticsProperty<ImageProvider>('Image provider', this),
        DiagnosticsProperty<_CacheImage>('Image key', key),
      ],
    );
  }

  Future<ui.Codec> _loadAsync(
    _CacheImage key, {
    required Future<ui.Codec> Function(ui.ImmutableBuffer buffer) decode,
  }) async {
    assert(key == this);

    final file = ElImageStorage.getCacheFile(cacheImage.url);

    if (file.existsSync()) {
      try {
        return decode(await ui.ImmutableBuffer.fromUint8List(file.readAsBytesSync()));
      } catch (error) {
        // 不检查文件系统上是否存在缓存图片，无论何种原因加载失败，都将从网络请求继续加载
      }
    }

    try {
      final Uri resolved = Uri.base.resolve(cacheImage.url);

      // 使用 dio 访问图片资源，将其解析为字节码
      final res = await ElHttp.instance.dio.getUri(
        resolved,
        options: Options(
          responseType: ResponseType.bytes,
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      final bytes = res.data as Uint8List;

      if (bytes.lengthInBytes == 0) {
        throw Exception('_CacheImage is an empty file: $resolved');
      }

      file.writeAsBytesSync(bytes);

      return decode(await ui.ImmutableBuffer.fromUint8List(bytes));
    } catch (error) {
      ElLog.e(error, title: '_CacheImage Error');
      scheduleMicrotask(() {
        PaintingBinding.instance.imageCache.evict(key);
      });
      rethrow;
    }
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is _CacheImage && other.cacheImage.url == cacheImage.url && other.cacheImage.scale == cacheImage.scale;
  }

  @override
  int get hashCode => Object.hash(cacheImage.url, cacheImage.scale);

  @override
  String toString() =>
      '${objectRuntimeType(this, '_CacheImage')}("${cacheImage.url}", '
      'scale: ${cacheImage.scale.toStringAsFixed(1)})';
}
