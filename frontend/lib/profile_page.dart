import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'order_tracking_page.dart';

class ProfilePage extends StatefulWidget {
  final String accessToken;

  const ProfilePage({super.key, required this.accessToken});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = 'Chargement...';
  String userEmail = '...';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? 'Utilisateur';
      userEmail = prefs.getString('userEmail') ?? 'email@exemple.com';
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Mon Profil', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 24),
            _buildPremiumHeader(),
            const SizedBox(height: 40),
            _buildBentoSettingsGrid(),
            const SizedBox(height: 48),
            _buildLogoutButton(),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _buildModernNavBar(),
    );
  }

  Widget _buildPremiumHeader() {
    return FadeInDown(
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.2), width: 2),
              ),
              child: const CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage('https://i.pravatar.cc/300?u=vision'),
              ),
            ),
            const SizedBox(height: 16),
            Text(userName, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
            Text(userEmail, style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildBentoSettingsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildBentoItem(
                title: 'Ordonnances',
                icon: Icons.assignment_rounded,
                color: const Color(0xFF6366F1),
                onTap: () {},
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildBentoItem(
                title: 'Commandes',
                icon: Icons.shopping_bag_rounded,
                color: const Color(0xFF3B82F6),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrderTrackingPage(accessToken: widget.accessToken))),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildBentoItem(
                title: 'Assurances',
                icon: Icons.verified_user_rounded,
                color: const Color(0xFF10B981),
                onTap: () {},
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildBentoItem(
                title: 'Favoris',
                icon: Icons.favorite_rounded,
                color: const Color(0xFFEF4444),
                onTap: () {},
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildFullWidthBentoItem(
          title: 'Paramètres du compte',
          subtitle: 'Sécurité, Notifications, Confidentialité',
          icon: Icons.settings_rounded,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildBentoItem({required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return FadeInUp(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 20),
              Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15, color: const Color(0xFF0F172A))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFullWidthBentoItem({required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {
    return FadeInUp(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.settings_rounded, color: Color(0xFF0F172A)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF0F172A))),
                    Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500])),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.black26),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return FadeInUp(
      child: SizedBox(
        width: double.infinity,
        height: 64,
        child: TextButton(
          onPressed: _logout,
          style: TextButton.styleFrom(
            backgroundColor: const Color(0xFFEF4444).withOpacity(0.05),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 20),
              const SizedBox(width: 12),
              Text("SE DÉCONNECTER", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFFEF4444), letterSpacing: 1)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernNavBar() {
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black.withOpacity(0.05))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home_max_rounded, "Accueil", false, 0),
          _navItem(Icons.document_scanner_rounded, "Analyses", false, 1),
          _navItem(Icons.shopping_bag_rounded, "Suivi", false, 2),
          _navItem(Icons.person_rounded, "Moi", true, 3),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool isSelected, int index) {
    return GestureDetector(
      onTap: () {
        if (index == 0) Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        if (index == 2) Navigator.push(context, MaterialPageRoute(builder: (_) => OrderTrackingPage(accessToken: widget.accessToken)));
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? const Color(0xFF6366F1) : Colors.black26),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? const Color(0xFF6366F1) : Colors.black26)),
        ],
      ),
    );
  }
}
