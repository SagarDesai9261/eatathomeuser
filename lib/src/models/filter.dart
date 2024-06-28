import '../helpers/custom_trace.dart';
import '../models/cuisine.dart';

class Filter {
  bool delivery;
  bool open;
  List<Cuisine> cuisines;

  Filter({
    this.delivery = false,
    this.open = false,
    this.cuisines = const [],
  });

  Filter.fromJSON(Map<String, dynamic> jsonMap)
      : delivery = jsonMap['delivery'] ?? false,
        open = jsonMap['open'] ?? false,
        cuisines = jsonMap['cuisines'] != null && (jsonMap['cuisines'] as List).isNotEmpty
            ? List.from(jsonMap['cuisines']).map((element) => Cuisine.fromJSON(element)).toList()
            : [];

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'delivery': delivery,
      'open': open,
      'cuisines': cuisines.map((element) => element.toMap()).toList(),
    };
    return map;
  }

  @override
  String toString() {
    String filter = "";
    if (delivery) {
      if (open) {
        filter = "search=available_for_delivery:1;closed:0&searchFields=available_for_delivery:=;closed:=&searchJoin=and";
      } else {
        filter = "search=available_for_delivery:1&searchFields=available_for_delivery:=";
      }
    } else if (open) {
      filter = "search=closed:${open ? 0 : 1}&searchFields=closed:=";
    }
    return filter;
  }

  Map<String, dynamic> toQuery({Map<String, dynamic>? oldQuery}) {
    Map<String, dynamic> query = {};
    String relation = '';
    if (oldQuery != null) {
      relation = oldQuery['with'] != null ? oldQuery['with']! + '.' : '';
      query['with'] = oldQuery['with'];
    }
    if (delivery) {
      if (open) {
        query['search'] = '$relation' + 'available_for_delivery:1;closed:0';
        query['searchFields'] = '$relation' + 'available_for_delivery:=;closed:=';
      } else {
        query['search'] = '$relation' + 'available_for_delivery:1';
        query['searchFields'] = '$relation' + 'available_for_delivery:=';
      }
    } else if (open) {
      query['search'] = '$relation' + 'closed:${open ? 0 : 1}';
      query['searchFields'] = '$relation' + 'closed:=';
    }
    if (cuisines.isNotEmpty) {
      query['cuisines[]'] = cuisines.map((element) => element.id).toList();
    }
    if (oldQuery != null) {
      query['search'] = oldQuery['search'] != null ? (query['search'] ?? '') + ';' + oldQuery['search']! : query['search'];
      query['searchFields'] =
      oldQuery['searchFields'] != null ? (query['searchFields'] ?? '') + ';' + oldQuery['searchFields']! : query['searchFields'];
    }
    query['searchJoin'] = 'and';
    return query;
  }
}
