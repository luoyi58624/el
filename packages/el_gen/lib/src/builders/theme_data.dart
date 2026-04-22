import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:el_dart/ext.dart';

import 'package:source_gen/source_gen.dart';

import '../config.dart';
import '../utils.dart';

/// 当前实体类的信息
late ClassElement _classInfo;

/// 当前实体类的类名
late String _className;

/// 当前实体类的字段列表
late List<FieldElement> _classFields;

@immutable
class ElThemeGenerator extends GeneratorForAnnotation<ElThemeGenerator> {
  /// 过滤前缀和后缀，获取单纯的组件名字，例如：
  /// * ElButtonThemeData -> Button
  /// * ElLinkThemeData -> Link
  static String getRawName(String className) {
    String rawName = className;
    if (rawName.startsWith(ThemeDataTemplateConfig.instance.prefix)) {
      rawName = rawName.substring(ThemeDataTemplateConfig.instance.prefix.length);
    }
    if (rawName.endsWith(ThemeDataTemplateConfig.instance.suffix)) {
      rawName = rawName.substring(0, rawName.lastIndexOf(ThemeDataTemplateConfig.instance.suffix));
    }
    if (rawName.endsWith('Theme')) {
      rawName = rawName.substring(0, rawName.lastIndexOf('Theme'));
    }
    return rawName;
  }

  @override
  generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {
    _classInfo = element as ClassElement;
    _className = _classInfo.name!;
    _classFields = MirrorUtils.filterFields(_classInfo);

    String result =
        """
        ${generateThemeWidget(annotation)}
        ${generateAnimatedWidget(annotation)}
    """;
    return result;
  }

  String generateThemeWidget(ConstantReader annotation) {
    bool generateThemeWidget = annotation.read('generateThemeWidget').boolValue;
    if (!generateThemeWidget) return '';

    assert(
      _className.startsWith(ThemeDataTemplateConfig.instance.prefix),
      '生成 ThemeWidget 的模型类必须以 ${ThemeDataTemplateConfig.instance.prefix} 开始',
    );
    assert(
      _className.endsWith(ThemeDataTemplateConfig.instance.suffix),
      '生成 ThemeWidget 的模型类必须以 ${ThemeDataTemplateConfig.instance.suffix} 结尾',
    );
    String themeClassName = _className.substring(0, _className.lastIndexOf(ThemeDataTemplateConfig.instance.suffix));

    String ofContent =
        """
static $_className of(BuildContext context) =>
  maybeOf(context) ?? (ElBrightness.isDark(context) ? $_className.darkTheme : $_className.theme);""";

    return """
class $themeClassName extends StatelessWidget {
  /// 提供局部默认主题小部件，局部默认主题必须强制继承祖先提供的样式
  const $themeClassName({
    super.key,
    required this.child,
    required this.data,
  });

  final Widget child;
  final $_className data;

  /// 通过上下文访问默认的主题数据，可能为 null
  static $_className? maybeOf(BuildContext context) =>
     context.dependOnInheritedWidgetOfExactType<_$themeClassName>()?.data;
     
  $ofContent

  @override
  Widget build(BuildContext context) {
    final parent = $themeClassName.of(context);
    return _$themeClassName(
      data: parent.merge(data),
      child: child,
    );
  }
}

class _$themeClassName extends InheritedWidget {
  const _$themeClassName({
    required super.child,
    required this.data,
  });

  final $_className data;
  
  @override
  bool updateShouldNotify(_$themeClassName oldWidget) => data != oldWidget.data;
}    
    """;
  }

  String generateAnimatedWidget(ConstantReader annotation) {
    bool generateThemeWidget = annotation.read('generateThemeWidget').boolValue;
    if (!generateThemeWidget) return '';
    bool generateAnimatedThemeWidget = annotation.read('generateAnimatedThemeWidget').boolValue;
    if (!generateAnimatedThemeWidget) return '';

    String themeClassName = _className.substring(0, _className.lastIndexOf(ThemeDataTemplateConfig.instance.suffix));
    String animatedThemeClassName =
        '${ThemeDataTemplateConfig.instance.prefix}Animated${themeClassName.substring(ThemeDataTemplateConfig.instance.prefix.length)}';
    String tweenClassName = '${ThemeDataTemplateConfig.instance.prefix}${getRawName(_className)}ThemeDataTween';

    String lerpContent = '';
    for (int i = 0; i < _classFields.length; i++) {
      final fieldInfo = _classFields[i].baseElement;
      lerpContent += MirrorUtils.generateFieldLerp(fieldInfo);
    }

    return """
class $animatedThemeClassName extends StatelessWidget {
  /// 提供带有动画的局部默认主题小部件
  const $animatedThemeClassName({
    super.key,
    required this.child,
    required this.data,
    this.duration,
    this.curve = Curves.linear,
    this.onEnd,
  });

  final Widget child;
  final $_className data;
  final Duration? duration;
  final Curve curve;
  final VoidCallback? onEnd;

  @override
  Widget build(BuildContext context) {
    return _$animatedThemeClassName(
      duration: el.globalAnimation(duration),
      curve: curve,
      onEnd: onEnd,
      data: data,
      child: child,
    );
  }
}  
    
class _$animatedThemeClassName extends ImplicitlyAnimatedWidget {
  const _$animatedThemeClassName({
    required this.data,
    required super.duration,
    super.curve,
    super.onEnd,
    required this.child,
  });

  final $_className data;
  final Widget child;

  @override
  AnimatedWidgetBaseState<_$animatedThemeClassName> createState() =>
      _${_className}State();
}

class _${_className}State extends AnimatedWidgetBaseState<_$animatedThemeClassName> {
  $tweenClassName? _data;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _data = visitor(_data, widget.data,
            (dynamic value) => $tweenClassName(begin: value as $_className))!
        as $tweenClassName;
  }

  @override
  Widget build(BuildContext context) {
    return $themeClassName(
      data: _data!.evaluate(animation),
      child: widget.child,
    );
  }
}

/// 生成的主题线性插值类
class $tweenClassName extends Tween<$_className> {
  $tweenClassName({super.begin});

  @override
  $_className lerp(double t) => _lerp(begin!, end!, t);
  
  static $_className _lerp($_className a, $_className b, double t) {
    if (identical(a, b)) {
      return a;
    }

    return $_className(
        $lerpContent
    );
  }
}
    """;
  }
}
