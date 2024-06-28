class Nutrition {
  String id;
  String name;
  double quantity;

  Nutrition({
    this.id = '',
    this.name = '',
    this.quantity = 0.0,
  });

  Nutrition.fromJSON(Map<String, dynamic> jsonMap)
      : id = jsonMap['id'].toString(),
        name = jsonMap['name'] ?? '',
        quantity = jsonMap['quantity']?.toDouble() ?? 0.0;

  @override
  bool operator ==(dynamic other) {
    if (other is! Nutrition) return false;
    return other.id == this.id;
  }

  @override
  int get hashCode => this.id.hashCode;
}
