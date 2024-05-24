class ChatHistoryMessages {
  List<Message> messages;
  String baseUrl;

  ChatHistoryMessages({ this.messages,  this.baseUrl});

  factory ChatHistoryMessages.fromJson(Map<String, dynamic> json) {
    var messagesList = json['messages'] as List;
    List<Message> messages =
    messagesList.map((message) => Message.fromJson(message)).toList();

    return ChatHistoryMessages(
      messages: messages,
      baseUrl: json['base_url'],
    );
  }
}

class TicketMessagesResponse {
  bool success;
  ChatHistoryMessages data;
  String message;

  TicketMessagesResponse({ this.success,  this.data,  this.message});

  factory TicketMessagesResponse.fromJson(Map<String, dynamic> json) {
    return TicketMessagesResponse(
      success: json['success'],
      data: ChatHistoryMessages.fromJson(json['data']),
      message: json['message'],
    );
  }
}

class Message {
  int id;
  String supportTicketId;
  String fromUserId;
  String toUserId;
  String message;
  String messageFile;
  String file;
  String isMe;
  String messageType;
  String createdAt;
  String updatedAt;
  String fromName;
  String fromEmail;
  String toName;
  String toEmail;

  Message({
     this.id,
     this.supportTicketId,
     this.fromUserId,
     this.toUserId,
     this.message,
     this.messageFile,
     this.file,
     this.isMe,
     this.messageType,
     this.createdAt,
     this.updatedAt,
     this.fromName,
     this.fromEmail,
     this.toName,
     this.toEmail,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      supportTicketId: json['support_ticket_id'],
      fromUserId: json['from_user_id'],
      toUserId: json['to_user_id'],
      message: json['message'],
      messageFile: json['message_file'],
      file: json['file'],
      isMe: json['isme'],
      messageType: json['message_type'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      fromName: json['from_name'],
      fromEmail: json['from_email'],
      toName: json['to_name'],
      toEmail: json['to_email'],
    );
  }
}