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
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.mobile,
    required this.information,
    required this.adminCommission,
    required this.deliveryFee,
    required this.deliveryRange,
    required this.defaultTax,
    required this.closed,
    required this.active,
    required this.availableForDelivery,
    required this.availableForDineIn,
    required this.slots,
    required this.documents,
    required this.createdAt,
    required this.updatedAt,
    required this.hasMedia,
    required this.rate,
    required this.media,
    required this.galleries,
    required this.foods,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    final List<dynamic> mediaList = json['media'] ?? [];
    final List<Media> parsedMedia = mediaList.map((e) => Media.fromJson(e)).toList();

    final Map<String, dynamic> foodsMap = json['foods'] ?? {};
    final Map<String, Foods> parsedFoods = foodsMap.map((key, value) => MapEntry(key, Foods.fromJson(value)));

    return Restaurant(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      address: json['address'],
      latitude: json['latitude'] ?? '',
      longitude: json['longitude'] ?? '',
      phone: json['phone'] ?? '',
      mobile: json['mobile'] ?? '',
      information: json['information'] ?? '',
      adminCommission: json['adminCommission'] ?? 0,
      deliveryFee: json['deliveryFee'] ?? 0,
      deliveryRange: json['deliveryRange'] ?? 0,
      defaultTax: json['defaultTax'] ?? 0,
      closed: json['closed'] ?? false,
      active: json['active'] ?? false,
      availableForDelivery: json['availableForDelivery'] ?? false,
      availableForDineIn: json['availableForDineIn'] ?? false,
      slots: json['slots'] ?? '',
      documents: json['documents'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      hasMedia: json['hasMedia'] ?? false,
      rate: json['rate'] ?? 0.0,
      media: parsedMedia,
      galleries: List<String>.from(json['galleries'] ?? []),
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
    required this.id,
    required this.modelType,
    required this.modelName,
    required this.fileName,
    required this.mimeType,
    required this.url,
    required this.thumb,
    required this.icon,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      id: json['id'],
      modelType: json['model_type'] ?? '',
      modelName: json['name'] ?? '',
      fileName: json['file_name'] ?? '',
      mimeType: json['mime_type'] ?? '',
      url: json['url'] ?? '',
      thumb: json['thumb'] ?? '',
      icon: json['icon'] ?? '',
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
    required this.id,
    required this.type,
    required this.dates,
    required this.name,
    required this.price,
    required this.description,
    required this.unit,
    required this.deliverable,
    required this.timeSlots,
    required this.separateItem,
    required this.media,
  });

  factory Foods.fromJson(Map<String, dynamic> json) {
    final List<dynamic> separateItemList = json['separate_item'] ?? [];
    final List<SeparateItem> parsedSeparateItem = separateItemList.map((e) => SeparateItem.fromJson(e)).toList();

    return Foods(
      id: json['id'],
      type: json['type'] ?? '',
      dates: json['dates'] ?? '',
      name: json['name'] ?? '',
      price: json['price'] ?? 0,
      description: json['description'] ?? '',
      unit: json['unit'] ?? '',
      deliverable: json['deliverable'] ?? false,
      timeSlots: Map<String, dynamic>.from(json['time_slots'] ?? {}),
      separateItem: parsedSeparateItem,
      media: json['media'] ?? '',
    );
  }
}

class SeparateItem {
  final int foodId;
  final String name;
  final int price;
  final String image;

  SeparateItem({
    required this.foodId,
    required this.name,
    required this.price,
    required this.image,
  });

  factory SeparateItem.fromJson(Map<String, dynamic> json) {
    return SeparateItem(
      foodId: json['food_id'],
      name: json['name'] ?? '',
      price: json['price'] ?? 0,
      image: json['image'] ?? '',
    );
  }
}
