class Conversation {
  final String id;
  final String userId;
  final String sellerId;
  final String sellerName;
  final String lastMessage;
  final DateTime lastSentAt;

  Conversation({
    required this.id,
    required this.userId,
    required this.sellerId,
    required this.sellerName,
    required this.lastMessage,
    required this.lastSentAt,
  });

  factory Conversation.fromMap(Map<String, dynamic> map) {
  return Conversation(
    id: map['id'] as String? ?? 'default_id',  // Provide a default value if null
    userId: map['user_id'] as String? ?? 'default_user',  // Provide a default value if null
    sellerId: map['seller_id'] as String? ?? 'default_seller',  // Provide a default value if null
    sellerName: map['seller_name'] as String? ?? 'Unknown Seller',  // Optional field, default if null
    lastMessage: map['last_message'] as String? ?? 'No message',  // Provide a default value if null
    lastSentAt: map['last_sent_at'] != null ? DateTime.parse(map['last_sent_at'] as String) : DateTime.now(),  // Default to current time if null
  );
}



  Conversation copyWith({
    String? sellerName,
  }) {
    return Conversation(
      id: id,
      userId: userId,
      sellerId: sellerId,
      sellerName: sellerName ?? this.sellerName,
      lastMessage: lastMessage,
      lastSentAt: lastSentAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'seller_id': sellerId,
      'seller_name': sellerName,
      'last_message': lastMessage,
      'last_sent_at': lastSentAt.toIso8601String(),
    };
  }
}
