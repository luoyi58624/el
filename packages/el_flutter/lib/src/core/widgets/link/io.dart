import 'package:url_launcher/link.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:el_dart/el_dart.dart';
import 'common.dart';

String? getPreviewLink(String href) {
  if (ElStringUtil.isHttp(href)) return href;
  return null;
}

void toLink(String href, LinkTarget target) {
  if (href == '#') return;
  if (ElStringUtil.isHttp(href)) {
    launchUrl(Uri.parse(href));
  } else {
    pushRouteNameToFramework(null, href);
  }
}
