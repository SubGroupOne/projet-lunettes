import 'package:flutter/material.dart';
import 'virtual_try_on_page.dart';

class ChooseFramePage extends StatefulWidget {
  const ChooseFramePage({super.key});

  @override
  State<ChooseFramePage> createState() => _ChooseFramePageState();
}

class _ChooseFramePageState extends State<ChooseFramePage> {
  // Mock data for products
  final List<Map<String, dynamic>> products = [
    {
      'name': 'Lumina Classic',
      'description': 'Aviateur. Noir Onyx',
      'price': '45000,00\F',
      'image': 'assets/glasses.png', // Fallback/reuse
    },
    {
      'name': 'Minimalist Slate',
      'description': 'Carre. Anthracite',
      'price': '120,00\$',
      'image': 'assets/tortoise_glasses.png',
    },
    {
      'name': 'Retro Gold',
      'description': 'Rond. Or 18k',
      'price': '120,00\$',
      'image': 'assets/orange_sunglasses.png',
    },
    {
      'name': 'Ocean Sport',
      'description': 'Sport.Rose',
      'price': '145,00\$',
      'image': 'assets/pink_gold_glasses.png',
    },
    {
      'name': 'Tortoise Shell',
      'description': 'Ovale. Ecaille',
      'price': '145,00\$',
      'image': 'assets/glasses.png', // Reuse or correct if I have more distinctive names, checking usage
    },
    {
      'name': 'ClearVision GenZ',
      'description': 'Rectangle. Cristal',
      'price': '145,00\$',
      'image': 'assets/blue_sunglasses.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Choisir une monture',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD0EAFA), // Light blue bubble
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),

                // Filters Tabs
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      _buildTabButton('Vue', isSelected: true),
                      const SizedBox(width: 8),
                      _buildTabButton('Solaire'),
                      const SizedBox(width: 8),
                      _buildTabButton('Anti-Lumiere\nBleue'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF2F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Rechercher un modele,une marque..',
                        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                        prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      _buildFilterChip('Filtres', isSelected: true),
                      const SizedBox(width: 8),
                      _buildFilterChip('Style'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Couleur'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Visage'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Prix'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),

                // Grid
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Card
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Stack(
                                children: [
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Image.asset(
                                        product['image'],
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 12,
                                    left: 12,
                                    right: 12,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const VirtualTryOnPage()),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        foregroundColor: Colors.white,
                                        minimumSize: const Size(double.infinity, 36),
                                        padding: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      ),
                                      child: const Text('Essayer', style: TextStyle(fontSize: 12)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            product['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            product['description'],
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            product['price'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4A4AFF), // Blueish purple
                              fontSize: 14,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),

            // AI Recommendations Button
            Positioned(
              bottom: 100, // Above nav bar
              right: 24,
              child: FloatingActionButton.extended(
                onPressed: () {},
                backgroundColor: const Color(0xFF1F1F1F),
                foregroundColor: Colors.white,
                label: const Text('Recommandations AI'),
                // icon: const Icon(Icons.stars), // Add if an icon is desired
              ),
            ),
            
            // Bottom Navbar placeholder (Custom to match design more closely)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9F9), // Light grey background
                  border: Border(top: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(Icons.home_outlined, 'Accueil', isSelected: true),
                    _buildNavItem(Icons.receipt_long_outlined, 'Ordonnance'),
                    _buildNavItem(Icons.refresh, 'Commandes'),
                    _buildNavItem(Icons.person_outline, 'Profil'),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String text, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : const Color(0xFFEFF2F9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.black : Colors.grey[500],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFEFF2F9) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, {bool isSelected = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isSelected ? Colors.black : Colors.grey[500]),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isSelected ? Colors.black : Colors.grey[500],
          ),
        ),
      ],
    );
  }
}
