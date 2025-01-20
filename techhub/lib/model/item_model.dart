class Item {
  final String id; // UUID (String)
  final String name;
  final String description;
  final String price;
  final String? sellerId; // seller_id is a UUID (String)
  final String sellerName;
  final int? category; // category is an int
  final String imageUrl;
  final String categoryName;
  late final bool? status; // Add the status field here

  Item({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.sellerId,
    this.sellerName = '',
    this.category,
    required this.imageUrl,
    this.categoryName = 'Uncategorized',
    this.status, // Initialize the status field
  });

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'] as String, // id is a String (UUID)
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
      price: _convertPrice(map['price']),
      sellerId: map['user_id'] as String?, // seller_id is String (UUID)
      sellerName: map['seller_name'] as String? ?? '',  // Assuming this is fetched
      category: map['category'] is String
          ? int.tryParse(map['category']) ?? 0 // Ensure it's converted to int if it's a String
          : map['category'] as int? ?? 0, // Otherwise, treat it as an int
      imageUrl: _processImageUrls(map['image_urls']), // Process image URLs
      categoryName: _extractCategoryName(map),
      status: map['status'] as bool?, // Map the status field
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'user_id': sellerId,
      'category': category,
      'image_urls': imageUrl,
      'status': status, // Include status in the map
    };
  }

  static String _convertPrice(dynamic price) {
    if (price == null) return '0';
    if (price is String) return price;
    if (price is int) return price.toString();
    if (price is double) return price.toString();
    return '0';
  }

  static String _processImageUrls(dynamic imageUrls) {
    if (imageUrls == null || imageUrls is! List) {
      return '';
    }

    if (imageUrls.isNotEmpty && imageUrls[0] is String) {
      return imageUrls[0]; // Take the first image URL
    }
    return ''; // Return empty string if no valid URL is found
  }

  static String _extractCategoryName(Map<String, dynamic> map) {
    try {
      if (map['categories'] is Map) {
        final categoryMap = map['categories'] as Map<String, dynamic>;
        return categoryMap['category_name'] as String? ?? 'Uncategorized';
      }
      return map['category_name'] as String? ?? 'Uncategorized';
    } catch (e) {
      print('Category name extraction error: $e');
      return 'Uncategorized';
    }
  }
}
