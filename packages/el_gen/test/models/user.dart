import 'animal.dart';
import 'class_extended.dart';
import 'package:el_dart/el_dart.dart';

part '../generates/models/user.g.dart';

@ElModelGenerator.all()
class UserModel extends ChildModel2 implements ElSerializeModel<UserModel> {
  final String? username;
  final int? age;
  final int? count;
  final UserModel? child;
  final List<UserModel>? children;
  final Map<String, AnimalModel>? animalMap;
  final Map? mapField;

  @ElDateTimeSerialize()
  final DateTime? startDate;

  @ElDateTimeSerialize()
  final DateTime? endDate;

  const UserModel({
    this.username,
    this.age,
    this.count,
    this.child,
    this.children,
    this.animalMap,
    this.mapField,
    this.startDate,
    this.endDate,
    super.childName,
  });

  /// fromJson 静态构造实际上没必要定义，你可以直接通过 Ext 访问
  factory UserModel.fromJson(Map<String, dynamic>? json) => UserModelExt.fromJson(json);

  @override
  UserModel fromJson(Map<String, dynamic>? json) => UserModelExt.fromJson(json);

  @override
  Map<String, dynamic> toJson() => _toJson();

  @override
  List<Object?> get props => [...super.props, _props];
}
