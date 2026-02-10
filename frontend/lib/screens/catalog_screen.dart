import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/cart.dart';
import '../services/session_service.dart';
import 'virtual_try_on_screen.dart';
import '../payment_confirmation_page.dart';
import '../login_page.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({Key? key}) : super(key: key);

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  String _activeCategory = 'TOUT';
  final List<String> _categories = ['TOUT', 'VUE', 'SOLAIRE', 'HOMME', 'FEMME', 'ENFANT'];

  List<Product> get _allProducts {
    List<Product> products = [];
    products.addAll(EyeglassesProducts.men);
    products.addAll(EyeglassesProducts.women);
    products.addAll(EyeglassesProducts.kids);
    products.addAll(SunglassesProducts.men);
    products.addAll(SunglassesProducts.women);
    products.addAll(SunglassesProducts.kids);
    return products;
  }

  List<Product> get _filteredProducts {
    if (_activeCategory == 'TOUT') return _allProducts;
    
    if (_activeCategory == 'VUE') {
      return [...EyeglassesProducts.men, ...EyeglassesProducts.women, ...EyeglassesProducts.kids];
    } else if (_activeCategory == 'SOLAIRE') {
      return [...SunglassesProducts.men, ...SunglassesProducts.women, ...SunglassesProducts.kids];
    } else if (_activeCategory == 'HOMME') {
      return [...EyeglassesProducts.men, ...SunglassesProducts.men];
    } else if (_activeCategory == 'FEMME') {
      return [...EyeglassesProducts.women, ...SunglassesProducts.women];
    } else if (_activeCategory == 'ENFANT') {
      return [...EyeglassesProducts.kids, ...SunglassesProducts.kids];
    }
    return _allProducts;
  }

  double _parsePrice(String priceStr) {
    // Nettoie "45 000 F" en 45000.0
    String clean = priceStr.replaceAll(RegExp(r'[^0-9]'), '');
    return double.tryParse(clean) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Catalogue', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF0F172A),
        actions: [
          Consumer<Cart>(
            builder: (context, cart, _) => Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  onPressed: () => _navigateToPayment(context),
                  icon: const Icon(Icons.shopping_cart_outlined),
                ),
                if (cart.itemCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Color(0xFF6366F1), shape: BoxShape.circle),
                      child: Text(
                        cart.itemCount.toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildCategoryFilter(),
          Expanded(
            child: _filteredProducts.isEmpty
                ? const Center(child: Text('Aucun produit trouvé'))
                : GridView.builder(
                    padding: const EdgeInsets.all(24),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.62,
                    ),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      return FadeInUp(
                        delay: Duration(milliseconds: index * 50),
                        child: _buildProductCard(context, product),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: Consumer<Cart>(
        builder: (context, cart, _) => cart.itemCount > 0 
          ? SafeArea(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
                ),
                child: ElevatedButton(
                  onPressed: () => _navigateToPayment(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 54),
                  ),
                  child: Text('PAYER (${cart.totalAmount.toStringAsFixed(0)} F)', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                ),
              ),
            )
          : const SizedBox.shrink(),
      ),
    );
  }

  void _navigateToPayment(BuildContext context) {
    final session = Provider.of<SessionService>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);

    if (!session.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez vous connecter pour payer')),
      );
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
      return;
    }

    if (cart.itemCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Votre panier est vide')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentConfirmationPage(
          totalAmount: cart.totalAmount,
          accessToken: session.token ?? '',
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 60,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _activeCategory == cat;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
            child: ChoiceChip(
              label: Text(cat, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : const Color(0xFF0F172A))),
              selected: isSelected,
              onSelected: (val) => setState(() => _activeCategory = cat),
              selectedColor: const Color(0xFF0F172A),
              backgroundColor: const Color(0xFFF1F5F9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: Image.asset(
                    product.image,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
                    ),
                  ),
                ),
                if (product.discountPercent != null)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '-${product.discountPercent}%',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: FloatingActionButton.small(
                    heroTag: null,
                    onPressed: () {
                      Provider.of<Cart>(context, listen: false).addItem(
                        product.name,
                        product.name,
                        _parsePrice(product.price),
                        product.image,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${product.name} ajouté au panier'),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    backgroundColor: const Color(0xFF0F172A),
                    child: const Icon(Icons.add_shopping_cart_rounded, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  product.desc,
                  style: GoogleFonts.inter(fontSize: 10, color: Colors.grey[500]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.price,
                      style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF6366F1)),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFB800)),
                        Text(
                          product.rating.toString(),
                          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const VirtualTryOnScreen()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      side: const BorderSide(color: Color(0xFFF1F5F9)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('ESSAYER 3D', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
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
