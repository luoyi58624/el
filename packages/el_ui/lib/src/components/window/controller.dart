part of 'index.dart';

/// 窗口控制器
class ElWindowController extends ChangeNotifier {
  late BuildContext context;
  late _WindowRender _renderObject;

  /// 窗口集合
  /// * key -> 窗口 id，默认 uuid
  /// * value -> 窗口模型对象
  final Map<String, ElWindowModel> windows = {};

  /// 窗口组集合，[windowsGroup] 与 [windows] 中的窗口在页面上没有本质的区分，它更多是一种规范，
  /// 例如：你可能希望创建多个相同类型的窗口，那么你应当将它们划分到窗口组中。
  final Map<String, Map<String, ElWindowModel>> groupWindows = {};

  /// 固定在顶部的窗口集合
  final Map<String, ElWindowModel> fixedTopWindows = {};

  /// 当前最大的 index 权重
  int maxIndex = -1;

  /// 获取被最小化的窗口集合
  Map<String, ElWindowModel> get minimizeWindows => windows.filter((k, v) => v.index < 0);

  /// 创建一个窗口
  /// * groupKey - 窗口分组 key
  /// * id - 自定义窗口 id，默认通过 uuid 生成唯一字符串
  String createWindow(ElWindowModel model, {String? groupKey, String? id}) {
    id ??= ElCryptoUtil.uuidStr;
    maxIndex++;
    model.index = maxIndex;
    model.id = id;
    model.controller = this;
    if (groupKey == null) {
      windows[id] = model;
      model.groupKey = null;
    } else {
      if (groupWindows.containsKey(groupKey) == false) {
        groupWindows[groupKey] = {};
      }
      groupWindows[groupKey]![id] = model;
      model.groupKey = groupKey;
    }
    notifyListeners();
    return id;
  }

  /// 移除窗口
  void removeWindow({String? groupKey, String? id}) {
    bool needNotify = false;
    if (groupKey == null) {
      if (id != null) {
        windows.remove(id);
        needNotify = true;
      }
    } else {
      if (groupWindows.containsKey(groupKey)) {
        if (id == null) {
          groupWindows.remove(groupKey);
        } else {
          groupWindows[groupKey]!.remove(id);
          if (groupWindows[groupKey]!.values.isEmpty) {
            groupWindows.remove(groupKey);
          }
        }
        needNotify = true;
      }
    }
    if (needNotify) notifyListeners();
  }

  /// 将窗口最大化
  void maximize(String id, [String? groupKey]) {
    getWindow(id, groupKey);
  }

  /// 将窗口最小化
  void minimize(String id, [String? groupKey]) {
    getWindow(id, groupKey);
  }

  /// 将窗口移至顶部
  void moveTop(String id, [String? groupKey]) {
    final model = getWindow(id, groupKey);
    if (model.index < maxIndex) {
      maxIndex++;
      model.index = maxIndex;
      _renderObject.needSort = true;
      _renderObject.markNeedsLayout();
    }
  }

  /// 将窗口组中的某个窗口移至顶部
  void moveTopForGroup(String groupKey, [int index = 0]) {
    assert(groupWindows.containsKey(groupKey), '没有找到 groupKey = $groupKey 的窗口组');
    final modelList = groupWindows[groupKey]!.values.toList();
    assert(
      0 <= index && index < modelList.length,
      'moveTopForGroup index 索引超出范围，窗口组长度为 ${modelList.length}，index 索引为 $index',
    );
    final model = modelList[index];
    if (model.index < maxIndex) {
      maxIndex++;
      model.index = maxIndex;
      _renderObject.needSort = true;
      _renderObject.markNeedsLayout();
    }
  }

  /// 将窗口固定在顶部
  void fixedTop(String id, {String? groupKey}) {}

  /// 通过 id 获取窗口模型对象
  ElWindowModel getWindow(String id, [String? groupKey]) {
    if (groupKey == null) {
      assert(windows[id] != null, '没有找到 id = $id 的窗口对象');
      return windows[id]!;
    } else {
      assert(groupWindows.containsKey(groupKey), '没有找到 groupKey = $groupKey 的窗口组');
      assert(groupWindows[groupKey]![id] != null, '没有找到 groupKey = $groupKey && id = $id 的窗口对象');
      return groupWindows[groupKey]![id]!;
    }
  }
}
