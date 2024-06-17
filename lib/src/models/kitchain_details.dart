class Restaurant {
  final int id;
  final String name;
  final String description;
  final String address;
  final String latitude;
  final String longitude;
  final String phone;
  final String mobile;
  final String information;
  final int adminCommission;
  final int deliveryFee;
  final int deliveryRange;
  final int defaultTax;
  final bool closed;
  final bool active;
  final bool availableForDelivery;
  final bool availableForDineIn;
  final String slots;
  final String documents;
  final String createdAt;
  final String updatedAt;
  final bool hasMedia;
  final double rate;
  final List<Media> media;
  final List<String> galleries;
  final Map<String, Foods> foods;

  Restaurant({
     this.id,
     this.name,
     this.description,
     this.address,
     this.latitude,
     this.longitude,
     this.phone,
     this.mobile,
     this.information,
     this.adminCommission,
     this.deliveryFee,
     this.deliveryRange,
     this.defaultTax,
     this.closed,
     this.active,
     this.availableForDelivery,
     this.availableForDineIn,
     this.slots,
     this.documents,
     this.createdAt,
     this.updatedAt,
     this.hasMedia,
     this.rate,
     this.media,
     this.galleries,
     this.foods,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    // Parsing 'media' and 'foods' lists
    final List<dynamic> mediaList = json['media'];
    final List<Media> parsedMedia = mediaList.map((e) => Media.fromJson(e)).toList();

    final Map<String, dynamic> foodsMap = json['foods'];
    final Map<String, Foods> parsedFoods = foodsMap.map((key, value) => MapEntry(key, Foods.fromJson(value)));

    return Restaurant(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      // ... other properties
      media: parsedMedia,
      galleries: List<String>.from(json['galleries']),
      foods: parsedFoods,
    );
  }
}

class Media {
  final int id;
  final String modelType;
  final String modelName;
  final String fileName;
  final String mimeType;
  final String url;
  final String thumb;
  final String icon;

  Media({
     this.id,
     this.modelType,
     this.modelName,
     this.fileName,
     this.mimeType,
     this.url,
     this.thumb,
     this.icon,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      id: json['id'],
      modelType: json['model_type'],
      modelName: json['name'],
      fileName: json['file_name'],
      mimeType: json['mime_type'],
      url: json['url'],
      thumb: json['thumb'],
      icon: json['icon'],
    );
  }
}

class Foods {
  final int id;
  final String type;
  final String dates;
  final String name;
  final int price;
  final String description;
  final String unit;
  final bool deliverable;
  final Map<String, dynamic> timeSlots;
  final List<SeparateItem> separateItem;
  final String media;

  Foods({
     this.id,
     this.type,
     this.dates,
     this.name,
     this.price,
     this.description,
     this.unit,
     this.deliverable,
     this.timeSlots,
     this.separateItem,
     this.media,
  });

  factory Foods.fromJson(Map<String, dynamic> json) {
    // Parsing 'separate_item' list
    final List<dynamic> separateItemList = json['separate_item'];
    final List<SeparateItem> parsedSeparateItem =
        separateItemList.map((e) => SeparateItem.fromJson(e)).toList();

    return Foods(
      id: json['id'],
      type: json['type'],
      dates: json['dates'],
      name: json['name'],
      price: json['price'],
      description: json['description'],
      unit: json['unit'],
      deliverable: json['deliverable'],
      timeSlots: Map<String, dynamic>.from(json['time_slots']),
      separateItem: parsedSeparateItem,
      media: json['media'],
    );
  }
}

class SeparateItem {
  final int foodId;
  final String name;
  final int price;
  final String image;

  SeparateItem({
     this.foodId,
     this.name,
     this.price,
     this.image,
  });

  factory SeparateItem.fromJson(Map<String, dynamic> json) {
    return SeparateItem(
      foodId: json['food_id'],
      name: json['name'],
      price: json['price'],
      image: json['image'],
    );
  }
}
