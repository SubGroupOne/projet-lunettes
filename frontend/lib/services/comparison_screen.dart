import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../models/product.dart';

class ComparisonScreen extends StatefulWidget {
  const ComparisonScreen({super.key});

  @override
  State<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<ComparisonScreen> {
  final List<Product?> _selected = [null, null];

  List<Product> get _allProducts {
    return [
      ...EyeglassesProducts.men,
      ...EyeglassesProducts.women,
      ...EyeglassesProducts.kids,
      ...SunglassesProducts.men,
      ...SunglassesProducts.women,
      ...SunglassesProducts.kids,
    ];
  }

  double _parsePrice(String priceStr) {
    return double.tryParse(priceStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
  }

  void _pickProduct(int slot) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              Text('Choisir une monture',
                  style: GoogleFonts.outfit(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  itemCount: _allProducts.length,
                  itemBuilder: (_, i) {
                    final p = _allProducts[i];
                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          p.image,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                              width: 56,
                              height: 56,
                              color: Colors.grey[200],
                              child: const Icon(Icons.visibility)),
                        ),
                      ),
                      title: Text(p.name,
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold)),
                      subtitle: Text(p.desc,
                          style: GoogleFonts.inter(
                              fontSize: 12, color: Colors.grey)),
                      trailing: Text(p.price,
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF6366F1))),
                      onTap: () {
                        setState(() => _selected[slot] = p);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool canCompare = _selected[0] != null && _selected[1] != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Comparer les montures',
            style:
                GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF0F172A),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildSelector(0)),
                const SizedBox(width: 16),
                Column(children: [
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                        color: Color(0xFF6366F1),
                        shape: BoxShape.circle),
                    child: const Icon(Icons.compare_arrows_rounded,
                        color: Colors.white, size: 20),
                  ),
                ]),
                const SizedBox(width: 16),
                Expanded(child: _buildSelector(1)),
              ],
            ),
            if (canCompare) ...[
              const SizedBox(height: 32),
              FadeInUp(child: _buildComparisonTable()),
            ] else ...[
              const SizedBox(height: 60),
              FadeIn(
                child: Column(
                  children: [
                    Icon(Icons.compare_rounded,
                        size: 80, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text('Sélectionnez 2 montures',
                        style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[400])),
                    const SizedBox(height: 8),
                    Text('Comparez les caractéristiques et les prix',
                        style: GoogleFonts.inter(
                            fontSize: 14, color: Colors.grey[400])),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSelector(int slot) {
    final product = _selected[slot];
    return GestureDetector(
      onTap: () => _pickProduct(slot),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: product != null
                  ? const Color(0xFF6366F1).withValues(alpha: 0.3)
                  : Colors.grey.shade200,
              width: 2),
        ),
        child: product == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  Icon(Icons.add_circle_outline_rounded,
                      size: 40, color: Colors.grey[300]),
                  const SizedBox(height: 8),
                  Text('Choisir\nune monture',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          fontSize: 12, color: Colors.grey[400])),
                  const SizedBox(height: 16),
                ],
              )
            : Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      product.image,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                          height: 80,
                          color: Colors.grey[100],
                          child: const Icon(Icons.visibility, size: 40)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(product.name,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  Text(product.price,
                      style: GoogleFonts.outfit(
                          color: const Color(0xFF6366F1),
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  TextButton(
                    onPressed: () => _pickProduct(slot),
                    style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 24)),
                    child: Text('Changer',
                        style: GoogleFonts.inter(
                            fontSize: 11, color: Colors.grey)),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildComparisonTable() {
    final p1 = _selected[0]!;
    final p2 = _selected[1]!;
    final price1 = _parsePrice(p1.price);
    final price2 = _parsePrice(p2.price);
    final cheaper = price1 < price2 ? 0 : (price2 < price1 ? 1 : -1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('COMPARAISON',
            style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: const Color(0xFF0F172A))),
        const SizedBox(height: 16),
        _buildRow('Nom', p1.name, p2.name, null),
        _buildRow('Description', p1.desc, p2.desc, null),
        _buildRow('Prix', p1.price, p2.price, cheaper, isPrice: true),
        _buildRow('Note', '${p1.rating} etoile', '${p2.rating} etoile',
            p1.rating >= p2.rating ? 0 : 1),
        _buildRow(
            'Reduction',
            p1.discountPercent != null
                ? '-${p1.discountPercent}%'
                : 'Aucune',
            p2.discountPercent != null
                ? '-${p2.discountPercent}%'
                : 'Aucune',
            null),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.emoji_events_rounded,
                  color: Colors.amber, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Meilleur rapport qualite/prix',
                        style: GoogleFonts.inter(
                            color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                      cheaper == 0
                          ? p1.name
                          : (cheaper == 1 ? p2.name : 'Prix identique'),
                      style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    if (cheaper != -1)
                      Text(
                        cheaper == 0
                            ? 'Economisez ${(price2 - price1).toStringAsFixed(0)} F'
                            : 'Economisez ${(price1 - price2).toStringAsFixed(0)} F',
                        style: GoogleFonts.inter(
                            color: Colors.greenAccent, fontSize: 12),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRow(String label, String val1, String val2, int? winner,
      {bool isPrice = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(),
                style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey,
                    letterSpacing: 1)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                    child: _buildValueCell(
                        val1, winner == 0, isPrice && winner == 0)),
                const SizedBox(width: 8),
                Expanded(
                    child: _buildValueCell(
                        val2, winner == 1, isPrice && winner == 1)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValueCell(String value, bool isWinner, bool isCheaper) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isWinner
            ? const Color(0xFF6366F1).withValues(alpha: 0.08)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: isWinner
            ? Border.all(
                color:
                    const Color(0xFF6366F1).withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: Text(value,
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: isWinner
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isWinner
                          ? const Color(0xFF6366F1)
                          : const Color(0xFF0F172A)))),
          if (isCheaper)
            const Icon(Icons.arrow_downward_rounded,
                color: Colors.green, size: 16),
          if (isWinner && !isCheaper)
            const Icon(Icons.star_rounded,
                color: Color(0xFF6366F1), size: 16),
        ],
      ),
    );
  }
}