class Conversation {
  final String id;
  final String userId;
  final String sellerId;
  final String sellerName;

  Conversation({
    required this.id,
    required this.userId,
    required this.sellerId,
    required this.sellerName,
  });

  factory Conversation.fromMap(Map<String, dynamic> map) {
    return Conversation(
      id: map['id'] as String? ?? 'default_id',
      userId: map['user_id'] as String? ?? 'default_user',
      sellerId: map['seller_id'] as String? ?? 'default_seller',
      sellerName: map['seller_name'] as String? ?? 'Unknown Seller',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'seller_id': sellerId,
      'seller_name': sellerName,
    };
  }
}
