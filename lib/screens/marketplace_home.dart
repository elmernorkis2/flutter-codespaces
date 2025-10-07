import 'package:flutter/material.dart';

class MarketplaceHome extends StatefulWidget {
  @override
  State<MarketplaceHome> createState() => _MarketplaceHomeState();
}

class _MarketplaceHomeState extends State<MarketplaceHome>
    with TickerProviderStateMixin {
  final List<Map<String, dynamic>> categories = [
    {
      'label': 'Food',
      'icon': Icons.fastfood,
      'image': 'https://via.placeholder.com/60x60?text=Food'
    },
    {
      'label': 'Fashion',
      'icon': Icons.checkroom,
      'image': 'https://via.placeholder.com/60x60?text=Fashion'
    },
    {
      'label': 'Gadgets',
      'icon': Icons.devices,
      'image': 'https://via.placeholder.com/60x60?text=Gadgets'
    },
    {
      'label': 'Services',
      'icon': Icons.miscellaneous_services,
      'image': 'https://via.placeholder.com/60x60?text=Services'
    },
    {
      'label': 'Transportation',
      'icon': Icons.directions_car,
      'image': 'https://via.placeholder.com/60x60?text=Transport'
    },
  ];

  final Map<String, List<String>> samplePosts = {
    'Food': ['Burger ₱120', 'Sushi ₱250', 'Milk Tea ₱80'],
    'Fashion': ['Denim Jacket ₱799', 'Sneakers ₱1299'],
    'Gadgets': ['Smartwatch ₱1999', 'Bluetooth Speaker ₱899'],
    'Services': ['Home Cleaning ₱500', 'Haircut ₱300'],
    'Transportation': ['Bike Rental ₱150/hr', 'Carpool ₱50/trip'],
  };

  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      categories.length,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(seconds: 1),
      )..repeat(reverse: true),
    );

    _animations = _controllers
        .map((controller) => Tween(begin: 0.3, end: 1.0).animate(controller))
        .toList();
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Marketplace')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((category) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.lightBlue[50],
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withAlpha(40),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            category['image'],
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          category['label'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              ...List.generate(categories.length, (index) {
                final label = categories[index]['label'];
                final posts = samplePosts[label] ?? [];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        FadeTransition(
                          opacity: _animations[index],
                          child: Icon(
                            categories[index]['icon'],
                            color: Colors.blueAccent,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$label Posts',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...posts.map((post) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withAlpha(30),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Text(post),
                          ),
                        )),
                    const SizedBox(height: 20),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
