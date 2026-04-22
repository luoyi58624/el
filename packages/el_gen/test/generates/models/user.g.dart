// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../models/user.dart';

// **************************************************************************
// ElModelGenerator
// **************************************************************************

extension UserModelExt on UserModel {
  static const UserModel defaultModel = UserModel();

  static UserModel fromJson(Map<String, dynamic>? json) {
    if (json == null) return defaultModel;
    return UserModel(
      username: ElJsonUtil.$string(json, 'username'),
      age: ElJsonUtil.$int(json, 'age'),
      count: ElJsonUtil.$int(json, 'count'),
      child: ElJsonUtil.$model<UserModel?>(json, 'child', UserModelExt.defaultModel),
      children: ElJsonUtil.$list<UserModel>(json, 'children'),
      animalMap: ElJsonUtil.$map<AnimalModel>(json, 'animalMap'),
      mapField: ElJsonUtil.$map<dynamic>(json, 'mapField'),
      startDate: ElJsonUtil.$custom<DateTime?>(json, 'startDate', const ElDateTimeSerialize()),
      endDate: ElJsonUtil.$custom<DateTime?>(json, 'endDate', const ElDateTimeSerialize()),
      childName: ElJsonUtil.$string(json, 'childName'),
    );
  }

  Map<String, dynamic> _toJson() {
    return {
      'username': username,
      'age': age,
      'count': count,
      'child': child?.toJson(),
      'children': children,
      'animalMap': animalMap,
      'mapField': mapField,
      'startDate': const ElDateTimeSerialize().serialize(startDate),
      'endDate': const ElDateTimeSerialize().serialize(endDate),
      'childName': childName,
    };
  }

  UserModel copyWith({
    String? username,
    int? age,
    int? count,
    UserModel? child,
    List<UserModel>? children,
    Map<String, AnimalModel>? animalMap,
    Map<dynamic, dynamic>? mapField,
    DateTime? startDate,
    DateTime? endDate,
    String? childName,
  }) {
    return UserModel(
      username: username ?? this.username,
      age: age ?? this.age,
      count: count ?? this.count,
      child: this.child == null ? child : this.child!.merge(child),
      children: children ?? this.children,
      animalMap: animalMap ?? this.animalMap,
      mapField: mapField ?? this.mapField,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      childName: childName ?? this.childName,
    );
  }

  UserModel merge([UserModel? other]) {
    if (other == null) return this;
    return copyWith(
      username: other.username,
      age: other.age,
      count: other.count,
      child: other.child,
      children: other.children,
      animalMap: other.animalMap,
      mapField: other.mapField,
      startDate: other.startDate,
      endDate: other.endDate,
      childName: other.childName,
    );
  }

  List<Object?> get _props => [username, age, count, child, children, animalMap, mapField, startDate, endDate];
}
