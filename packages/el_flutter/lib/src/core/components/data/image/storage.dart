part of 'index.dart';

class ElImageStorage {
  ElImageStorage._();

  static const storageName = 'el_image';
  static const dirName = 'el_images';

  static ElStorage? _storage;

  static ElStorage get storage {
    if (_storage == null) {
      _storage = ElStorage.createStorage(storageName);
      final expireKeys = _storage!.clearExpire();

      if (!kIsWeb) {
        final imageDirectory = Directory(cachePath);

        imageDirectory.exists().then((isExists) {
          if (isExists != true) {
            try {
              imageDirectory.createSync();
            } catch (e) {
              try {
                File(imageDirectory.path).deleteSync();
                imageDirectory.createSync();
              } catch (e) {
                ElLog.e(e);
              }
            }
          }
        });

        for (final key in expireKeys) {
          removeCacheFile(key);
        }
      }
    }
    return _storage!;
  }

  /// 图片缓存目录
  static String get cachePath {
    assert(kIsWeb == false);
    return p.join(ElStorage.storagePath, dirName);
  }

  static File getCacheFile(String key) {
    return File(p.join(cachePath, ElCryptoUtil.toMd5(key)));
  }

  /// 删除本地缓存的图片文件，如果删除失败，则返回 false
  static bool removeCacheFile(String key) {
    if (kIsWeb) return true;
    try {
      final cache = getCacheFile(key);
      if (cache.existsSync()) cache.deleteSync();
      return true;
    } catch (error) {
      ElLog.e(error, title: 'ElImage 图片删除失败，目标为：$key');

      return false;
    }
  }
}
