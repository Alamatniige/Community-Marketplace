import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SellItemModel {
  final SupabaseClient _client = Supabase.instance.client;

  // Upload image to bucket
  Future<String> uploadImage(String filePath) async {
    try {
      final fileName = filePath.split('/').last;
      final response = await _client.storage
          .from('item_image')
          .upload(fileName, File(filePath));
      if (response.isEmpty) {
        throw Exception('Failed to upload image');
      }
      return _client.storage.from('item_image').getPublicUrl(fileName);
    } catch (e) {
      throw Exception('Image upload failed: $e');
    }
  }

  // Insert item into the database
  Future<void> addItem({
    required String name,
    required String description,
    required double price,
    required int category,
    required String contactInformation,
    required List<String> imageUrls,
    required String userId,
  }) async {
    try {
      await _client.from('items').insert({
        'name': name,
        'description': description,
        'price': price,
        'category': category,
        'contact_information': contactInformation,
        'image_urls': imageUrls, 
        'user_id': userId,
        'status': true, 
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Item submission failed: $e');
    }
  }
}
