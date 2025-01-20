import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:techhub/model/item_model.dart';

class ItemController {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Fetch all items for the current user
  Future<List<Item>> fetchUserItems(String userId) async {
    final response = await _supabase
        .from('items')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((item) => Item.fromMap(item))
        .toList();
  }

    Future<void> updateItemStatus(String itemId, bool status) async {
      try {
        await _supabase
            .from('items')
            .update({'status': status})
            .eq('id', itemId);

      } catch (e) {
        print('Error updating status for item $itemId: $e');
        throw Exception('Failed to update status');
      }
    }


  // Delete an item
  Future<void> deleteItem(String itemId) async {
    final response = await _supabase
        .from('items')
        .delete()
        .eq('id', itemId);

    if (response.error != null) {
      throw Exception(response.error!.message);
    }
  }
}
