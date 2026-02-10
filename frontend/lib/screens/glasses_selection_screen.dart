import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/glasses_models.dart';
import '../services/api_service.dart';

class GlassesSelectionScreen extends StatefulWidget {
  const GlassesSelectionScreen({Key? key}) : super(key: key);

  @override
  State<GlassesSelectionScreen> createState() => _GlassesSelectionScreenState();
}

class _GlassesSelectionScreenState extends State<GlassesSelectionScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<GlassesModel> _glassesList = [];
  String _selectedCategory = 'Tout';
  final List<String> _categories = ['Tout', 'Solaire', 'Optique', 'Homme', 'Femme'];

  @override
  void initState() {
    super.initState();
    _loadGlasses();
  }

  Future<void> _loadGlasses() async {
    setState(() => _isLoading = true);
    try {
      final glasses = await ApiService.getGlasses();
      setState(() {
        _glassesList = glasses;
        _isLoading = false;
      });
    } catch (e) {
      _loadMockData();
    }
  }

  void _loadMockData() {
    setState(() {
      _glassesList = [
        GlassesModel(id: '1', name: 'Aviator Gold', brand: 'Ray-Ban', category: 'Solaire', price: 145, color: 'Or', material: 'Métal', mainImage: 'image.jpeg', images: ['image.jpeg'], isAvailable: true, description: 'La légende intemporelle pour un style affirmé.'),
        GlassesModel(id: '2', name: 'Wayfarer Lite', brand: 'Oakley', category: 'Optique', price: 120, color: 'Noir', material: 'Acétate', mainImage: 'image2.jpg', images: ['image2.jpg'], isAvailable: true, description: 'Légèreté et robustesse pour un confort quotidien.'),
        GlassesModel(id: '3', name: 'Clubmaster V1', brand: 'Ray-Ban', category: 'Solaire', price: 160, color: 'Écaille', material: 'Métal/Bois', mainImage: 'image4.jpg', images: ['image4.jpg'], isAvailable: true, description: 'Un look vintage élégant et sophistiqué.'),
        GlassesModel(id: '4', name: 'Sport Pro', brand: 'Nike', category: 'Sport', price: 135, color: 'Bleu', material: 'Polymère', mainImage: 'image5.jpg', images: ['image5.jpg'], isAvailable: true, description: 'Conçue pour la performance et le mouvement.'),
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          _buildPremiumAppBar(),
          SliverToBoxAdapter(child: _buildCategoryTabs()),
          _isLoading 
              ? const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
              : _buildGlassesGrid(),
        ],
      ),
    );
  }

  Widget _buildPremiumAppBar() {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: true,
      pinned: true,
      backgroundColor: const Color(0xFFF8FAFC).withOpacity(0.8),
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        title: Text(
          'Collection 2026',
          style: GoogleFonts.outfit(color: const Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: IconButton(
            icon: const Icon(Icons.search_rounded, color: Color(0xFF0F172A)),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          bool isSelected = _selectedCategory == _categories[index];
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = _categories[index]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 12, top: 10, bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0F172A) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))] : [],
              ),
              alignment: Alignment.center,
              child: Text(
                _categories[index],
                style: GoogleFonts.inter(
                  color: isSelected ? Colors.white : Colors.grey[600],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGlassesGrid() {
    return SliverPadding(
      padding: const EdgeInsets.all(24),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 24,
          crossAxisSpacing: 20,
          childAspectRatio: 0.72,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final glasses = _glassesList[index];
            return FadeInUp(
              delay: Duration(milliseconds: index * 100),
              child: _buildProductCard(glasses),
            );
          },
          childCount: _glassesList.length,
        ),
      ),
    );
  }

  Widget _buildProductCard(GlassesModel glasses) {
    return GestureDetector(
      onTap: () => _openProductDetail(glasses),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: Stack(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Hero(
                        tag: 'glasses_${glasses.id}',
                        child: Image.asset(
                          'assets/glasses/${glasses.mainImage}',
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Color(0xFFF8FAFC), shape: BoxShape.circle),
                      child: const Icon(Icons.favorite_border_rounded, size: 18, color: Color(0xFF0F172A)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            glasses.brand.toUpperCase(),
            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: const Color(0xFF6366F1), letterSpacing: 1),
          ),
          const SizedBox(height: 4),
          Text(
            glasses.name,
            style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            '${glasses.price.toStringAsFixed(0)} €',
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A)),
          ),
        ],
      ),
    );
  }

  void _openProductDetail(GlassesModel glasses) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ProductDetailScreen(glasses: glasses),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}

class ProductDetailScreen extends StatelessWidget {
  final GlassesModel glasses;

  const ProductDetailScreen({Key? key, required this.glasses}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildImageHeader(context),
              SliverToBoxAdapter(child: _buildDetailsSection()),
            ],
          ),
          _buildQuickActionBottom(context),
        ],
      ),
    );
  }

  Widget _buildImageHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 400.0,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A)),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Center(
          child: Hero(
            tag: 'glasses_${glasses.id}',
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Image.asset('assets/glasses/${glasses.mainImage}', fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            glasses.brand.toUpperCase(),
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF6366F1), letterSpacing: 2),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(glasses.name, style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)))),
              Text('${glasses.price.toStringAsFixed(0)} €', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A))),
            ],
          ),
          const SizedBox(height: 32),
          Text('DESCRIPTION', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey[400], letterSpacing: 1.5)),
          const SizedBox(height: 12),
          Text(glasses.description, style: GoogleFonts.inter(fontSize: 15, color: Colors.grey[700], height: 1.6)),
          const SizedBox(height: 32),
          _buildSpecTile('Matériau', glasses.material),
          _buildSpecTile('Couleur', glasses.color),
          _buildSpecTile('Disponibilité', glasses.isAvailable ? 'En stock' : 'Épuisé'),
          const SizedBox(height: 120), // Padding for CTA
        ],
      ),
    );
  }

  Widget _buildSpecTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 14)),
          Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFF0F172A), fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildQuickActionBottom(BuildContext context) {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              border: const Border(top: BorderSide(color: Colors.black12)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(20)),
                  child: const Icon(Icons.favorite_border_rounded, color: Color(0xFF0F172A)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Text("AJOUTER AU PANIER", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}