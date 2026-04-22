// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../models/animal.dart';

// **************************************************************************
// ElModelGenerator
// **************************************************************************

extension AnimalModelExt on AnimalModel {
  static const AnimalModel defaultModel = AnimalModel();

  static AnimalModel fromJson(Map<String, dynamic>? json) {
    if (json == null) return defaultModel;
    return AnimalModel(name: ElJsonUtil.$string(json, 'name'), type: ElJsonUtil.$string(json, 'type'));
  }

  Map<String, dynamic> _toJson() {
    return {'name': name, 'type': type};
  }

  AnimalModel copyWith({String? name, String? type}) {
    return AnimalModel(name: name ?? this.name, type: type ?? this.type);
  }

  AnimalModel merge([AnimalModel? other]) {
    if (other == null) return this;
    return copyWith(name: other.name, type: other.type);
  }

  List<Object?> get _props => [name, type];
}
