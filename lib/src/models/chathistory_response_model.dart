class ChatHistoryMessages {
  final List<Message> messages;
  final String baseUrl;

  ChatHistoryMessages({required this.messages, required this.baseUrl});

  factory ChatHistoryMessages.fromJson(Map<String, dynamic> json) {
    var messagesList = json['messages'] as List;
    List<Message> messages = messagesList.map((message) => Message.fromJson(message)).toList();

    return ChatHistoryMessages(
      messages: messages,
      baseUrl: json['base_url'] ?? '',
    );
  }
}

class TicketMessagesResponse {
  final bool success;
  final ChatHistoryMessages data;
  final String message;

  TicketMessagesResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory TicketMessagesResponse.fromJson(Map<String, dynamic> json) {
    return TicketMessagesResponse(
      success: json['success'] ?? false,
      data: ChatHistoryMessages.fromJson(json['data'] ?? {}),
      message: json['message'] ?? '',
    );
  }
}

class Message {
  final int id;
  final String supportTicketId;
  final String fromUserId;
  final String toUserId;
  final String message;
  final String messageFile;
  final String file;
  final String isMe;
  final String messageType;
  final String createdAt;
  final String updatedAt;
  final String fromName;
  final String fromEmail;
  final String toName;
  final String toEmail;

  Message({
    required this.id,
    required this.supportTicketId,
    required this.fromUserId,
    required this.toUserId,
    required this.message,
    required this.messageFile,
    required this.file,
    required this.isMe,
    required this.messageType,
    required this.createdAt,
    required this.updatedAt,
    required this.fromName,
    required this.fromEmail,
    required this.toName,
    required this.toEmail,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? 0,
      supportTicketId: json['support_ticket_id'] ?? '',
      fromUserId: json['from_user_id'] ?? '',
      toUserId: json['to_user_id'] ?? '',
      message: json['message'] ?? '',
      messageFile: json['message_file'] ?? '',
      file: json['file'] ?? '',
      isMe: json['isme'] ?? '',
      messageType: json['message_type'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      fromName: json['from_name'] ?? '',
      fromEmail: json['from_email'] ?? '',
      toName: json['to_name'] ?? '',
      toEmail: json['to_email'] ?? '',
    );
  }
}
