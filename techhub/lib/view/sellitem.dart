import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:techhub/controller/sellitem_controller.dart';
import 'package:techhub/model/sellitem_model.dart';

class SellPage extends StatefulWidget {
  const SellPage({super.key});

  @override
  State<SellPage> createState() => _SellPageState();
}

class _SellPageState extends State<SellPage> {
  final SellItemController _controller = SellItemController(SellItemModel());

  // Form controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _contactController = TextEditingController();

  String? selectedCategory;
  List<Map<String, dynamic>> categories = [];
  List<String> imagePaths = [];
  String? userId;
  bool isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      userId = session.user.id;
    }
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    setState(() {
      isLoadingCategories = true;
    });
    
    try {
      final fetchedCategories = await _controller.fetchCategories();
      setState(() {
        categories = fetchedCategories;
        // If categories are loaded and we don't have a selection, select the first one
        if (categories.isNotEmpty && selectedCategory == null) {
          selectedCategory = categories.first['id'].toString();
        }
        isLoadingCategories = false;
      });
    } catch (e) {
      setState(() {
        isLoadingCategories = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching categories: $e')),
        );
      }
    }
  }

  Future<void> pickImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> pickedFiles = await picker.pickMultiImage();

      setState(() {
        imagePaths = pickedFiles.map((file) => file.path).toList();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${imagePaths.length} images selected.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick images: $e')),
        );
      }
    }
  }

  Widget _buildCategoryDropdown() {
    if (isLoadingCategories) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (categories.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No categories available',
            style: TextStyle(color: Colors.red[700]),
          ),
          TextButton(
            onPressed: fetchCategories,
            child: const Text('Retry loading categories'),
          ),
        ],
      );
    }

    return DropdownButtonFormField<String>(
      value: selectedCategory,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      hint: const Text('Select a category'),
      isExpanded: true,
      onChanged: (String? newValue) {
        setState(() {
          selectedCategory = newValue;
        });
      },
      items: categories.map((category) {
        return DropdownMenuItem<String>(
          value: category['id'].toString(),
          child: Text(category['category_name']),
        );
      }).toList(),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a category';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Sell an Item',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'List Your Item for Sale',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // Upload Images Section
              Center(
                child: GestureDetector(
                  onTap: pickImages,
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  'Upload Item Images',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 20),
              // Item Name Field
              const Text(
                'Item Name',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Enter the item name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Item Description Field
              const Text(
                'Item Description',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter a description of the item',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Item Category Dropdown
              const Text(
                'Item Category',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildCategoryDropdown(),
              const SizedBox(height: 20),
              // Price Input Field
              const Text(
                'Price (₱)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter the price of the item',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Contact Information
              const Text(
                'Contact Information',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _contactController,
                decoration: InputDecoration(
                  hintText: 'Enter your contact details',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Submit Button
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (userId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('User session not found')),
                        );
                        return;
                      }

                      if (selectedCategory == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please select a category')),
                        );
                        return;
                      }

                      try {
                        final imageUrls =
                            await _controller.uploadImages(imagePaths);
                        await _controller.submitItem(
                          name: _nameController.text,
                          description: _descriptionController.text,
                          price: double.parse(_priceController.text),
                          category: int.parse(selectedCategory!),
                          contactInformation: _contactController.text,
                          imageUrls: imageUrls,
                          userId: userId!,
                        );
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Item listed successfully!')),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed: $e')),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Submit Item',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}