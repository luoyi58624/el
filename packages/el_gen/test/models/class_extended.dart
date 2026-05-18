import 'package:el_dart/el_dart.dart';

part '../generates/models/class_extended.g.dart';

// ========================================================================
// 测试继承实体类的代码生成
// ========================================================================

@ElModelGenerator.copy(generateProps: false)
class RootModel {
  final String? rootName;

  const RootModel({this.rootName});
}

@ElModelGenerator.copy(generateProps: true)
class ParentModel extends RootModel with EquatableMixin {
  final String? parentName;

  const ParentModel({this.parentName, super.rootName});

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => _props;
}

@ElModelGenerator.copy()
class ChildModel extends ParentModel {
  final String childName;

  /// 如果指定父级字段，那么生成的代码将会携带父级字段
  ChildModel({required this.childName, super.parentName, super.rootName});

  @override
  List<Object?> get props => [...super.props, _props];
}

@ElModelGenerator.copy(generateProps: false)
class ChildModel2 extends ParentModel {
  final String? childName;

  /// 如果不指定父级字段，那么生成的代码也不会包含父级字段
  const ChildModel2({this.childName});

  @override
  List<Object?> get props => [...super.props, _props];
}
