import 'package:flutter/material.dart';
import 'package:techhub/controller/item_controller.dart';
import 'package:techhub/view/directmessage.dart';
import 'package:techhub/view/inbox.dart';
import 'package:techhub/view/profile.dart';
import 'package:techhub/model/item_model.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final ItemController _itemController = ItemController();
  final TextEditingController _searchController = TextEditingController();

  late Future<Map<String, List>> categorizedItems;
  List<Item> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    categorizedItems = _itemController.fetchItemsByCategory();
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    categorizedItems.then((categories) {
      final results = categories.values
          .expand((items) => items)
          .where((item) => item.name.toLowerCase().contains(query))
          .toList();

      setState(() {
        _isSearching = true;
        _searchResults = results.cast<Item>();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = _itemController.currentUser?.id;
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Row(
            children: [
              Spacer(),
              CircleAvatar(
                backgroundColor: Color.fromARGB(255, 0, 0, 0),
                child: Icon(
                  Icons.headset,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
              ),
              SizedBox(width: 5),
              Text(
                "Tech-Hub",
                style: TextStyle(color: Colors.white),
              ),
              Spacer(),
            ],
          ),
          backgroundColor: Colors.blue,
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            // Reload the categorized items
            setState(() {
              categorizedItems = _itemController.fetchItemsByCategory();
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: SingleChildScrollView(
              child: FutureBuilder<Map<String, List>>(
                future: categorizedItems,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No items available.'));
                  }

                  final categories = snapshot.data!;
                  final displayItems = _isSearching
                      ? {"Search Results": _searchResults}
                      : categories;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: "Search Product",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...displayItems.entries.map((entry) {
                        final categoryName = entry.key;
                        final items = entry.value;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              categoryName,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            SizedBox(
                              height: 150,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: items.length,
                                itemBuilder: (context, index) {
                                  return ProductCard(
                                    product: items[index],
                                    userId: userId,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.blue,
          selectedItemColor: Colors.white,
          unselectedItemColor: const Color.fromARGB(255, 0, 0, 0),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.message),
              label: "Messages",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profile",
            ),
          ],
          onTap: (index) {
            if (index == 1) {
              if (userId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InboxScreen(userId: userId),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User not authenticated')),
                );
              }
            }
            if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            }
          },
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Item product;
  final String? userId;

  const ProductCard({required this.product, required this.userId, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 120,
          maxHeight: 150,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: NetworkImage(product.imageUrl),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {
                    print('Image load error: $exception');
                  },
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              product.name,
              style: const TextStyle(fontSize: 10),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
            Text(
              product.price,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
            const SizedBox(height: 5),
            SizedBox(
              width: double.infinity,
              height: 25,
              child: ElevatedButton(
                onPressed: () {
                  if (userId != null && product.sellerId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatView(
                          userId: userId!,
                          receiverId: product.sellerId!,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User not authenticated')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.orange,
                ),
                child: const Text(
                  "Message Seller",
                  style: TextStyle(fontSize: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
