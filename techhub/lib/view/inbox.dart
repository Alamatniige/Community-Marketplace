import 'package:flutter/material.dart';
import 'package:techhub/controller/message_controller.dart';
import 'package:techhub/view/directmessage.dart';
import 'package:techhub/model/conversation_model.dart'; 

class InboxScreen extends StatelessWidget {
  final String userId;

  const InboxScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final controller = ChatController();
    return FutureBuilder<List<Conversation>>(
      future: controller.fetchConversations(userId), // Fetching conversations
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final conversations = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: Text('Inbox'),
              backgroundColor: Colors.blue,
            ),
            body: ListView.builder(
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                final conversation = conversations[index];
                return ListTile(
                  title: Text(conversation.sellerName),
                  subtitle: Text(conversation.lastMessage),
                  onTap: () {
                    // Pass the sellerId to direct message screen
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
            ),
          );
        } else {
          return Center(child: Text('No conversations found.'));
        }
      },
    );
  }
}
