import 'package:flutter/material.dart';
import 'virtual_try_on_page.dart';
import 'cart.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage>
    with SingleTickerProviderStateMixin {
  final List<String> categories = ['Eyeglasses', 'Sunglasses'];
  final List<String> demographics = ['Men', 'Women', 'Kids'];

  late TabController _tabController;
  String _selectedDemo = 'Men';

  final Map<String, Map<String, List<Map<String, String>>>> productsByCategory =
      {
        'Eyeglasses': {
          'Men': [
            {
              'name': 'Lumina Classic',
              'desc': 'Aviateur. Noir Onyx',
              'price': '45 000 F',
              'image': 'assets/glasses.png',
            },
            {
              'name': 'Minimalist Slate',
              'desc': 'Carré. Anthracite',
              'price': '38 000 F',
              'image': 'assets/tortoise_glasses.png',
            },
          ],
          'Women': [
            {
              'name': 'Retro Gold',
              'desc': 'Rond. Or 18k',
              'price': '52 000 F',
              'image': 'assets/orange_sunglasses.png',
            },
            {
              'name': 'Tortoise Charm',
              'desc': 'Ovale. Écaille',
              'price': '41 000 F',
              'image': 'assets/glasses.png',
            },
          ],
          'Kids': [
            {
              'name': 'Mini Clear',
              'desc': 'Pour enfants',
              'price': '20 000 F',
              'image': 'assets/blue_sunglasses.png',
            },
          ],
        },
        'Sunglasses': {
          'Men': [
            {
              'name': 'Ocean Sport',
              'desc': 'Sport. Polarized',
              'price': '60 000 F',
              'image': 'assets/pink_gold_glasses.png',
            },
          ],
          'Women': [
            {
              'name': 'Sun Luxe',
              'desc': 'Cat-eye. Or',
              'price': '72 000 F',
              'image': 'assets/orange_sunglasses.png',
            },
          ],
          'Kids': [
            {
              'name': 'Sunny Jr',
              'desc': 'Coloré pour enfants',
              'price': '25 000 F',
              'image': 'assets/glasses.png',
            },
          ],
        },
      };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Produits',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/payment'),
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF4A4AFF),
          labelColor: Colors.black,
          tabs: categories.map((c) => Tab(text: c)).toList(),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: demographics.map((demo) {
                final selected = _selectedDemo == demo;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDemo = demo),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF4A4AFF)
                          : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      demo,
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: categories.map((category) {
                final products =
                    productsByCategory[category]![_selectedDemo] ?? [];
                if (products.isEmpty) {
                  return Center(
                    child: Text(
                      'Aucun produit pour $category / $_selectedDemo',
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.68,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final p = products[index];
                      return _buildProductCard(p);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, String> p) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
              child: Container(
                color: Colors.white,
                child: Stack(
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Image.asset(p['image']!, fit: BoxFit.contain),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      left: 8,
                      right: 8,
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const VirtualTryOnPage(),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Essayer'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: () {
                              Cart.instance.addFromMap(p);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Ajouté au panier'),
                                ),
                              );
                              Navigator.pushNamed(context, '/payment');
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF4A4AFF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Acheter'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p['name']!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  p['desc']!,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 6),
                Text(
                  p['price']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A4AFF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
