import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'manage_frames_page.dart';
import 'manage_orders_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OpticianDashboardPage extends StatefulWidget {
  final String accessToken;

  const OpticianDashboardPage({Key? key, required this.accessToken}) : super(key: key);

  @override
  State<OpticianDashboardPage> createState() => _OpticianDashboardPageState();
}

class _OpticianDashboardPageState extends State<OpticianDashboardPage> {
  String? _userName;
  int _orderCount = 0;
  int _frameCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _fetchStats();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName');
    });
  }

  Future<void> _fetchStats() async {
    try {
      // Pour être cohérent avec les autres pages, on utilise http directement ici 
      // car ApiService n'est pas encore totalement utilisé par les pages opticiens
      final ordersResponse = await http.get(
        Uri.parse('http://localhost:3000/orders'),
        headers: {'Authorization': 'Bearer ${widget.accessToken}'},
      );
      
      final framesResponse = await http.get(
        Uri.parse('http://localhost:3000/frames'),
        headers: {'Authorization': 'Bearer ${widget.accessToken}'},
      );

      if (mounted) {
        setState(() {
          if (ordersResponse.statusCode == 200) {
            final List orders = json.decode(ordersResponse.body);
            _orderCount = orders.length;
          }
          if (framesResponse.statusCode == 200) {
            final List frames = json.decode(framesResponse.body);
            _frameCount = frames.length;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching stats: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF0F172A),
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('ESPACE OPTICIEN', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 2)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bonjour,', style: GoogleFonts.inter(color: Colors.white60, fontSize: 16)),
                      Text(_userName ?? 'Opticien', style: GoogleFonts.outfit(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(icon: const Icon(Icons.logout_rounded, color: Colors.white), onPressed: () => _logout(context)),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInUp(
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ManageOrdersPage(accessToken: widget.accessToken))).then((_) => _fetchStats()),
                            child: _buildStatCard('COMMANDES', '$_orderCount', Icons.shopping_bag_rounded, const Color(0xFF6366F1))
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ManageFramesPage(accessToken: widget.accessToken))).then((_) => _fetchStats()),
                            child: _buildStatCard('MONTURES', '$_frameCount', Icons.remove_red_eye_rounded, const Color(0xFF10B981))
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text('ACTIONS MÉTIER', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w900, color: const Color(0xFF6366F1), letterSpacing: 2)),
                  const SizedBox(height: 16),
                  _buildLargeActionCard(
                    context,
                    title: 'Gestion des Montures',
                    desc: 'Mettez à jour le catalogue 3D et les stocks.',
                    icon: Icons.inventory_2_outlined,
                    color: const Color(0xFF6366F1),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ManageFramesPage(accessToken: widget.accessToken))).then((_) => _fetchStats()),
                  ),
                  const SizedBox(height: 16),
                  _buildLargeActionCard(
                    context,
                    title: 'Validation Ordonnances',
                    desc: 'Vérifiez et validez les commandes reçues.',
                    icon: Icons.verified_user_outlined,
                    color: const Color(0xFF10B981),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ManageOrdersPage(accessToken: widget.accessToken))).then((_) => _fetchStats()),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          _isLoading 
            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2))
            : Text(value, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(label, style: GoogleFonts.inter(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildLargeActionCard(BuildContext context, {required String title, required String desc, required IconData icon, required Color color, required VoidCallback onTap}) {
    return FadeInUp(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(desc, style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 13)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
