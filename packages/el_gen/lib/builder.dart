import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/builders/model.dart';
import 'src/builders/theme_data.dart';
import 'src/config.dart';

Builder elModelBuilder(BuilderOptions options) {
  ModelTemplateConfig.instance = ModelTemplateConfig(options.config);
  return SharedPartBuilder([ElModelGenerator()], 'model');
}

Builder elThemeDataBuilder(BuilderOptions options) {
  ThemeDataTemplateConfig.instance = ThemeDataTemplateConfig(options.config);
  return SharedPartBuilder([ElThemeGenerator()], 'themeData');
}
