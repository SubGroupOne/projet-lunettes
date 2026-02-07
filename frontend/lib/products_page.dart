import 'package:flutter/material.dart';
import 'virtual_try_on_page.dart';
import 'cart.dart';
import 'models/product.dart';

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

  late final Map<String, Map<String, List<Product>>> productsByCategory = {
    'Eyeglasses': {
      'Men': EyeglassesProducts.men,
      'Women': EyeglassesProducts.women,
      'Kids': EyeglassesProducts.kids,
    },
    'Sunglasses': {
      'Men': SunglassesProducts.men,
      'Women': SunglassesProducts.women,
      'Kids': SunglassesProducts.kids,
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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFFEBF0FF), const Color(0xFFF5F7FF)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          title: const Text(
            'Produits',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
            unselectedLabelColor: const Color(0xFF999999),
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
                            : Colors.white.withAlpha(200),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          if (selected)
                            BoxShadow(
                              color: const Color(0xFF4A4AFF).withAlpha(80),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                        ],
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
      ),
    );
  }

  Widget _buildProductCard(Product p) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.06 * 255).round()),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
              child: Stack(
                children: [
                  Container(color: const Color(0xFFF8FAFC)),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: p.imageUrl != null
                          ? Image.network(p.imageUrl!, fit: BoxFit.contain)
                          : Image.asset(p.image, fit: BoxFit.contain),
                    ),
                  ),
                  // Price badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0EA5E9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        p.price,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  // Quick try button (overlay)
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
                                builder: (_) => VirtualTryOnPage(
                                  initialFrameAsset: p.tryOnAsset ?? p.image,
                                ),
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
                            Cart.instance.addFromMap(p.toMap());
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Ajouté au panier')),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        p.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (p.discountPercent != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEDD5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '-${p.discountPercent}%',
                          style: const TextStyle(
                            color: Color(0xFFB45309),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  p.desc,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < p.rating.round()
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          size: 15,
                          color: const Color(0xFFFFB703),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      p.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
