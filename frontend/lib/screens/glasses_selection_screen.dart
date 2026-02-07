// lib/screens/glasses_selection_screen.dart

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../models/glasses_models.dart';
import '../services/api_service.dart';
import '../widgets/glasses_carousel.dart';
import '../widgets/glasses_grid.dart';

class GlassesSelectionScreen extends StatefulWidget {
  const GlassesSelectionScreen({Key? key}) : super(key: key);

  @override
  State<GlassesSelectionScreen> createState() => _GlassesSelectionScreenState();
}

class _GlassesSelectionScreenState extends State<GlassesSelectionScreen>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  List<GlassesModel> _glassesList = [];
  bool _isCarouselView = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadGlasses();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadGlasses() async {
    setState(() => _isLoading = true);

    try {
      // Charger les lunettes depuis l'API
      final glasses = await ApiService.getGlasses();
      setState(() {
        _glassesList = glasses;
        _isLoading = false;
      });
    } catch (e) {
      // Si l'API n'est pas disponible, utiliser des données de test
      setState(() {
        _glassesList = [
          GlassesModel(
            id: '1',
            name: 'Aviator Dark',
            brand: 'Ray-Ban',
            category: 'solaire',
            price: 45000,
            color: 'Noir',
            material: 'Métal',
            mainImage: 'image.jpeg',
            images: ['image.jpeg'],
            isAvailable: true,
            description: 'Protection UV maximale.',
          ),
          GlassesModel(
            id: '2',
            name: 'Modèle Élégant',
            brand: 'Oakley',
            category: 'homme',
            price: 27000,
            color: 'Noir',
            material: 'Acétate',
            mainImage: 'image2.jpg',
            images: ['image2.jpg'],
            isAvailable: true,
            description: 'Monture légère et confortable.',
          ),
          GlassesModel(
            id: '3',
            name: 'Beautiful',
            brand: 'Oakley',
            category: 'homme',
            price: 27000,
            color: 'Noir',
            material: 'Acétate',
            mainImage: 'image4.jpg',
            images: ['image4.jpg'],
            isAvailable: true,
            description: 'Monture légère et confortable.',
          ),
          GlassesModel(
            id: '4',
            name: 'Magnifique',
            brand: 'Oakley',
            category: 'femme',
            price: 26000,
            color: 'Noir',
            material: 'Acétate',
            mainImage: 'image5.jpg',
            images: ['image5.jpg'],
            isAvailable: true,
            description: 'Monture légère et confortable.',
          ),
          GlassesModel(
            id: '5',
            name: 'Mode',
            brand: 'Oakley',
            category: 'femme',
            price: 20000,
            color: 'Noir',
            material: 'Acétate',
            mainImage: 'image6.jpg',
            images: ['image6.jpg'],
            isAvailable: true,
            description: 'Monture légère et confortable.',
          ),
          GlassesModel(
            id: '6',
            name: 'Modè',
            brand: 'Oakley',
            category: 'homme',
            price: 17000,
            color: 'Noir',
            material: 'Acétate',
            mainImage: 'image7.jpg',
            images: ['image7.jpg'],
            isAvailable: true,
            description: 'Monture légère et confortable.',
          ),
          GlassesModel(
            id: '7',
            name: 'MoÉlégant',
            brand: 'Oakley',
            category: 'femme',
            price: 21000,
            color: 'Noir',
            material: 'Acétate',
            mainImage: 'image8.jpg',
            images: ['image8.jpg'],
            isAvailable: true,
            description: 'Monture légère et confortable.',
          ),
          GlassesModel(
            id: '8',
            name: 'Modèle Élé',
            brand: 'Oakley',
            category: 'homme',
            price: 29000,
            color: 'Noir',
            material: 'Acétate',
            mainImage: 'image9.jpeg',
            images: ['image9.jpeg'],
            isAvailable: true,
            description: 'Monture légère et confortable.',
          ),
          GlassesModel(
            id: '9',
            name: 'Modèle Égant',
            brand: 'Oakley',
            category: 'homme',
            price: 7000,
            color: 'Noir',
            material: 'Acétate',
            mainImage: 'imagee.jpeg',
            images: ['imagee.jpeg'],
            isAvailable: true,
            description: 'Monture légère et confortable.',
          ),
          GlassesModel(
            id: '10',
            name: 'Modle Élégant',
            brand: 'Oakley',
            category: 'homme',
            price: 27000,
            color: 'Noir',
            material: 'Acétate',
            mainImage: 'images.jpeg',
            images: ['images.jpeg'],
            isAvailable: true,
            description: 'Monture légère et confortable.',
          ),
          GlassesModel(
            id: '11',
            name: 'dèle Élégant',
            brand: 'Oakley',
            category: 'homme',
            price: 27000,
            color: 'Noir',
            material: 'Acétate',
            mainImage: 'image1.jpeg',
            images: ['image1.jpeg'],
            isAvailable: true,
            description: 'Monture légère et confortable.',
          ),
          GlassesModel(
            id: '12',
            name: 'Modèle Élégant',
            brand: 'Oakley',
            category: 'homme',
            price: 37000,
            color: 'Noir',
            material: 'Acétate',
            mainImage: 'image3.jpeg',
            images: ['image3.jpeg'],
            isAvailable: true,
            description: 'Monture légère et confortable.',
          ),
        ];
        _isLoading = false;
      });
    }
  }

  void _onGlassesSelected(GlassesModel glasses) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildGlassesDetailSheet(glasses),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: FadeInDown(
          child: const Text(
            'Choisir une monture',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          FadeInDown(
            delay: const Duration(milliseconds: 200),
            child: IconButton(
              icon: Icon(
                _isCarouselView ? Icons.grid_view : Icons.view_carousel,
                color: Colors.black87,
              ),
              onPressed: () {
                setState(() {
                  _isCarouselView = !_isCarouselView;
                });
              },
            ),
          ),
          FadeInDown(
            delay: const Duration(milliseconds: 300),
            child: IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.black87),
              onPressed: _showFilterDialog,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadGlasses,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: _isCarouselView
              ? SingleChildScrollView(
            key: const ValueKey('carousel'),
            child: Column(
              children: [
                const SizedBox(height: 20),
                FadeInUp(
                  child: GlassesCarousel(
                    glassesList: _glassesList,
                    onGlassesSelected: _onGlassesSelected,
                  ),
                ),
              ],
            ),
          )
              : GlassesGrid(
            key: const ValueKey('grid'),
            glassesList: _glassesList,
            onGlassesSelected: _onGlassesSelected,
          ),
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtres'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Prix maximum'),
            Slider(
              value: 50000,
              min: 0,
              max: 100000,
              divisions: 20,
              label: '50000 FCFA',
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            const Text('Marque'),
            // Ajouter d'autres filtres ici
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Appliquer les filtres
            },
            child: const Text('Appliquer'),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassesDetailSheet(GlassesModel glasses) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            children: [
              // Barre de drag
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // ✅ CORRECTION 1 : Contrainte de largeur ajoutée pour éviter l'overflow
              Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: PageView.builder(
                  itemCount: glasses.images.length,
                  itemBuilder: (context, index) {
                    // ✅ CORRECTION 2 : Chemin d'image correct avec gestion d'erreur robuste
                    final imagePath = glasses.images[index].contains('assets/')
                        ? glasses.images[index]
                        : 'assets/glasses/${glasses.images[index]}';

                    return ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                                const SizedBox(height: 8),
                                Text(
                                  'Image non trouvée',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  glasses.images[index],
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Nom et prix
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          glasses.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          glasses.brand,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${glasses.price.toStringAsFixed(0)} FCFA',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Description
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                glasses.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 20),

              // Caractéristiques
              const Text(
                'Caractéristiques',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildSpecRow('Catégorie', glasses.category),
              _buildSpecRow('Couleur', glasses.color),
              _buildSpecRow('Matériau', glasses.material),

              const SizedBox(height: 30),

              // ✅ CORRECTION 3 : Correction de l'overflow dans les boutons
              Row(
                children: [
                  Flexible(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Ajouter aux favoris'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: glasses.isAvailable
                          ? () {
                        Navigator.pop(context); // Ferme le bottom sheet
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Module IA en cours de développement pour ${glasses.name}'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                          : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Essayer maintenant'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}