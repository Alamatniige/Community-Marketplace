import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:techhub/model/item_model.dart';

class ItemController {
  final SupabaseClient _client = Supabase.instance.client;

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

    // Group items by category
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

  // Fetch items for a specific category
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