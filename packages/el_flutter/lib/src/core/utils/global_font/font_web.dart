import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:el_dart/el_dart.dart';
import 'global_font.dart';

/// 加载字体 - web环境
Future<ByteData?> generalLoadNetworkFont(String fontUrl, {FontModel? fontModel, String? localKey}) async {
  assert(fontUrl.startsWith('http'), '字体文件地址必须是网络地址');
  try {
    var res = await http.get(Uri.parse(fontUrl));
    return ByteData.view(res.bodyBytes.buffer);
  } catch (error) {
    ElLog.e(error, title: '请求字体失败');
    return null;
  }
}
