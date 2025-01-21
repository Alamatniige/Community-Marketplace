import 'package:flutter/material.dart';
import 'package:techhub/controller/message_controller.dart';
import 'package:techhub/model/message_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatView extends StatefulWidget {
  final String userId;
  final String receiverId;

  const ChatView({super.key, required this.userId, required this.receiverId});

  @override
  _ChatViewState createState() => _ChatViewState();
}

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMyMessage;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMyMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMyMessage ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          message.content,
          style: TextStyle(
            color: isMyMessage ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatController _controller = ChatController();
  
  String _conversationId = '';
  bool _isConversationReady = false;
  List<Message> _messages = [];
  RealtimeChannel? _messageSubscription;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  @override
  void dispose() {
    _messageSubscription?.unsubscribe();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    try {
      // Get or create conversation between the two users
      _conversationId = await _controller.getOrCreateConversation(
        widget.userId,
        widget.receiverId,
      );

      if (_conversationId.isNotEmpty) {
        setState(() {
          _isConversationReady = true;
        });

        await _loadMessages();

        _subscribeToMessages();

      }
    } catch (e) {
      print('Error initializing chat: $e');
      setState(() {
        _isConversationReady = false;
      });
    }
  }

  Future<void> _loadMessages() async {
    final messages = await _controller.getMessagesByConversation(_conversationId);
    setState(() {
      _messages = messages;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _subscribeToMessages() {
    try {
      _messageSubscription = _controller.subscribeToMessages(
        _conversationId,
        widget.userId,
        (newMessage) {
          setState(() {
            _messages.add(newMessage);
          });
          _scrollToBottom();
          
        },
      );
    } catch (e) {
      print('Error subscribing to messages: $e');
    }
  }

  
  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty || !_isConversationReady) return;

    final messageText = _messageController.text.trim();
    _messageController.clear();

    try {
      final message = await _controller.sendMessage(
        senderId: widget.userId,
        receiverId: widget.receiverId,
        content: messageText,
      );

      if (message != null) {
        _scrollToBottom();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to send message')),
          );
        }
      }
    } catch (e) {
      print('Error sending message: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: !_isConversationReady
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8.0),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isMyMessage = message.senderId == widget.userId;

                      return MessageBubble(
                        message: message,
                        isMyMessage: isMyMessage,
                      );
                    },
                  ),
                ),
                _buildMessageInput(),
              ],
            ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -1),
            blurRadius: 8,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}