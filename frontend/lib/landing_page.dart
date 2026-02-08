import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'screens/virtual_try_on_screen.dart';
import 'screens/prescription_scan_screen.dart';
import 'screens/insurance_simulation_screen.dart';
import 'package:provider/provider.dart';
import 'services/session_service.dart';
import 'profile_page.dart';
import 'services/cart.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  String _activeFilter = 'TOUT';
  final List<String> _filters = ['TOUT', 'HOMME', 'FEMME', 'SOLAIRE', 'LUXE'];

  final List<Map<String, String>> _featuredGlasses = [
    {'name': 'Aviator Classic', 'brand': 'Ray-Ban', 'image': 'assets/glasses/image.jpeg', 'price': '145 €'},
    {'name': 'Wayfarer Noir', 'brand': 'Oakley', 'image': 'assets/glasses/image2.jpg', 'price': '120 €'},
    {'name': 'Clubmaster Gold', 'brand': 'Ray-Ban', 'image': 'assets/glasses/image4.jpg', 'price': '160 €'},
    {'name': 'Sport X-Extreme', 'brand': 'Nike', 'image': 'assets/glasses/image5.jpg', 'price': '135 €'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildNewHero(context),
            _buildTrustBar(),
            const SizedBox(height: 32),
            _buildProcessSection(),
            const SizedBox(height: 48),
            _buildBentoSection(context),
            const SizedBox(height: 48),
            _buildFeaturedCarousel(),
            const SizedBox(height: 48),
            _buildCatalogGridWithFilters(),
            const SizedBox(height: 64),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildTrustBar() {
    return Container(
      height: 60,
      width: double.infinity,
      color: Colors.white,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          _trustBadge(Icons.star_rounded, '4.9/5 (10k clients)'),
          const SizedBox(width: 32),
          _trustBadge(Icons.verified_user_rounded, 'Opticiens diplômés'),
          const SizedBox(width: 32),
          _trustBadge(Icons.lock_rounded, 'Verres Premium'),
          const SizedBox(width: 32),
          _trustBadge(Icons.local_shipping_rounded, 'Livraison 48h'),
        ],
      ),
    );
  }

  Widget _trustBadge(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF6366F1)),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A))),
      ],
    );
  }

  Widget _buildProcessSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('COMMENT ÇA MARCHE ?', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w900, color: const Color(0xFF6366F1), letterSpacing: 2)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _processStep('1', 'Essayer', 'Réalité Augmentée'),
              _processStep('2', 'Scanner', 'Ordonnance IA'),
              _processStep('3', 'Commander', 'Chez vous en 48h'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _processStep(String num, String title, String sub) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 40, width: 40,
            decoration: BoxDecoration(color: const Color(0xFF0F172A), shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(num, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
          Text(sub, style: GoogleFonts.inter(fontSize: 10, color: Colors.grey[500]), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildCatalogGridWithFilters() {
    final List<Map<String, String>> _catalog = [
      {'name': 'Onyx Pro', 'brand': 'Gunnar', 'image': 'assets/glasses/image.jpeg', 'price': '95 €'},
      {'name': 'Luxury Panther', 'brand': 'Cartier', 'image': 'assets/glasses/image2.jpg', 'price': '750 €'},
      {'name': 'Metal Minimal', 'brand': 'Prada', 'image': 'assets/glasses/image4.jpg', 'price': '220 €'},
      {'name': 'Sport Ultra', 'brand': 'Nike', 'image': 'assets/glasses/image5.jpg', 'price': '155 €'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('NOS MODÈLES', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A), letterSpacing: 2)),
          const SizedBox(height: 16),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final f = _filters[index];
                final isSelected = _activeFilter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(f, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : const Color(0xFF0F172A))),
                    selected: isSelected,
                    onSelected: (val) => setState(() => _activeFilter = f),
                    backgroundColor: Colors.white,
                    selectedColor: const Color(0xFF0F172A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.grey.withOpacity(0.2))),
                    showCheckmark: false,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.8,
            ),
            itemCount: _catalog.length,
            itemBuilder: (context, index) {
              final item = _catalog[index];
              return FadeInUp(
                delay: Duration(milliseconds: index * 100),
                child: Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 5))]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(24)), child: Image.asset(item['image']!, fit: BoxFit.cover, width: double.infinity))),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['name']!, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold), maxLines: 1),
                            Text(item['brand']!, style: GoogleFonts.inter(fontSize: 10, color: Colors.grey[400])),
                            const SizedBox(height: 8),
                            Text(item['price']!, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF6366F1))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      color: const Color(0xFF0F172A),
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Smart Vision', style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  _socialIcon(Icons.facebook),
                  const SizedBox(width: 12),
                  _socialIcon(Icons.camera_alt_rounded),
                ],
              ),
            ],
          ),
          const SizedBox(height: 48),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _footerColumn('SHOP', ['Homme', 'Femme', 'Solaire', 'Luxe']),
              const SizedBox(width: 48),
              _footerColumn('SERVICES', ['Essai AR', 'IA Scan', 'Mutuelle', 'Historique']),
              const SizedBox(width: 48),
              _footerColumn('INFO', ['FAQ', 'Contact', 'Livraison', 'Mentions']),
            ],
          ),
          const Divider(height: 80, color: Colors.white10),
          Text('© 2026 Smart Vision IA. Tous droits réservés.', style: GoogleFonts.inter(color: Colors.white30, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _socialIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }

  Widget _footerColumn(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.outfit(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1)),
        const SizedBox(height: 20),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(item, style: GoogleFonts.inter(color: Colors.white60, fontSize: 13)),
        )),
      ],
    );
  }

  Widget _buildNewHero(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FadeInLeft(
                child: Text('Vision IA', style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: 1)),
              ),
              Row(
                children: [
                  Consumer<Cart>(
                    builder: (context, cart, _) => Stack(
                      children: [
                        IconButton(onPressed: () {}, icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 22)),
                        if (cart.itemCount > 0)
                          Positioned(right: 8, top: 8, child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: const Color(0xFF6366F1), shape: BoxShape.circle), child: Text(cart.itemCount.toString(), style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)))),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Consumer<SessionService>(
                    builder: (context, session, _) => GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage())),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
                        child: Icon(session.isLoggedIn ? Icons.account_circle_rounded : Icons.person_outline_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 48),
          FadeInUp(
            child: Text('Redéfinissez\nvotre style.', style: GoogleFonts.outfit(color: Colors.white, fontSize: 44, fontWeight: FontWeight.bold, height: 1.05)),
          ),
          const SizedBox(height: 20),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Text('Essayez vos montures préférées en 3D et validez votre ordonnance par intelligence artificielle.', style: GoogleFonts.inter(color: Colors.white60, fontSize: 16, height: 1.5)),
          ),
          const SizedBox(height: 32),
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VirtualTryOnScreen())),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), foregroundColor: Colors.white),
                    child: const Text('ESSAYER EN 3D'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrescriptionScanScreen())),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white24), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: const Text('SCAN IA'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBentoSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('POUR VOUS', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w900, color: const Color(0xFF6366F1), letterSpacing: 2)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildBentoCard(
                  height: 220, title: 'IA Vision', subtitle: 'Analyse Optique', icon: Icons.auto_awesome_rounded, color: const Color(0xFF6366F1),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrescriptionScanScreen())),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    _buildBentoCard(
                      height: 102, title: 'Mutuelle', subtitle: 'Simulateur', icon: Icons.verified_user_rounded, color: const Color(0xFF10B981), compact: true,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InsuranceSimulationScreen())),
                    ),
                    const SizedBox(height: 16),
                    _buildBentoCard(
                      height: 102, title: 'SAV', subtitle: 'Aide H24', icon: Icons.support_agent_rounded, color: const Color(0xFF3B82F6), compact: true,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBentoCard({required double height, required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap, bool compact = false}) {
    return FadeInUp(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: height, width: double.infinity, padding: EdgeInsets.all(compact ? 12 : 20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: compact ? 20 : 28)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(subtitle, style: GoogleFonts.inter(fontSize: compact ? 9 : 11, fontWeight: FontWeight.w800, color: Colors.grey[400], letterSpacing: 1)),
                  const SizedBox(height: 4),
                  Text(title, style: GoogleFonts.outfit(fontSize: compact ? 14 : 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A), height: 1.1)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedCarousel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text('TENDANCES 2026', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A), letterSpacing: 2)),
        ),
        const SizedBox(height: 16),
        CarouselSlider(
          options: CarouselOptions(height: 280, enlargeCenterPage: true, autoPlay: true, viewportFraction: 0.8),
          items: _featuredGlasses.map((glasses) {
            return Builder(builder: (context) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 30, offset: const Offset(0, 15))]),
              child: Column(
                children: [
                  Expanded(child: ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(32)), child: Image.asset(glasses['image']!, fit: BoxFit.cover, width: double.infinity))),
                  Padding(padding: const EdgeInsets.all(20), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(glasses['name']!, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
                      Text(glasses['brand']!, style: GoogleFonts.inter(color: Colors.grey[400], fontSize: 12, fontWeight: FontWeight.w600)),
                    ]),
                    Text(glasses['price']!, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20, color: const Color(0xFF6366F1))),
                  ])),
                ],
              ),
            ));
          }).toList(),
        ),
      ],
    );
  }
}
