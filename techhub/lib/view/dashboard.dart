import 'package:flutter/material.dart';
import 'package:techhub/view/cart.dart';
import 'package:techhub/view/message.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Product> devices = [
      Product("IPhone 15", "₱ 44,990", "lib/assets/images/iphone15.jpg"),
      Product("ASUS TUF", "₱ 45,000", "lib/assets/images/asusTUF.jpg"),
      Product("ACER C24-1800", "₱ 46,999", "lib/assets/images/acerC24.jpg"),
    ];

    final List<Product> hardware = [
      Product("MSI GM4 Mouse", "₱ 3,499", "lib/assets/images/msiMouse.jpg"),
      Product("MSI VIGOR GK71", "₱ 5,400", "lib/assets/images/msiVigor.jpg"),
      Product("ASUS TFU H3", "₱ 2,100", "lib/assets/images/asusH3.jpg"),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Spacer(),
            const CircleAvatar(
              backgroundColor: Color.fromARGB(255, 0, 0, 0),
              child: Icon(Icons.headset, color: Color.fromARGB(255, 255, 255, 255)),
            ),
            const SizedBox(width: 5),
            const Text(
              "Tech-Hub",
              style: TextStyle(color: Colors.white),
            ),
            const Spacer(),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartApp()),
                );
              },
              icon: const Icon(Icons.shopping_cart),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              const TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: "Search Product",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Devices Section
              const Text(
                "Devices",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              SizedBox(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    return ProductCard(product: devices[index]);
                  },
                ),
              ),
              const SizedBox(height: 20),
              // Hardware Section
              const Text(
                "Hardware",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              SizedBox(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: hardware.length,
                  itemBuilder: (context, index) {
                    return ProductCard(product: hardware[index]);
                  },
                ),
              ),
              const SizedBox(height: 20),
              // Recently Viewed Section
              const Text(
                "Recently Viewed",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Container(
                height: 100,
                color: Colors.grey[200],
                child: const Center(
                  child: Text("No recently viewed items."),
                ),
              ),
            ],
          ),
        ),
      ),

      //bottom navigation bar

      bottomNavigationBar: BottomNavigationBar(
         type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.blue,
  selectedItemColor: Colors.white,
  unselectedItemColor: const Color.fromARGB(255, 0, 0, 0), 
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Cart",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: "Messages",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile", 
          ), 
        ],
        onTap: (index) {
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Message()),
            );
          }
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CartApp()),
            );
          }
        },
      ),
    );
  }
}

class Product {
  final String name;
  final String price;
  final String image;

  Product(this.name, this.price, this.image);
}

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({required this.product, super.key});

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
            // Product Image
            Container(
              width: 100,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: AssetImage(product.image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 5),
            // Product Name
            Text(
              product.name,
              style: const TextStyle(fontSize: 10),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
            // Product Price
            Text(
              product.price,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 5),
            // Add to Cart Button
            SizedBox(
              width: double.infinity,
              height: 25,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.orange,
                ),
                child: const Text(
                  "Add to Cart",
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
