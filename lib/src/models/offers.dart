
class Offer {
  int id;
  String title;
  String description;
  String logo;
  int active;
  int priority;
  String createdAt;
  String updatedAt;
  bool hasMedia;
  List<Media> media;

  Offer(
      {this.id,
        this.title,
        this.description,
        this.logo,
        this.active,
        this.priority,
        this.createdAt,
        this.updatedAt,
        this.hasMedia,
        this.media});

  Offer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    logo = json['logo'];
    active = json['active'];
    priority = json['priority'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    hasMedia = json['has_media'];
    if (json['media'] != null) {
      media = <Media>[];
      json['media'].forEach((v) {
        media.add(new Media.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['description'] = this.description;
    data['logo'] = this.logo;
    data['active'] = this.active;
    data['priority'] = this.priority;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['has_media'] = this.hasMedia;

    return data;
  }
}

class Media {

  String createdAt;
  String updatedAt;
  String url;
  String thumb;
  String icon;


  Media(
      {
        this.createdAt,
        this.updatedAt,
        this.url,
        this.thumb,
        this.icon,
        });

  Media.fromJson(Map<String, dynamic> json) {

    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    url = json['url'];
    thumb = json['thumb'];
    icon = json['icon'];

  }

}
