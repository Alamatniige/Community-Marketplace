class Message {
  final String id;  // UUID as String
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime sentAt;
  final bool isRead;
  final String conversationId;  // UUID as String for conversation ID

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.sentAt,
    required this.isRead,
    required this.conversationId,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
  return Message(
    id: map['id'] as String? ?? 'default_id',  // Provide a default value if null
    senderId: map['sender_id'] as String? ?? 'default_sender',  // Provide a default value if null
    receiverId: map['receiver_id'] as String? ?? 'default_receiver',  // Provide a default value if null
    content: map['content'] as String? ?? 'No content',  // Provide a default value if null
    sentAt: map['sent_at'] != null ? DateTime.parse(map['sent_at'] as String) : DateTime.now(),  // Default to current time if null
    isRead: map['is_read'] as bool? ?? false,  // Default to false if null
    conversationId: map['conversations_id'] as String? ?? 'default_conversation',  // Provide a default value if null
  );
}


  Map<String, dynamic> toMap() {
    return {
      'id': id,  // UUID as String
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
      'sent_at': sentAt.toIso8601String(),
      'is_read': isRead,
      'conversation_id': conversationId,  // UUID as String
    };
  }
}
