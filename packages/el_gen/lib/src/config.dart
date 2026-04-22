class ModelTemplateConfig {
  static late ModelTemplateConfig instance;

  /// 声明扩展后缀，默认 Ext
  final String extSuffix;

  ModelTemplateConfig._({required this.extSuffix});

  factory ModelTemplateConfig(Map<String, dynamic> config) {
    return ModelTemplateConfig._(extSuffix: config['ext_suffix'] ?? 'Ext');
  }
}

class ThemeDataTemplateConfig {
  static late ThemeDataTemplateConfig instance;

  /// 主题类命名前缀，默认 El，用于解析出目标字段名，字段名通常不需要特定的前缀、后缀，
  /// 例如：ElButtonThemeData -> buttonTheme
  final String prefix;

  /// 主题类命名后缀，默认 Data
  final String suffix;

  ThemeDataTemplateConfig._({required this.prefix, required this.suffix});

  factory ThemeDataTemplateConfig(Map<String, dynamic> config) {
    return ThemeDataTemplateConfig._(prefix: config['prefix'] ?? 'El', suffix: config['suffix'] ?? 'Data');
  }
}
