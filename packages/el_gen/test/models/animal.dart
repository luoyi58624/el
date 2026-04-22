import 'package:el_dart/el_dart.dart';

part '../generates/models/animal.g.dart';

@ElModelGenerator.all()
class AnimalModel with EquatableMixin implements ElSerializeModel {
  final String? name;
  final String? type;

  const AnimalModel({this.name, this.type});

  AnimalModel.name({this.name, this.type});

  @override
  AnimalModel fromJson(Map<String, dynamic>? json) => AnimalModelExt.fromJson(json);

  @override
  Map<String, dynamic> toJson() => _toJson();

  @override
  List<Object?> get props => _props;
}
