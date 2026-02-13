import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'user_management_page.dart';
import 'optician_management_page.dart';
import 'insurance_management_page.dart';
import 'statistics_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:animate_do/animate_do.dart';

class AdminDashboardPage extends StatefulWidget {
  final String accessToken;

  const AdminDashboardPage({super.key, required this.accessToken});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;
  String? _error;

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await http.get(
        Uri.parse('http://localhost:3000/admin/dashboard/stats'),
        headers: {
          'Authorization': 'Bearer ${widget.accessToken}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _stats = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Erreur: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Administrateur'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStats,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : _buildDashboard(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 20),
          Text('Erreur: $_error'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadStats,
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête de bienvenue
          FadeInDown(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kontrol Panel',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.deepPurple,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      'Dashboard Admin',
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.shield_rounded, color: Colors.deepPurple, size: 28),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Résumé graphique
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: _buildChartOverview(),
          ),
          const SizedBox(height: 32),

          // Cartes statistiques rapides
          const SectionTitle(title: 'Aperçu Statistique'),
          const SizedBox(height: 16),
          _buildStatsGrid(),
          const SizedBox(height: 32),

          // Actions de Gestion
          const SectionTitle(title: 'Gestion du Système'),
          const SizedBox(height: 16),
          _buildManagementSection(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildChartOverview() {
    // Calculer les données pour le graphique (utiliser les stats réelles si disponibles)
    final double userPercent = _stats?['users'] != null ? (_stats!['users'] as num).toDouble() : 0.0;
    final double orderPercent = _stats?['orders'] != null ? (_stats!['orders'] as num).toDouble() : 0.0;
    final double framePercent = _stats?['frames'] != null ? (_stats!['frames'] as num).toDouble() : 0.0;
    
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Répartition Activité',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const Icon(Icons.more_horiz, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 4,
                      centerSpaceRadius: 40,
                      sections: [
                        PieChartSectionData(
                          color: Colors.blueAccent,
                          value: userPercent,
                          radius: 50,
                          showTitle: false,
                        ),
                        PieChartSectionData(
                          color: Colors.greenAccent,
                          value: orderPercent,
                          radius: 50,
                          showTitle: false,
                        ),
                        PieChartSectionData(
                          color: Colors.orangeAccent,
                          value: framePercent,
                          radius: 50,
                          showTitle: false,
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildChartLegend('Utilisateurs', Colors.blueAccent, userPercent),
                      const SizedBox(height: 12),
                      _buildChartLegend('Commandes', Colors.greenAccent, orderPercent),
                      const SizedBox(height: 12),
                      _buildChartLegend('Montures', Colors.orangeAccent, framePercent),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartLegend(String label, Color color, double val) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[700], fontWeight: FontWeight.w500),
        ),
        const Spacer(),
        Text(
          val.toInt().toString(),
          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildManagementSection() {
    return Column(
      children: [
        _buildLuxuryButton(
          icon: Icons.people_rounded,
          title: 'Gestion Utilisateurs',
          subtitle: 'Gérer rôles, comptes et accès',
          color: const Color(0xFF6366F1),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => UserManagementPage(accessToken: widget.accessToken))),
        ),
        const SizedBox(height: 16),
        _buildLuxuryButton(
          icon: Icons.medical_services_rounded,
          title: 'Gestion Opticiens',
          subtitle: 'Supervision des partenaires',
          color: const Color(0xFF10B981),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => OpticianManagementPage(accessToken: widget.accessToken))),
        ),
        const SizedBox(height: 16),
        _buildLuxuryButton(
          icon: Icons.health_and_safety_rounded,
          title: 'Gestion Assurances',
          subtitle: 'Paramétrage des remboursements',
          color: const Color(0xFFF59E0B),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => InsuranceManagementPage(accessToken: widget.accessToken))),
        ),
        const SizedBox(height: 16),
        _buildLuxuryButton(
          icon: Icons.analytics_rounded,
          title: 'Statistiques avancées',
          subtitle: 'Analyses globales et rapports',
          color: const Color(0xFF8B5CF6),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => StatisticsPage(accessToken: widget.accessToken))),
        ),
      ],
    );
  }

  Widget _buildLuxuryButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return FadeInRight(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(color: color.withValues(alpha: 0.1), width: 1),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return FadeInUp(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const Spacer(),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.3,
      children: [
        _buildStatCard(
          title: 'Utilisateurs',
          value: _stats?['users']?.toString() ?? '0',
          icon: Icons.people,
          color: Colors.blue,
        ),
        _buildStatCard(
          title: 'Commandes',
          value: _stats?['orders']?.toString() ?? '0',
          icon: Icons.shopping_cart,
          color: Colors.green,
        ),
        _buildStatCard(
          title: 'Revenus',
          value: '${(double.tryParse(_stats?['revenue']?.toString() ?? '0') ?? 0.0).toStringAsFixed(0)} €',
          icon: Icons.euro,
          color: Colors.orange,
        ),
        _buildStatCard(
          title: 'Montures',
          value: _stats?['frames']?.toString() ?? '0',
          icon: Icons.remove_red_eye,
          color: Colors.purple,
        ),
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF1E293B),
      ),
    );
  }
}
