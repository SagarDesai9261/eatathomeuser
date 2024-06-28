import 'package:flutter/material.dart';

import 'user.dart';

class Chat {
  String? id;
  // message text
  String? text;
  // time of the message
  int? time;
  // user id who send the message
  String? userId;

  User user;

  Chat({
     this.text,
     this.time,
     this.userId,
  }) : id = UniqueKey().toString(),
        user = User();

  Chat.fromJSON(Map<String, dynamic> jsonMap)
      : id = jsonMap['id'] != null ? jsonMap['id'].toString() : UniqueKey().toString(),
        text = jsonMap['text'] != null ? jsonMap['text'].toString() : '',
        time = jsonMap['time'] != null ? jsonMap['time'] : 0,
        userId = jsonMap['user'] != null ? jsonMap['user'].toString() : '',
        user = User.fromJSON(jsonMap['user'] ?? {});

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "text": text,
      "time": time,
      "user": userId,
    };
  }
}
