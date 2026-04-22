// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'index.dart';

// **************************************************************************
// ElModelGenerator
// **************************************************************************

extension ElLayoutDataExt on ElLayoutData {
  static final ElLayoutData defaultModel = ElLayoutData(header: 0.0, sidebar: 0.0, rightSidebar: 0.0, footer: 0.0);

  static ElLayoutData fromJson(Map<String, dynamic>? json) {
    if (json == null) return defaultModel;
    return ElLayoutData(
      header: ElJsonUtil.$double(json, 'header') ?? 0.0,
      sidebar: ElJsonUtil.$double(json, 'sidebar') ?? 0.0,
      rightSidebar: ElJsonUtil.$double(json, 'rightSidebar') ?? 0.0,
      footer: ElJsonUtil.$double(json, 'footer') ?? 0.0,
    );
  }

  Map<String, dynamic> _toJson() {
    return {'header': header, 'sidebar': sidebar, 'rightSidebar': rightSidebar, 'footer': footer};
  }

  ElLayoutData copyWith({double? header, double? sidebar, double? rightSidebar, double? footer}) {
    return ElLayoutData(
      header: header ?? this.header,
      sidebar: sidebar ?? this.sidebar,
      rightSidebar: rightSidebar ?? this.rightSidebar,
      footer: footer ?? this.footer,
    );
  }

  ElLayoutData merge([ElLayoutData? other]) {
    if (other == null) return this;
    return copyWith(
      header: other.header,
      sidebar: other.sidebar,
      rightSidebar: other.rightSidebar,
      footer: other.footer,
    );
  }

  List<Object?> get _props => [header, sidebar, rightSidebar, footer];
}
