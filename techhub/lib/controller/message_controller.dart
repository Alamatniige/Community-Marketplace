import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:techhub/model/message_model.dart';
import 'package:techhub/model/conversation_model.dart';

class ChatController {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Fetch conversations for a user
  Future<List<Conversation>> fetchConversations(String userId) async {
    try {
      final response = await _supabase
          .from('conversations')
          .select(
            '''id, user_id, seller_id, last_message, last_sent_at, seller:user!fk_seller_id(fullname)'''
          )
          .eq('user_id', userId);

      return (response as List).map((conversation) {
        final sellerName = conversation['seller']['fullname'] ?? 'Unknown Seller';
        return Conversation.fromMap({...conversation, 'seller_name': sellerName});
      }).toList();
    } catch (e) {
      print('Error fetching conversations: $e');
      return [];
    }
  }

  // Fetch conversation ID based on user and receiver
  Future<String> fetchConversationId(String userId, String receiverId) async {
    try {
      final response = await _supabase
          .from('conversations')
          .select('id')
          .eq('user_id', userId)
          .eq('seller_id', receiverId)
          .single();

      return response['id'];  // Return the conversation ID
    } catch (e) {
      print('Error fetching conversation ID: $e');
      return '';  // Return an empty string if no conversation found
    }
  }

  // Fetch messages for a specific conversation
   Future<List<Message>> getMessagesByConversation(String conversationsId) async {
    try {
      final response = await _supabase
          .from('messages')
          .select()
          .eq('conversations_id', conversationsId)
          .order('sent_at', ascending: true);

      return (response as List)
          .map((message) => Message.fromMap(message))
          .toList();
    } catch (e) {
      print('Error fetching messages: $e');
      return [];
    }
  }
  // Create or fetch the existing conversation between user and seller
  Future<int> getOrCreateConversation(String userId, String sellerId, String productId) async {
    final response = await _supabase
        .from('conversations')
        .select('id')
        .eq('user_id', userId)
        .eq('seller_id', sellerId)
        .eq('product_id', productId)
        .single();

    return response['id'];
  }

  // Fetch conversation with seller name
  Future<Conversation> fetchConversationWithSellerName(String userId, String sellerId, String productId) async {
    final response = await _supabase
        .from('conversations')
        .select('id, user_id, seller_id, product_id, last_message, last_sent_at')
        .eq('user_id', userId)
        .eq('seller_id', sellerId)
        .eq('product_id', productId)
        .single();

    final conversation = Conversation.fromMap(response);

    // Fetch the seller's full name from the user table
    final sellerNameResponse = await _supabase
        .from('user')
        .select('fullname')
        .eq('id', sellerId)
        .single();

    final sellerName = sellerNameResponse['fullname'] as String;

    return conversation.copyWith(sellerName: sellerName);
  }


  // Check if the user has unread messages
  Future<List<Message>> checkUnreadMessages(String userId) async {
    try {
      final response = await _supabase
          .from('messages')
          .select()
          .eq('receiver_id', userId)  // Get messages sent to the user
          .eq('is_read', false)  // Get only unread messages
          .order('sent_at', ascending: false);  // Order by the latest message first

      return (response as List)
          .map((message) => Message.fromMap(message))
          .toList();
    } catch (e) {
      print('Error fetching unread messages: $e');
      return [];
    }
  }

    // Subscribe to messages
  RealtimeChannel subscribeToMessages(
    String conversationsId,
    Function(Message) onMessageReceived,
  ) {
    final channel = _supabase.channel('messages:$conversationsId');
    
    channel.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'messages',
      callback: (payload) {
        print('New message received: ${payload.newRecord}');
        if (payload.newRecord['conversations_id'] == conversationsId) {
          final newMessage = Message.fromMap(
            Map<String, dynamic>.from(payload.newRecord),
          );
          onMessageReceived(newMessage);
        }
      },
    );

    channel.subscribe();
    return channel;
  }

 Future<void> markMessagesAsRead(String conversationId, String userId) async {
    try {
      await _supabase
          .from('messages')
          .update({'is_read': true})
          .eq('conversations_id', conversationId)
          .eq('receiver_id', userId)
          .eq('is_read', false);
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

// Send a message
  Future<Message?> sendMessage(
    String senderId,
    String receiverId,
    String content,
    String conversationsId,
  ) async {
    try {
      final response = await _supabase
          .from('messages')
          .insert({
            'sender_id': senderId,
            'receiver_id': receiverId,
            'content': content,
            'sent_at': DateTime.now().toIso8601String(),
            'is_read': false,
            'conversations_id': conversationsId,
          })
          .select()
          .single();

      // Update the last message in the conversation table
      await _supabase
          .from('conversations')
          .update({
            'last_message': content,
            'last_sent_at': DateTime.now().toIso8601String(),
          })
          .eq('id', conversationsId);

      return Message.fromMap(response);
    } catch (e) {
      print('Error sending message: $e');
      return null;
    }
  }
}





