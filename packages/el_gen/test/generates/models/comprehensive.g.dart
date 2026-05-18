// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../models/comprehensive.dart';

// **************************************************************************
// ElModelGenerator
// **************************************************************************

extension AllFeaturesModelExt on AllFeaturesModel {
  static const AllFeaturesModel defaultModel = AllFeaturesModel(
    withJsonKey: '',
    withDefault: 42,
    nullableWithDefault: 'fallback',
    normalString: '',
    normalInt: 0,
    normalDouble: 0.0,
    normalBool: false,
    stringList: [],
    intSet: {},
    normalMap: {},
  );

  static AllFeaturesModel fromJsonAllFeaturesModel(Map<String, dynamic>? json) {
    if (json == null) return defaultModel;
    return AllFeaturesModel(
      withJsonKey: $ElJsonUtil.$string(json, 'custom_key') ?? '',
      withDefault: $ElJsonUtil.$int(json, 'withDefault') ?? 42,
      nullableWithDefault:
          $ElJsonUtil.$string(json, 'nullable_key') ?? 'fallback',
      normalString: $ElJsonUtil.$string(json, 'normalString') ?? '',
      normalInt: $ElJsonUtil.$int(json, 'normalInt') ?? 0,
      normalDouble: $ElJsonUtil.$double(json, 'normalDouble') ?? 0.0,
      normalBool: $ElJsonUtil.$bool(json, 'normalBool') ?? false,
      stringList: $ElJsonUtil.$list<String>(json, 'stringList') ?? [],
      intSet: $ElJsonUtil.$set<int>(json, 'intSet') ?? {},
      normalMap: $ElJsonUtil.$map<dynamic>(json, 'normalMap') ?? {},
    );
  }

  Map<String, dynamic> _toJson() {
    return {
      'custom_key': withJsonKey,
      'with_default': withDefault,
      'nullable_key': nullableWithDefault,
      'normal_string': normalString,
      'normal_int': normalInt,
      'normal_double': normalDouble,
      'normal_bool': normalBool,
      'string_list': stringList,
      'int_set': intSet,
      'normal_map': normalMap,
    };
  }

  AllFeaturesModel copyWith({
    String? withJsonKey,
    int? withDefault,
    String? nullableWithDefault,
    String? normalString,
    int? normalInt,
    double? normalDouble,
    bool? normalBool,
    List<String>? stringList,
    Set<int>? intSet,
    Map<String, dynamic>? normalMap,
  }) {
    return AllFeaturesModel(
      withJsonKey: withJsonKey ?? this.withJsonKey,
      withDefault: withDefault ?? this.withDefault,
      nullableWithDefault: nullableWithDefault ?? this.nullableWithDefault,
      normalString: normalString ?? this.normalString,
      normalInt: normalInt ?? this.normalInt,
      normalDouble: normalDouble ?? this.normalDouble,
      normalBool: normalBool ?? this.normalBool,
      stringList: stringList ?? this.stringList,
      intSet: intSet ?? this.intSet,
      normalMap: normalMap ?? this.normalMap,
    );
  }

  AllFeaturesModel merge([AllFeaturesModel? other]) {
    if (other == null) return this;
    return copyWith(
      withJsonKey: other.withJsonKey,
      withDefault: other.withDefault,
      nullableWithDefault: other.nullableWithDefault,
      normalString: other.normalString,
      normalInt: other.normalInt,
      normalDouble: other.normalDouble,
      normalBool: other.normalBool,
      stringList: other.stringList,
      intSet: other.intSet,
      normalMap: other.normalMap,
    );
  }

  List<Object?> get _props => [
    withJsonKey,
    withDefault,
    nullableWithDefault,
    normalString,
    normalInt,
    normalDouble,
    normalBool,
    stringList,
    intSet,
    normalMap,
  ];
}

extension JsonOnlyModelExt on JsonOnlyModel {
  static const JsonOnlyModel defaultModel = JsonOnlyModel(name: '', age: 0);

  static JsonOnlyModel fromJson(Map<String, dynamic>? json) {
    if (json == null) return defaultModel;
    return JsonOnlyModel(
      name: $ElJsonUtil.$string(json, 'name') ?? '',
      age: $ElJsonUtil.$int(json, 'age') ?? 0,
    );
  }

  Map<String, dynamic> _toJson() {
    return {'name': name, 'age': age};
  }

  List<Object?> get _props => [name, age];
}

extension CopyOnlyModelExt on CopyOnlyModel {
  CopyOnlyModel copyWith({String? name, int? age}) {
    return CopyOnlyModel(name: name ?? this.name, age: age ?? this.age);
  }

  CopyOnlyModel merge([CopyOnlyModel? other]) {
    if (other == null) return this;
    return copyWith(name: other.name, age: other.age);
  }

  List<Object?> get _props => [name, age];
}

extension MergeForcesCopyWithModelExt on MergeForcesCopyWithModel {
  static const MergeForcesCopyWithModel defaultModel = MergeForcesCopyWithModel(
    title: '',
  );

  static MergeForcesCopyWithModel fromJson(Map<String, dynamic>? json) {
    if (json == null) return defaultModel;
    return MergeForcesCopyWithModel(
      title: $ElJsonUtil.$string(json, 'title') ?? '',
    );
  }

  Map<String, dynamic> _toJson() {
    return {'title': title};
  }

  MergeForcesCopyWithModel copyWith({String? title}) {
    return MergeForcesCopyWithModel(title: title ?? this.title);
  }

  MergeForcesCopyWithModel merge([MergeForcesCopyWithModel? other]) {
    if (other == null) return this;
    return copyWith(title: other.title);
  }

  List<Object?> get _props => [title];
}

extension NoPropsModelExt on NoPropsModel {
  static const NoPropsModel defaultModel = NoPropsModel(value: '');

  static NoPropsModel fromJson(Map<String, dynamic>? json) {
    if (json == null) return defaultModel;
    return NoPropsModel(value: $ElJsonUtil.$string(json, 'value') ?? '');
  }

  Map<String, dynamic> _toJson() {
    return {'value': value};
  }

  NoPropsModel copyWith({String? value}) {
    return NoPropsModel(value: value ?? this.value);
  }

  NoPropsModel merge([NoPropsModel? other]) {
    if (other == null) return this;
    return copyWith(value: other.value);
  }
}

extension CustomSerializeModelExt on CustomSerializeModel {
  static const CustomSerializeModel defaultModel = CustomSerializeModel(
    name: '',
  );

  static CustomSerializeModel fromJson(Map<String, dynamic>? json) {
    if (json == null) return defaultModel;
    return CustomSerializeModel(
      dateField: $ElJsonUtil.$custom<DateTime?>(
        json,
        'dateField',
        const ElDateTimeSerialize(),
      ),
      durationField: $ElJsonUtil.$custom<Duration?>(
        json,
        'durationField',
        const ElDurationSerialize(),
      ),
      name: $ElJsonUtil.$string(json, 'name') ?? '',
    );
  }

  Map<String, dynamic> _toJson() {
    return {
      'dateField': const ElDateTimeSerialize().serialize(dateField),
      'durationField': const ElDurationSerialize().serialize(durationField),
      'name': name,
    };
  }

  CustomSerializeModel copyWith({
    DateTime? dateField,
    Duration? durationField,
    String? name,
  }) {
    return CustomSerializeModel(
      dateField: dateField ?? this.dateField,
      durationField: durationField ?? this.durationField,
      name: name ?? this.name,
    );
  }

  CustomSerializeModel merge([CustomSerializeModel? other]) {
    if (other == null) return this;
    return copyWith(
      dateField: other.dateField,
      durationField: other.durationField,
      name: other.name,
    );
  }

  List<Object?> get _props => [dateField, durationField, name];
}

extension MergeTargetModelExt on MergeTargetModel {
  MergeTargetModel copyWith({String? label, int? count}) {
    return MergeTargetModel(
      label: label ?? this.label,
      count: count ?? this.count,
    );
  }

  MergeTargetModel merge([MergeTargetModel? other]) {
    if (other == null) return this;
    return copyWith(label: other.label, count: other.count);
  }

  List<Object?> get _props => [label, count];
}

extension MergeHostModelExt on MergeHostModel {
  static const MergeHostModel defaultModel = MergeHostModel(
    forceMergeField: null,
    autoDetectMergeField: null,
    noMergeField: null,
    name: '',
  );

  static MergeHostModel fromJson(Map<String, dynamic>? json) {
    if (json == null) return defaultModel;
    return MergeHostModel(
      forceMergeField: json['forceMergeField'],
      autoDetectMergeField: json['autoDetectMergeField'],
      noMergeField: json['noMergeField'],
      name: $ElJsonUtil.$string(json, 'name') ?? '',
    );
  }

  Map<String, dynamic> _toJson() {
    return {
      'forceMergeField': forceMergeField,
      'autoDetectMergeField': autoDetectMergeField,
      'noMergeField': noMergeField,
      'name': name,
    };
  }

  MergeHostModel copyWith({
    MergeTargetModel? forceMergeField,
    MergeTargetModel? autoDetectMergeField,
    MergeTargetModel? noMergeField,
    String? name,
  }) {
    return MergeHostModel(
      forceMergeField: this.forceMergeField == null
          ? forceMergeField
          : this.forceMergeField!.merge(forceMergeField),
      autoDetectMergeField: this.autoDetectMergeField == null
          ? autoDetectMergeField
          : this.autoDetectMergeField!.merge(autoDetectMergeField),
      noMergeField: noMergeField ?? this.noMergeField,
      name: name ?? this.name,
    );
  }

  MergeHostModel merge([MergeHostModel? other]) {
    if (other == null) return this;
    return copyWith(
      forceMergeField: other.forceMergeField,
      autoDetectMergeField: other.autoDetectMergeField,
      noMergeField: other.noMergeField,
      name: other.name,
    );
  }

  List<Object?> get _props => [
    forceMergeField,
    autoDetectMergeField,
    noMergeField,
    name,
  ];
}

extension PropsParentModelExt on PropsParentModel {
  PropsParentModel copyWith({String? parentField}) {
    return PropsParentModel(parentField: parentField ?? this.parentField);
  }

  PropsParentModel merge([PropsParentModel? other]) {
    if (other == null) return this;
    return copyWith(parentField: other.parentField);
  }

  List<Object?> get _props => [parentField];
}

extension PropsChildModelExt on PropsChildModel {
  PropsChildModel copyWith({String? childField, String? parentField}) {
    return PropsChildModel(
      childField: childField ?? this.childField,
      parentField: parentField ?? this.parentField,
    );
  }

  PropsChildModel merge([PropsChildModel? other]) {
    if (other == null) return this;
    return copyWith(
      childField: other.childField,
      parentField: other.parentField,
    );
  }

  List<Object?> get _props => [childField];
}

extension NestedModelExt on NestedModel {
  static const NestedModel defaultModel = NestedModel(label: '');

  static NestedModel fromJson(Map<String, dynamic>? json) {
    if (json == null) return defaultModel;
    return NestedModel(
      label: $ElJsonUtil.$string(json, 'label') ?? '',
      child: $ElJsonUtil.$model<NestedModel?>(
        json,
        'child',
        NestedModelExt.defaultModel,
      ),
    );
  }

  Map<String, dynamic> _toJson() {
    return {'label': label, 'child': child?.toJson()};
  }

  NestedModel copyWith({String? label, NestedModel? child}) {
    return NestedModel(
      label: label ?? this.label,
      child: this.child == null ? child : this.child!.merge(child),
    );
  }

  NestedModel merge([NestedModel? other]) {
    if (other == null) return this;
    return copyWith(label: other.label, child: other.child);
  }

  List<Object?> get _props => [label, child];
}
