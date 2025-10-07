import 'package:flutter/material.dart';

class ProductDetailScreen extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({Key? key, required this.product})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product['title'])),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Image.network(product['image'], height: 200, fit: BoxFit.cover),
            const SizedBox(height: 16),
            Text(product['description'], style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Text('₱${product['price']}',
                style: const TextStyle(fontSize: 20, color: Colors.green)),
            const Spacer(),
            ElevatedButton.icon(
              icon: const Icon(Icons.shopping_cart),
              label: const Text('Add to Cart'),
              onPressed: () {
                // Add cart logic here
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
