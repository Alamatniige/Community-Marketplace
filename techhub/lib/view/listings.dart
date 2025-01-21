import 'package:flutter/material.dart';
import 'package:techhub/controller/listing_controller.dart';
import 'package:techhub/model/item_model.dart';

class OnSaleListPage extends StatefulWidget {
  final String userId;
  const OnSaleListPage({required this.userId, super.key});

  @override
  State<OnSaleListPage> createState() => _OnSaleListPageState();
}

class _OnSaleListPageState extends State<OnSaleListPage> {
  final ItemController _controller = ItemController();
  late Future<List<Item>> _itemsFuture;

  @override
  void initState() {
    super.initState();
      _itemsFuture = _controller.fetchUserItems(widget.userId);
  }

  void _refreshItems() {
    setState(() {
          _itemsFuture = _controller.fetchUserItems(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Your Listings', style: TextStyle(color: Colors.white)),
      ),
      body: FutureBuilder<List<Item>>(
        future: _itemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No items listed yet.'));
          }

          final items = snapshot.data!;

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(item.imageUrl),
                    backgroundColor: Colors.grey[300],
                  ),
                  title: Text(item.name),
                  subtitle: Text('Price: ${item.price}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: item.status ?? false,
                        onChanged: (value) async {
                          try {
                            await _controller.updateItemStatus(item.id, value);

                            // Update the local state of the item without needing to call setState
                            setState(() {
                              item.status = value;
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Status updated successfully')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          try {
                            await _controller.deleteItem(item.id);
                            _refreshItems();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
