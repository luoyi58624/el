import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:el_dart/ext.dart';

import 'package:source_gen/source_gen.dart';

import '../config.dart';
import '../utils.dart';

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
    final classInfo = element as ClassElement;
    final className = classInfo.name!;
    final classFields = MirrorUtils.filterFields(classInfo);

    return '''
${_generateThemeWidget(classInfo, className, classFields, annotation)}
${_generateAnimatedWidget(classInfo, className, classFields, annotation)}
''';
  }

  String _generateThemeWidget(ClassElement classInfo, String className, List<FieldElement> classFields,
      ConstantReader annotation) {
    if (!annotation.read('generateThemeWidget').boolValue) return '';

    assert(
      className.startsWith(ThemeDataTemplateConfig.instance.prefix),
      '生成 ThemeWidget 的模型类必须以 ${ThemeDataTemplateConfig.instance.prefix} 开始',
    );
    assert(
      className.endsWith(ThemeDataTemplateConfig.instance.suffix),
      '生成 ThemeWidget 的模型类必须以 ${ThemeDataTemplateConfig.instance.suffix} 结尾',
    );
    final themeClassName = className.substring(0, className.lastIndexOf(ThemeDataTemplateConfig.instance.suffix));

    return '''
class $themeClassName extends StatelessWidget {
  const $themeClassName({
    super.key,
    required this.child,
    required this.data,
  });

  final Widget child;
  final $className data;

  static $className? maybeOf(BuildContext context) =>
     context.dependOnInheritedWidgetOfExactType<_$themeClassName>()?.data;

  static $className of(BuildContext context) =>
    maybeOf(context) ?? (ElBrightness.isDark(context) ? $className.darkTheme : $className.theme);

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

  final $className data;

  @override
  bool updateShouldNotify(_$themeClassName oldWidget) => data != oldWidget.data;
}
''';
  }

  String _generateAnimatedWidget(ClassElement classInfo, String className, List<FieldElement> classFields,
      ConstantReader annotation) {
    if (!annotation.read('generateThemeWidget').boolValue) return '';
    if (!annotation.read('generateAnimatedThemeWidget').boolValue) return '';

    final themeClassName = className.substring(0, className.lastIndexOf(ThemeDataTemplateConfig.instance.suffix));
    final animatedThemeClassName =
        '${ThemeDataTemplateConfig.instance.prefix}Animated${themeClassName.substring(ThemeDataTemplateConfig.instance.prefix.length)}';
    final tweenClassName = '${ThemeDataTemplateConfig.instance.prefix}${getRawName(className)}ThemeDataTween';

    final lerpContent = StringBuffer();
    for (final fieldInfo in classFields) {
      lerpContent.writeln(MirrorUtils.generateFieldLerp(fieldInfo.baseElement));
    }

    return '''
class $animatedThemeClassName extends StatelessWidget {
  const $animatedThemeClassName({
    super.key,
    required this.child,
    required this.data,
    this.duration,
    this.curve = Curves.linear,
    this.onEnd,
  });

  final Widget child;
  final $className data;
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

  final $className data;
  final Widget child;

  @override
  AnimatedWidgetBaseState<_$animatedThemeClassName> createState() =>
      _${className}State();
}

class _${className}State extends AnimatedWidgetBaseState<_$animatedThemeClassName> {
  $tweenClassName? _data;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _data = visitor(_data, widget.data,
            (dynamic value) => $tweenClassName(begin: value as $className))!
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
class $tweenClassName extends Tween<$className> {
  $tweenClassName({super.begin});

  @override
  $className lerp(double t) => _lerp(begin!, end!, t);

  static $className _lerp($className a, $className b, double t) {
    if (identical(a, b)) {
      return a;
    }

    return $className(
      $lerpContent
    );
  }
}
''';
  }
}
