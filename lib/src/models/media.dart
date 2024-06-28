import 'package:global_configuration/global_configuration.dart';

import '../helpers/custom_trace.dart';

class Media {
  String id;
  String name;
  String url;
  String thumb;
  String icon;
  String size;

  Media({
    this.id = '',
    this.name = '',
    this.url = '',
    this.thumb = '',
    this.icon = '',
    this.size = '',
  });

  Media.fromJSON(Map<String, dynamic> jsonMap)
      : id = jsonMap['id'].toString(),
        name = jsonMap['name'] ?? '',
        url = jsonMap['url'] ?? "${GlobalConfiguration().getValue('base_url')}images/image_default.png",
        thumb = jsonMap['thumb'] ?? "${GlobalConfiguration().getValue('base_url')}images/image_default.png",
        icon = jsonMap['icon'] ?? "${GlobalConfiguration().getValue('base_url')}images/image_default.png",
        size = jsonMap['formated_size'] ?? '';

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "url": url,
      "thumb": thumb,
      "icon": icon,
      "formated_size": size,
    };
  }

  @override
  String toString() {
    return this.toMap().toString();
  }
}
