import 'package:flutter/material.dart';
import 'package:techhub/controller/message_controller.dart';
import 'package:techhub/view/directmessage.dart';
import 'package:techhub/model/conversation_model.dart'; 
import 'package:techhub/model/message_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InboxScreen extends StatelessWidget {
  final String userId;
  final _supabase = Supabase.instance.client;

  InboxScreen({super.key, required this.userId});

  Future<String> getSellerName(String sellerId) async {
    // Fetch the seller's full name by sellerId
    try {
      final response = await _supabase
          .from('user')
          .select('fullname')
          .eq('id', sellerId)
          .single();
      return response['fullname'] ?? 'Unknown Seller';
    } catch (e) {
      print('Error fetching seller name: $e');
      return 'Unknown Seller';
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ChatController();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inbox'),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<List<Conversation>>(
        future: controller.fetchConversations(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
                  ElevatedButton(
                    onPressed: () => controller.fetchConversations(userId),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final conversations = snapshot.data!;
            return ListView.builder(
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                final conversation = conversations[index];

                // Fetch the seller's name for the current conversation
                return FutureBuilder<String>(
                  future: getSellerName(conversation.sellerId),
                  builder: (context, sellerSnapshot) {
                    if (sellerSnapshot.connectionState == ConnectionState.waiting) {
                      return ListTile(
                        title: const Text('Loading seller...'),
                        subtitle: Text('Loading...'),
                        trailing: Icon(Icons.check_circle, color: Colors.grey),
                      );
                    }

                    if (sellerSnapshot.hasError) {
                      return ListTile(
                        title: const Text('Error fetching seller'),
                        subtitle: Text('Error loading message'),
                        trailing: Icon(Icons.check_circle, color: Colors.grey),
                      );
                    }

                    final sellerName = sellerSnapshot.data ?? 'Unknown Seller';

                    return FutureBuilder<List<Message>>(
                      future: controller.getMessagesByConversation(conversation.id),
                      builder: (context, messageSnapshot) {
                        if (messageSnapshot.connectionState == ConnectionState.waiting) {
                          return ListTile(
                            title: Text(sellerName),
                            subtitle: Text('Loading...'),
                            trailing: Icon(Icons.check_circle, color: Colors.grey),
                          );
                        }

                        if (messageSnapshot.hasError) {
                          return ListTile(
                            title: Text(sellerName),
                            subtitle: Text('Error loading message'),
                            trailing: Icon(Icons.check_circle, color: Colors.grey),
                          );
                        }

                        final messages = messageSnapshot.data ?? [];
                        final lastMessage = messages.isNotEmpty ? messages.last.content : 'No messages yet';

                        return ListTile(
                          title: Text(sellerName),
                          subtitle: Text(lastMessage),
                          trailing: Icon(
                            Icons.check_circle,
                            color: messages.isNotEmpty && messages.last.isRead ? Colors.green : Colors.grey,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatView(
                                  userId: userId,
                                  receiverId: conversation.sellerId,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            );
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No conversations yet!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
