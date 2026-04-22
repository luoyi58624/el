// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../models/class_extended.dart';

// **************************************************************************
// ElModelGenerator
// **************************************************************************

extension RootModelExt on RootModel {
  RootModel copyWith({String? rootName}) {
    return RootModel(rootName: rootName ?? this.rootName);
  }

  RootModel merge([RootModel? other]) {
    if (other == null) return this;
    return copyWith(rootName: other.rootName);
  }
}

extension ParentModelExt on ParentModel {
  ParentModel copyWith({String? parentName, String? rootName}) {
    return ParentModel(parentName: parentName ?? this.parentName, rootName: rootName ?? this.rootName);
  }

  ParentModel merge([ParentModel? other]) {
    if (other == null) return this;
    return copyWith(parentName: other.parentName, rootName: other.rootName);
  }

  List<Object?> get _props => [parentName];
}

extension ChildModelExt on ChildModel {
  ChildModel copyWith({String? childName, String? parentName, String? rootName}) {
    return ChildModel(
      childName: childName ?? this.childName,
      parentName: parentName ?? this.parentName,
      rootName: rootName ?? this.rootName,
    );
  }

  ChildModel merge([ChildModel? other]) {
    if (other == null) return this;
    return copyWith(childName: other.childName, parentName: other.parentName, rootName: other.rootName);
  }

  List<Object?> get _props => [childName];
}

extension ChildModel2Ext on ChildModel2 {
  ChildModel2 copyWith({String? childName}) {
    return ChildModel2(childName: childName ?? this.childName);
  }

  ChildModel2 merge([ChildModel2? other]) {
    if (other == null) return this;
    return copyWith(childName: other.childName);
  }
}
