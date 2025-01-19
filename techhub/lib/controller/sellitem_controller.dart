import 'package:techhub/model/sellitem_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SellItemController {
  final SellItemModel _model;

  SellItemController(this._model);

  // Upload images and return their URLs
  Future<List<String>> uploadImages(List<String> filePaths) async {
    try {
      final urls = <String>[];
      for (var filePath in filePaths) {
        final url = await _model.uploadImage(filePath);
        urls.add(url);
      }
      return urls;
    } catch (e) {
      print('Error uploading images: $e');
      throw Exception('Image upload failed. Please try again.');
    }
  }

  // Fetch categories
Future<List<Map<String, dynamic>>> fetchCategories([String? userId]) async {
  try {
    final response = await Supabase.instance.client
        .from('categories')
        .select('id, category_name')
        .then((value) => value);  
    
    return List<Map<String, dynamic>>.from(response);
  } catch (e) {
    print('Error fetching categories: $e');
    throw Exception('Failed to fetch categories.');
  }
}


  // Submit item with user_id from session
  Future<void> submitItem({
    required String name,
    required String description,
    required double price,
    required int category,
    required String contactInformation,
    required List<String> imageUrls,
    required String userId,
  }) async {
    if (name.isEmpty || price <= 0 || contactInformation.isEmpty) {
      throw Exception('Invalid input. Please check your data.');
    }

    try {
      await _model.addItem(
        name: name,
        description: description,
        price: price,
        category: category,
        contactInformation: contactInformation,
        imageUrls: imageUrls,
        userId: userId,
      );
    } catch (e) {
      print('Error submitting item: $e');
      throw Exception('Item submission failed.');
    }
  }
}
