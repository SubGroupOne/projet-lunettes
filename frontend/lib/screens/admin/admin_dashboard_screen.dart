// lib/screens/admin/admin_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:animate_do/animate_do.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../models/glasses_models.dart';
import '../../widgets/glasses_carousel.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isLoading = true;
  StatisticsModel? _statistics;

  // ✅ CORRECTION : Utiliser les VRAIS noms de tes images
  final List<GlassesModel> maBoutique = [
    GlassesModel(
      id: '1',
      name: 'Aviator Dark',
      brand: 'Ray-Ban',
      category: 'solaire',
      price: 45000,
      color: 'Noir',
      material: 'Métal',
      mainImage: 'assets/glasses/image.jpeg',
      images: ['assets/glasses/image.jpeg'],
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
      mainImage: 'assets/glasses/image2.jpg',  // ⬅️ CORRIGÉ
      images: ['assets/glasses/image2.jpg'],
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
      mainImage: 'assets/glasses/image4.jpg',  // ⬅️ CORRIGÉ
      images: ['assets/glasses/image4.jpg'],
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
      mainImage: 'assets/glasses/image5.jpg',  // ⬅️ CORRIGÉ
      images: ['assets/glasses/image5.jpg'],
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
      mainImage: 'assets/glasses/image6.jpg',  // ⬅️ CORRIGÉ
      images: ['assets/glasses/image6.jpg'],
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
      mainImage: 'assets/glasses/image7.jpg',  // ⬅️ CORRIGÉ
      images: ['assets/glasses/image7.jpg'],
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
      mainImage: 'assets/glasses/image8.jpg',  // ⬅️ CORRIGÉ
      images: ['assets/glasses/image8.jpg'],
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
      mainImage: 'assets/glasses/image9.jpeg',  // ⬅️ CORRIGÉ
      images: ['assets/glasses/image9.jpeg'],
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
      mainImage: 'assets/glasses/imagee.jpeg',
      images: ['assets/glasses/imagee.jpeg'],
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
      mainImage: 'assets/glasses/images.jpeg',
      images: ['assets/glasses/images.jpeg'],
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
      mainImage: 'assets/glasses/img1.jpg',  // ⬅️ CORRIGÉ
      images: ['assets/glasses/img1.jpg'],
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
      mainImage: 'assets/glasses/img3.jpg',  // ⬅️ CORRIGÉ
      images: ['assets/glasses/img3.jpg'],
      isAvailable: true,
      description: 'Monture légère et confortable.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);

    try {
      final stats = await ApiService.getStatistics();
      setState(() {
        _statistics = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _statistics = _generateMockStatistics();
        _isLoading = false;
      });
    }
  }

  StatisticsModel _generateMockStatistics() {
    return StatisticsModel(
      totalUsers: 1245,
      totalOpticiens: 45,
      totalOrders: 3890,
      totalRevenue: 45678900,
      pendingOrders: 234,
      completedOrders: 3656,
      monthlyRevenue: [
        MonthlyData(month: 'Jan', revenue: 3500000),
        MonthlyData(month: 'Fév', revenue: 4200000),
        MonthlyData(month: 'Mar', revenue: 3800000),
        MonthlyData(month: 'Avr', revenue: 5100000),
        MonthlyData(month: 'Mai', revenue: 4900000),
        MonthlyData(month: 'Juin', revenue: 5600000),
      ],
      ordersByCategory: [
        CategoryData(category: 'Homme', count: 1245),
        CategoryData(category: 'Femme', count: 1567),
        CategoryData(category: 'Enfant', count: 678),
        CategoryData(category: 'Sport', count: 400),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Tableau de bord',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadStatistics,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInUp(
                child: _buildStatsCards(),
              ),

              const SizedBox(height: 24),

              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: _buildRevenueChart(),
              ),

              const SizedBox(height: 24),

              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: _buildCategoryChart(),
              ),

              const SizedBox(height: 24),

              // SECTION APERÇU DU CATALOGUE
              FadeInUp(
                delay: const Duration(milliseconds: 500),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Aperçu du catalogue',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 450,
                      child: GlassesCarousel(
                        glassesList: maBoutique,
                        onGlassesSelected: (glasses) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Lunette sélectionnée : ${glasses.name}'),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              FadeInUp(
                delay: const Duration(milliseconds: 600),
                child: _buildQuickActions(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    final stats = [
      {
        'title': 'Utilisateurs',
        'value': _statistics!.totalUsers.toString(),
        'icon': Icons.people,
        'color': Colors.blue,
        'trend': '+12%',
      },
      {
        'title': 'Opticiens',
        'value': _statistics!.totalOpticiens.toString(),
        'icon': Icons.store,
        'color': Colors.green,
        'trend': '+5%',
      },
      {
        'title': 'Commandes',
        'value': _statistics!.totalOrders.toString(),
        'icon': Icons.shopping_cart,
        'color': Colors.orange,
        'trend': '+23%',
      },
      {
        'title': 'Revenus',
        'value': '${(_statistics!.totalRevenue / 1000000).toStringAsFixed(1)}M',
        'icon': Icons.attach_money,
        'color': Colors.purple,
        'trend': '+18%',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (stat['color'] as Color).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      stat['icon'] as IconData,
                      color: stat['color'] as Color,
                      size: 24,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      stat['trend'] as String,
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stat['value'] as String,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    stat['title'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
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

  Widget _buildRevenueChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Revenus mensuels',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${(value / 1000000).toInt()}M',
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < _statistics!.monthlyRevenue.length) {
                          return Text(
                            _statistics!.monthlyRevenue[value.toInt()].month,
                            style: const TextStyle(fontSize: 10),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _statistics!.monthlyRevenue
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value.revenue))
                        .toList(),
                    isCurved: true,
                    color: Theme.of(context).primaryColor,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Commandes par catégorie',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: _statistics!.ordersByCategory.map((category) {
                  final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple];
                  final index = _statistics!.ordersByCategory.indexOf(category);

                  return PieChartSectionData(
                    value: category.count.toDouble(),
                    title: '${category.count}',
                    color: colors[index % colors.length],
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: _statistics!.ordersByCategory.map((category) {
              final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple];
              final index = _statistics!.ordersByCategory.indexOf(category);

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors[index % colors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    category.category,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {
        'title': 'Gérer utilisateurs',
        'icon': Icons.people,
        'color': Colors.blue,
        'route': '/admin/users',
      },
      {
        'title': 'Gérer opticiens',
        'icon': Icons.store,
        'color': Colors.green,
        'route': '/admin/opticiens',
      },
      {
        'title': 'Gérer assurances',
        'icon': Icons.shield,
        'color': Colors.orange,
        'route': '/admin/insurances',
      },
      {
        'title': 'Voir rapports',
        'icon': Icons.analytics,
        'color': Colors.purple,
        'route': '/admin/reports',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actions rapides',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return InkWell(
              onTap: () {
                Navigator.pushNamed(context, action['route'] as String);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (action['color'] as Color).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (action['color'] as Color).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      action['icon'] as IconData,
                      color: action['color'] as Color,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        action['title'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: action['color'] as Color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
