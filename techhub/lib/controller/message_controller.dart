import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:techhub/model/message_model.dart';
import 'package:techhub/model/conversation_model.dart';

class ChatController {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Fetch conversations for a user who is currently logged in
  Future<String> getSellerName(String userId) async {
    try {
      final response = await _supabase
          .from('user')
          .select('fullname')
          .eq('id', userId)
          .single();
      return response['fullname'] as String;
    } catch (e) {
      print('Error fetching seller name: $e');
      return 'Unknown User';
    }
  }

  Future<List<Conversation>> fetchConversations(String userId) async {
    try {
      // Fetch ALL conversations where the user is either sender or receiver in a single query
      final response = await _supabase
          .from('conversations')
          .select('id, user_id, seller_id')
          .or('user_id.eq.$userId,seller_id.eq.$userId');

      return Future.wait(response.map((conversation) async {
        final otherUserId = conversation['user_id'] == userId 
            ? conversation['seller_id'] 
            : conversation['user_id'];
        
        final otherUserName = await getSellerName(otherUserId);
        
        return Conversation.fromMap({
          ...conversation,
          'seller_name': otherUserName,
        });
      }));
    } catch (e) {
      print('Error fetching conversations: $e');
      return [];
    }
  }

  // Fetch messages for a specific conversation
  Future<List<Message>> getMessagesByConversation(String conversationId) async {
    try {
      final response = await _supabase
          .from('messages')
          .select()
          .eq('conversations_id', conversationId)
          .order('sent_at', ascending: true);

      return (response as List)
          .map((message) => Message.fromMap(message))
          .toList();
    } catch (e) {
      print('Error fetching messages: $e');
      return [];
    }
  }

  // Modified to properly handle bi-directional conversations
  Future<String> getOrCreateConversation(String userId1, String userId2) async {
    try {
      // Check both directions in a single query using OR condition
      final existing = await _supabase
          .from('conversations')
          .select('id')
          .or('and(user_id.eq.$userId1,seller_id.eq.$userId2),and(user_id.eq.$userId2,seller_id.eq.$userId1)')
          .maybeSingle();

      if (existing != null) {
        return existing['id'];
      }

      // If no conversation exists, create a new one
      final newConversation = await _supabase
          .from('conversations')
          .insert({
            'user_id': userId1,
            'seller_id': userId2,
          })
          .select('id')
          .single();

      return newConversation['id'];
    } catch (e) {
      print('Error in getOrCreateConversation: $e');
      return '';
    }
  }

  // Modified to handle messages in both directions
  Future<Message?> sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
  }) async {
    try {
      final conversationId = await getOrCreateConversation(senderId, receiverId);

      if (conversationId.isEmpty) {
        print('Failed to create or find conversation');
        return null;
      }

      final messageResponse = await _supabase
          .from('messages')
          .insert({
            'conversations_id': conversationId,
            'sender_id': senderId,
            'receiver_id': receiverId,
            'content': content,
            'sent_at': DateTime.now().toIso8601String(),
            'is_read': false,
          })
          .select()
          .single();

      return Message.fromMap(messageResponse);
    } catch (e) {
      print('Error sending message: $e');
      return null;
    }
  }

  // Subscribe to messages (modified to handle both directions)
  RealtimeChannel subscribeToMessages(
    String conversationId,
    String currentUserId,
    Function(Message) onMessageReceived,
  ) {
    final channel = _supabase.channel('messages:$conversationId');
    
    channel.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'messages',
      callback: (payload) {
        if (payload.newRecord['conversations_id'] == conversationId) {
          final newMessage = Message.fromMap(
            Map<String, dynamic>.from(payload.newRecord),
          );
          // Make sure to show messages for both sender and receiver
          if (newMessage.senderId == currentUserId || 
              newMessage.receiverId == currentUserId) {
            onMessageReceived(newMessage);
          }
        }
      },
    );

    channel.subscribe();
    return channel;
  }
}