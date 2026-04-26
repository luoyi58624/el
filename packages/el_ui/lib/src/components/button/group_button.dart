part of 'index.dart';

const _buttonTypeAssert = 'ElButtonGroup 不支持 link、icon 按钮类型，请指定其他 buttonType!';

class ElButtonGroup extends ElButton implements ElModelValue {
  /// 普通按钮组
  const ElButtonGroup({
    super.key,
    required this.children,
    super.buttonType = ElButtonType.basic,
    super.type,
    super.color,
    super.width,
    super.height,
    super.padding,
    super.margin,
    super.textStyle,
    super.iconThemeData,
    super.borderRadius,
    super.round,
    super.block,
    this.divided,
    this.axis = Axis.horizontal,
  }) : _modelType = null,
       mandatory = null,
       modelValue = null,
       onChanged = null,
       assert(buttonType != ElButtonType.link && buttonType != ElButtonType.icon, _buttonTypeAssert),
       super(child: null, onPressed: null);

  /// 单选按钮组
  const ElButtonGroup.single(
    this.modelValue, {
    super.key,
    required this.children,
    super.buttonType = ElButtonType.basic,
    super.type,
    super.color,
    super.width,
    super.height,
    super.padding,
    super.margin,
    super.textStyle,
    super.iconThemeData,
    super.borderRadius,
    super.round,
    super.block,
    this.mandatory,
    this.divided,
    this.axis = Axis.horizontal,
    this.onChanged,
  }) : _modelType = ElModelValueType.single,
       assert(buttonType != ElButtonType.link && buttonType != ElButtonType.icon, _buttonTypeAssert),
       super(child: null, onPressed: null);

  /// 多选按钮组
  const ElButtonGroup.multi(
    this.modelValue, {
    super.key,
    required this.children,
    super.buttonType = ElButtonType.basic,
    super.type,
    super.color,
    super.width,
    super.height,
    super.padding,
    super.margin,
    super.textStyle,
    super.iconThemeData,
    super.borderRadius,
    super.round,
    super.block,
    this.mandatory,
    this.divided,
    this.axis = Axis.horizontal,
    this.onChanged,
  }) : _modelType = ElModelValueType.multi,
       assert(buttonType != ElButtonType.link && buttonType != ElButtonType.icon, _buttonTypeAssert),
       super(child: null, onPressed: null);

  final ElModelValueType? _modelType;

  /// 按钮组子项集合
  final List<ElButtonGroupItem> children;

  /// 是否必须选择一项
  final bool? mandatory;

  /// 是否添加分割线
  final bool? divided;

  /// 按钮组方向
  final Axis axis;

  @override
  final dynamic modelValue;

  @override
  final ValueChanged? onChanged;

  @override
  State<ElButtonGroup> createState() => _ElButtonGroupState();
}

class _ElButtonGroupState extends _ElButtonState<ElButtonGroup> with ElModelValueMixin {
  late List<Widget> children;
  Map<int, dynamic> itemValueMap = {}; // 按钮组子项列表的 index 与 value 映射，方便分割线定位激活的目标

  /// 计算激活的 value 下标集合
  List<int> get activeIndexList {
    if (modelValue is List) {
      List<int> newList = [];
      for (final value in (modelValue as List)) {
        final result = itemValueMap.getKeyByValue(value);
        if (result != null) newList.add(result);
      }
      newList.sort();
      return newList;
    } else {
      return [];
    }
  }

  bool isInit = false;
  late Widget result;
  late double borderWidth;
  late bool divided;
  late Color textColor;
  Color? bgColor;

  /// 单选、多选激活颜色
  Color get activeBgColor {
    return color ?? (bgColor != null ? bgColor!.deepen(16) : context.elDefaultColor.deepen(10, darkScale: 14));
  }

  /// 分割线颜色，此颜色也会充当边框颜色
  Color? dividedColor;

  Color get activeDividedColor {
    if (color == null) return dividedColor!;
    return color!;
  }

  bool get isHorizontal => widget.axis.isHorizontal;

  @override
  double get iconSize => widget.iconThemeData?.size ?? themeData.iconSize!;

  /// 需要绘制分割线的按钮 key 列表，当构建完成按钮组后，会在下一帧通过这些 key 计算每个分割线的位置
  List<GlobalKey> _childrenKeyList = [];

  /// 按钮组分割线的偏移位置
  final _dividePositionList = Obs<List<double>>([]);

  /// 设置分割线的 key
  void _setChildrenKeyList(int length) {
    if (length <= 1) {
      _childrenKeyList.clear();
    } else {
      _childrenKeyList = List.generate(widget.children.length - 1, (i) => GlobalKey()).toList();
    }
  }

  /// 更新分割线的位置
  void _updateDivideOffset() {
    nextTick(() {
      List<double> $list = [];
      for (int i = 0; i < _childrenKeyList.length; i++) {
        final offset = ElFlutterUtil.getPosition(_childrenKeyList[i].currentContext!, context);
        $list.add(widget.axis == Axis.horizontal ? offset.dx : offset.dy);
      }
      if (_dividePositionList.value.eq($list) == false) {
        _dividePositionList.value = $list;
      }
    });
  }

  /// 计算按钮组选中逻辑
  void onChanged(dynamic value) {
    switch (widget._modelType) {
      case null:
        return;
      case ElModelValueType.single:
        if (modelValue == value && widget.mandatory != true) {
          modelValue = null;
        } else {
          modelValue = value;
        }
        return;
      case ElModelValueType.multi:
        assert(modelValue is List || modelValue is Set, 'ElButtonGroup.multi 数据类型必须为 List、Set 集合！');
        dynamic list;
        if (modelValue is List) {
          list = List.from(modelValue);
        } else {
          list = Set.from(modelValue);
        }

        if (list.contains(value)) {
          if (list.length == 1) {
            if (widget.mandatory != true) {
              list.clear();
            }
          } else {
            list.remove(value);
          }
        } else {
          list.add(value);
        }

        modelValue = list;
    }
  }

  void setDivided() {
    divided = widget.divided ?? false;
    if (widget.buttonType == ElButtonType.outline) divided = true;
  }

  @override
  void initState() {
    super.initState();
    setDivided();
    _setChildrenKeyList(widget.children.length);
    nextTick(() {
      setState(() {
        isInit = true;
      });
    });
  }

  @override
  void didUpdateWidget(ElButtonGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.divided != oldWidget.divided || widget.buttonType != oldWidget.buttonType) {
      setDivided();
    }
    if (widget.children.length != oldWidget.children.length) {
      _setChildrenKeyList(widget.children.length);
    }
  }

  @override
  Widget obsBuild(BuildContext context) {
    return _ElButtonGroupInheritedWidget(
      this,
      child: Stack(
        children: [
          result,
          if (dividedColor != null)
            ..._childrenKeyList.mapIndexed(
              (i, e) => _GroupDivide(
                length: children.length,
                index: i,
                hasSelected: modelValue is List ? (modelValue as List).isNotEmpty : modelValue != null,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    themeData = ElButtonTheme.of(context);
    textScaler = MediaQuery.textScalerOf(context);
    textDirection = Directionality.of(context);

    borderWidth = el.config.borderWidth;
    children = widget.children.mapIndexed((i, e) {
      itemValueMap[i] = e.value ?? i;
      return ElChildIndex(index: i, child: e);
    }).toList();

    if (children.length > 1 && divided) {
      children = [
        children.first,
        ...children.sublist(1).mapIndexed((i, e) {
          return Builder(key: _childrenKeyList[i], builder: (context) => e);
        }),
      ];
      _updateDivideOffset();
    }

    result = isHorizontal ? Row(children: children) : IntrinsicWidth(child: Column(children: children));

    switch (widget.buttonType) {
      case ElButtonType.basic:
      case ElButtonType.flat:
        bgColor = _BasicButton.buildBgColor(context, widget._modelType == null ? color : null);
        textColor = bgColor!.elRegularTextColor(context);
        if (divided) {
          dividedColor = textColor.isDark ? Colors.black12 : Colors.white54;
        }

        result = ElAnimatedMaterial(
          elevation: widget.buttonType == ElButtonType.flat ? 0 : 2,
          borderRadius: borderRadius,
          child: result,
        );
        break;
      case ElButtonType.outline:
      case ElButtonType.text:
        textColor = _OutlineButton.buildTextColor(context, widget._modelType == null ? color : null);
        if (divided) {
          dividedColor = textColor;
        }
        break;
      case ElButtonType.link:
      case ElButtonType.icon:
        throw _buttonTypeAssert;
    }

    if (widget.block != true) result = UnconstrainedBox(child: result);

    return Opacity(opacity: isInit ? 1 : 0, child: super.build(context));
  }
}

class _ElButtonGroupInheritedWidget extends InheritedWidget {
  const _ElButtonGroupInheritedWidget(this.state, {required super.child});

  final _ElButtonGroupState state;

  static _ElButtonGroupState of(BuildContext context) {
    final _ElButtonGroupInheritedWidget? result = context
        .dependOnInheritedWidgetOfExactType<_ElButtonGroupInheritedWidget>();
    assert(result != null, 'ElButtonGroupItem 不能单独使用，它必须作为 ElButtonGroup 子项');
    return result!.state;
  }

  @override
  bool updateShouldNotify(_ElButtonGroupInheritedWidget oldWidget) {
    return true;
  }
}

/// 按钮组分割线
class _GroupDivide extends StatelessWidget {
  const _GroupDivide({required this.length, required this.index, required this.hasSelected});

  /// 按钮组的按钮数量
  final int length;

  /// 当前分割线的索引位置
  final int index;

  /// 存在选中的按钮
  final bool hasSelected;

  /// 将指定的索引与当前索引进行匹配
  bool matchIndex(_ElButtonGroupState state, dynamic target) {
    final activeIndex = state.itemValueMap.getKeyByValue(target);
    if (activeIndex == null) return false;
    if (length == 2) {
      if (activeIndex != -1) return true;
    } else if (length > 2) {
      if (activeIndex == 0) {
        if (index == activeIndex) return true;
      } else if (activeIndex == length - 1) {
        if (index == activeIndex - 1) return true;
      } else if (activeIndex != -1) {
        if (index == activeIndex - 1 || index == activeIndex) {
          return true;
        }
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final state = _ElButtonGroupInheritedWidget.of(context);

    return ObsBuilder(
      builder: (context) {
        final $dividePositionList = state._dividePositionList.value;
        if ($dividePositionList.length != length - 1) return const SizedBox();

        double $borderSize = state.borderWidth;
        Color $borderColor = state.dividedColor!;
        final $modelValue = state.modelValue;

        // 判断多选主题类型按钮组 selected 是否相邻，需要在中间绘制比较显眼的分割线
        bool isUnionBorder = false;

        if (hasSelected) {
          if (state.widget._modelType == ElModelValueType.single) {
            if (matchIndex(state, $modelValue)) {
              $borderColor = state.activeDividedColor;
            }
          } else {
            for (final activeIndex in state.activeIndexList) {
              if (activeIndex == index) {
                if ($modelValue.contains(state.itemValueMap[activeIndex + 1])) {
                  isUnionBorder = true;
                }
                break;
              }
            }
            for (final target in $modelValue) {
              if (matchIndex(state, target)) {
                $borderColor = state.activeDividedColor;
                break;
              }
            }

            if (isUnionBorder) {
              if ((state.widget.buttonType == ElButtonType.outline && state.color == null) == false) {
                $borderColor = state.activeDividedColor.mix(
                  (state.bgColor ?? context.elDefaultColor).isDark ? Colors.black : Colors.white,
                  50,
                );
              }
            }
          }
        }

        return Positioned.directional(
          textDirection: Directionality.of(context),
          start: state.isHorizontal ? $dividePositionList[index] - $borderSize / 2 : 0,
          end: !state.isHorizontal ? 0 : null,
          top: !state.isHorizontal ? $dividePositionList[index] - $borderSize / 2 : 0,
          bottom: state.isHorizontal ? 0 : null,
          child: IgnorePointer(
            child: ElAnimatedColoredBox(
              color: $borderColor,
              child: SizedBox(
                width: state.isHorizontal ? $borderSize : null,
                height: state.isHorizontal ? null : $borderSize,
              ),
            ),
          ),
        );
      },
    );
  }
}

class ElButtonGroupItem extends StatelessWidget {
  const ElButtonGroupItem({super.key, this.child, this.value, this.flex, this.onPressed});

  final dynamic child;

  /// 自定义激活目标值
  final Object? value;

  /// 当按钮组启用 block 属性时，你可以指定此按钮占据的空间
  final int? flex;

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    _ElButtonGroupState state = _ElButtonGroupInheritedWidget.of(context);
    ElChildIndex indexData = ElChildIndex.of(context);
    final isLtr = Directionality.of(context) == TextDirection.ltr;
    int length = state.widget.children.length;
    bool isRow = state.widget.axis == Axis.horizontal;
    final $value = value ?? indexData.index;
    late _InkWellColors colors;
    Border? border;
    var borderRadius = state.borderRadius;

    late bool isSelected;
    switch (state.widget._modelType) {
      case null:
        isSelected = false;
      case ElModelValueType.single:
        isSelected = state.modelValue == $value;
      case ElModelValueType.multi:
        isSelected = (state.modelValue as List).contains($value);
    }

    Color? bgColor;
    Color textColor;

    final $child = state.buildChild(child);

    if (length > 1) {
      if (indexData.index == 0) {
        borderRadius = BorderRadius.only(
          topLeft: isRow
              ? isLtr
                    ? borderRadius.topLeft
                    : .zero
              : borderRadius.topLeft,
          bottomLeft: isRow
              ? isLtr
                    ? borderRadius.bottomLeft
                    : .zero
              : .zero,
          topRight: isRow
              ? isLtr
                    ? .zero
                    : borderRadius.topRight
              : borderRadius.topRight,
          bottomRight: isRow
              ? isLtr
                    ? .zero
                    : borderRadius.bottomRight
              : .zero,
        );
      } else if (indexData.index == length - 1) {
        borderRadius = BorderRadius.only(
          topLeft: isRow
              ? isLtr
                    ? .zero
                    : borderRadius.topLeft
              : .zero,
          bottomLeft: isRow
              ? isLtr
                    ? .zero
                    : borderRadius.bottomLeft
              : borderRadius.bottomLeft,
          topRight: isRow
              ? isLtr
                    ? borderRadius.topRight
                    : .zero
              : .zero,
          bottomRight: isRow
              ? isLtr
                    ? borderRadius.bottomRight
                    : .zero
              : borderRadius.bottomRight,
        );
      } else {
        borderRadius = BorderRadius.zero;
      }
    }

    switch (state.widget.buttonType) {
      case ElButtonType.basic:
      case ElButtonType.flat:
        colors = _BasicButton.buildInkWellColors(context, state.bgColor!);
        bgColor = isSelected ? state.activeBgColor : state.bgColor;
        textColor = isSelected ? bgColor!.elRegularTextColor(context) : state.textColor;
        break;
      case ElButtonType.outline:
        colors = _OutlineButton.buildInkWellColors(context, state.textColor);
        bgColor = isSelected ? state.activeBgColor : context.elDefaultColor;
        textColor = isSelected ? bgColor.elRegularTextColor(context) : state.textColor;
        final borderColor = isSelected ? state.activeDividedColor : state.dividedColor!;
        if (length > 1) {
          final borderSide = BorderSide(width: state.borderWidth, color: borderColor);
          if (indexData.index == 0) {
            border = Border(
              left: borderSide,
              right: !isRow || state.children.length == 2 ? borderSide : .none,
              top: borderSide,
              bottom: isRow ? borderSide : .none,
            );
          } else if (indexData.index == length - 1) {
            border = Border(
              left: !isRow ? borderSide : .none,
              right: borderSide,
              top: isRow ? borderSide : .none,
              bottom: borderSide,
            );
          } else {
            border = Border(
              left: !isRow ? borderSide : .none,
              right: !isRow ? borderSide : .none,
              top: isRow ? borderSide : .none,
              bottom: isRow ? borderSide : .none,
            );
          }
        } else {
          border = Border.all(width: state.borderWidth, color: borderColor);
        }
        break;
      case ElButtonType.text:
        colors = _TextButton.buildInkWellColors(context, state.textColor);
        bgColor = isSelected ? state.activeBgColor : state.bgColor;
        textColor = isSelected ? bgColor!.elRegularTextColor(context) : state.textColor;
        break;
      case ElButtonType.link:
      case ElButtonType.icon:
        throw _buttonTypeAssert;
    }
    final globalAnimation = el.globalAnimation();

    Widget result = state.buildBox(
      context,
      AnimatedDefaultTextStyle(
        duration: globalAnimation.$1,
        curve: globalAnimation.$2,
        style: state.buildTextStyle(textColor),
        child: ElAnimatedIconTheme(
          data: state.buildIconData(textColor),
          child: Center(child: $child),
        ),
      ),
    );

    if (border != null) {
      result = ElAnimatedDecoratedBox(
        decoration: BoxDecoration(borderRadius: borderRadius, border: border),
        child: result,
      );
    }

    Color? hoverHover = colors.$1;
    if (state.widget._modelType != null) {
      if (state.widget.buttonType != ElButtonType.basic && state.widget.buttonType != ElButtonType.flat) {
        if (state.widget.buttonType == ElButtonType.outline) {
          hoverHover = Colors.transparent;
        } else {
          hoverHover = ElBrightness.isDark(context) ? Colors.white.elOpacity(0.05) : Colors.black.elOpacity(0.05);
        }
      }
    }

    result = state.buildInkWell(
      onPressed: () {
        state.onChanged($value);
        onPressed?.call();
      },
      hoverColor: hoverHover,
      highlightColor: colors.$2,
      splashColor: colors.$3,
      borderRadius: borderRadius,
      child: ElAnimatedInk(
        decoration: BoxDecoration(borderRadius: borderRadius, color: bgColor),
        child: result,
      ),
    );

    if (state.widget.block == true) {
      result = Expanded(flex: flex ?? 1, child: result);
    }

    return result;
  }
}
