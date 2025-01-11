import 'package:flutter/material.dart';
import 'package:techhub/view/dashboard.dart';

void main() {
  runApp(CartApp());
}

class CartApp extends StatelessWidget {
  const CartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CartScreen(),
    );
  }
}

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CART'),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => DashboardPage()));
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(value: false, onChanged: (value) {}),
                    Text('Select'),
                  ],
                ),
                Row(
                  children: [
                    Checkbox(value: false, onChanged: (value) {}),
                    Text('Delete'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return CartItem(
                  imageUrl: item['imageUrl']!,
                  title: item['title']!,
                  price: item['price']!,
                  description: item['description']!,
                  totalPrice: item['totalPrice']!,
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Center(
                child: Text(
                  'Check Out',
                  style: TextStyle(fontSize: 18.0, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final List<Map<String, String>> cartItems = [
  {
    'imageUrl': 'lib/assets/images/acerC24.jpg',
    'title': 'ACER C24-1800',
    'price': '₱46,999',
    'description': 'Intel Core i3-1315u\n8GB DDR4 RAM',
    'totalPrice': '46,999',
  },
  {
    'imageUrl': 'lib/assets/images/msiVigor.jpg',
    'title': 'MSI VIGOR GK 71',
    'price': '₱5,400',
    'description': 'Mechanical keyboard\nLightweight switches',
    'totalPrice': '5,400',
  },
  {
    'imageUrl': 'lib/assets/images/msiMouse.jpg',
    'title': 'MSI GM4 Mouse',
    'price': '₱3,499',
    'description': 'Multi programmable button\nUSB Mouse',
    'totalPrice': '3,499',
  },
];

class CartItem extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String price;
  final String description;
  final String totalPrice;

  const CartItem({super.key, 
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.description,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  imageUrl,
                  width: 80.0,
                  height: 80.0,
                  fit: BoxFit.cover,
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text('Edit'),
                          ),
                        ],
                      ),
                      Text(
                        price,
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        description,
                        style: TextStyle(fontSize: 12.0, color: Colors.grey[700]),
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Price: $totalPrice',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0,
                              )),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.remove_circle_outline),
                                color: Colors.blue,
                              ),
                              Text('1'),
                              IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.add_circle_outline),
                                color: Colors.blue,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
