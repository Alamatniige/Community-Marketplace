import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:techhub/model/item_model.dart';

class ItemController {
  final SupabaseClient _client = Supabase.instance.client;
  User? _currentUser;
  Map<String, dynamic>? _userData;

  // Getters
  User? get currentUser => _currentUser;
  Map<String, dynamic>? get userData => _userData;
  bool get isAuthenticated => _currentUser != null;

  // Constructor to initialize the user data
  ItemController() {
    _initializeCurrentUser();
  }

  // Method to initialize the currentUser
  Future<void> _initializeCurrentUser() async {
    try {
      _currentUser = _client.auth.currentUser;
      if (_currentUser != null) {
        await _loadUserData();
      } else {
        print("No user is logged in.");
      }
    } catch (e) {
      print("Error checking user: $e");
    }
  }

  // Load additional user data
  Future<void> _loadUserData() async {
    try {
      final email = _currentUser!.email;
      if (email != null) {
        final response = await _client
            .from('user')
            .select()
            .eq('email', email)
            .single();

        _userData = response;
        print('User data loaded successfully: ${_userData?['fullname']}');
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<Map<String, List<Item>>> fetchItemsByCategory() async {
    try {
      final response = await _client
          .from('items')
          .select('*, categories(id, category_name)');

      final List<Item> items = [];
      for (var itemData in (response as List<dynamic>)) {
        try {
          final item = Item.fromMap(itemData);
          items.add(item);
        } catch (e) {
          print('Error processing item: $e');
        }
      }

      final Map<String, List<Item>> categorizedItems = {};
      for (final item in items) {
        final categoryName = item.categoryName.isNotEmpty
            ? item.categoryName
            : 'Uncategorized';

        categorizedItems.putIfAbsent(categoryName, () => []);
        categorizedItems[categoryName]!.add(item);
      }

      return categorizedItems;
    } catch (e) {
      print('Fetch error: $e');
      throw Exception('Failed to fetch items by category: $e');
    }
  }

  Future<List<Item>> fetchItemsBySpecificCategory(int categoryId) async {
    try {
      final response = await _client
          .from('items')
          .select('*, categories(id, category_name)')
          .eq('category', categoryId);

      return (response as List<dynamic>)
          .map((itemData) => Item.fromMap(itemData))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch items: $e');
    }
  }
}
