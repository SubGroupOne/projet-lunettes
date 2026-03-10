import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

class ManageOrdersPage extends StatefulWidget {
  final String? accessToken;

  const ManageOrdersPage({super.key, this.accessToken});

  @override
  State<ManageOrdersPage> createState() => _ManageOrdersPageState();
}

class _ManageOrdersPageState extends State<ManageOrdersPage> {
  List<dynamic> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/orders'),
        headers: {'Authorization': 'Bearer ${widget.accessToken}'},
      );
      if (response.statusCode == 200) {
        setState(() {
          _orders = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(int id, String status) async {
    try {
      final response = await http.patch(
        Uri.parse('http://localhost:3000/orders/$id/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.accessToken}',
        },
        body: json.encode({'status': status}),
      );
      if (response.statusCode == 200) {
        _fetchOrders();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Statut mis a jour : $status'),
              backgroundColor: status == 'validated' ? Colors.green : Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error updating status: $e');
    }
  }

  Map<String, dynamic> _parsePrescription(dynamic rawData) {
    if (rawData == null) return {};
    try {
      if (rawData is String && rawData.isNotEmpty && rawData != '{}') {
        return json.decode(rawData) as Map<String, dynamic>;
      } else if (rawData is Map) {
        return rawData as Map<String, dynamic>;
      }
    } catch (_) {}
    return {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Commandes Clients',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh), onPressed: _fetchOrders),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6366F1)))
          : _orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_rounded,
                          size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text('Aucune commande',
                          style: GoogleFonts.outfit(
                              fontSize: 18, color: Colors.grey[400])),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchOrders,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _orders.length,
                    itemBuilder: (context, index) {
                      final order = _orders[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 20,
                                offset: const Offset(0, 10))
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text('ORD-${order['id']}',
                                    style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF6366F1),
                                        fontSize: 13)),
                                _buildStatusChip(order['status']),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(order['user_name'] ?? 'Client Inconnu',
                                style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(order['user_email'] ?? '',
                                style: GoogleFonts.inter(
                                    color: Colors.grey[500], fontSize: 13)),
                            const Divider(height: 32),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text('MONTURE',
                                        style: GoogleFonts.inter(
                                            color: Colors.grey,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1)),
                                    const SizedBox(height: 4),
                                    Text(
                                        order['frame_name'] ?? 'Inconnue',
                                        style: GoogleFonts.outfit(
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('TOTAL',
                                        style: GoogleFonts.inter(
                                            color: Colors.grey,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1)),
                                    const SizedBox(height: 4),
                                    Text('${order['total_price']} F',
                                        style: GoogleFonts.outfit(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                const Color(0xFF0F172A))),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () =>
                                        _showPrescription(order),
                                    icon: const Icon(
                                        Icons.description_outlined,
                                        size: 18),
                                    label: const Text('ORDONNANCE'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color(0xFFF1F5F9),
                                      foregroundColor:
                                          const Color(0xFF0F172A),
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                                if (order['status'] == 'pending') ...[
                                  const SizedBox(width: 12),
                                  _buildActionButton(
                                      Icons.check_circle_rounded,
                                      Colors.green,
                                      () => _updateStatus(
                                          order['id'], 'validated')),
                                  const SizedBox(width: 8),
                                  _buildActionButton(
                                      Icons.cancel_rounded,
                                      Colors.red,
                                      () => _updateStatus(
                                          order['id'], 'rejected')),
                                ],
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildActionButton(
      IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    switch (status) {
      case 'validated':
        color = Colors.green;
        label = 'VALIDEE';
        break;
      case 'rejected':
        color = Colors.red;
        label = 'REJETEE';
        break;
      case 'shipped':
        color = Colors.blue;
        label = 'EXPEDIEE';
        break;
      case 'delivered':
        color = Colors.teal;
        label = 'LIVREE';
        break;
      default:
        color = Colors.orange;
        label = 'EN ATTENTE';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8)),
      child: Text(label,
          style: GoogleFonts.inter(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5)),
    );
  }

  void _showPrescription(Map<String, dynamic> order) {
    final prescription = _parsePrescription(order['prescription_data']);
    final insurance = _parsePrescription(order['insurance_data']);
    final hasPrescription = prescription.isNotEmpty &&
        prescription.values.any((v) => v != null && v.toString().isNotEmpty);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(32))),
          padding: const EdgeInsets.all(28),
          child: ListView(
            controller: controller,
            children: [
              // Handle
              Center(
                child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2))),
              ),

              // Titre
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: const Color(0xFF6366F1)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.description_rounded,
                        color: Color(0xFF6366F1), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ordonnance du patient',
                          style: GoogleFonts.outfit(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('ORD-${order['id']}',
                          style: GoogleFonts.inter(
                              color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Infos patient
              _buildSection('INFORMATIONS PATIENT', [
                _buildInfoRow('Patient', order['user_name'] ?? 'Inconnu'),
                _buildInfoRow('Email', order['user_email'] ?? '-'),
                _buildInfoRow('Date commande',
                    order['created_at'].toString().split('T')[0]),
                _buildInfoRow('Monture', order['frame_name'] ?? '-'),
              ]),
              const SizedBox(height: 20),

              // Ordonnance
              if (hasPrescription) ...[
                _buildSection('DONNEES ORDONNANCE', [
                  if (prescription['od_sph'] != null)
                    _buildVisionRow('OEIL DROIT (OD)',
                        'Sph: ${prescription['od_sph']}',
                        cyl: prescription['od_cyl'] != null
                            ? 'Cyl: ${prescription['od_cyl']}'
                            : null,
                        axe: prescription['od_axe'] != null
                            ? 'Axe: ${prescription['od_axe']}'
                            : null),
                  if (prescription['og_sph'] != null)
                    _buildVisionRow('OEIL GAUCHE (OG)',
                        'Sph: ${prescription['og_sph']}',
                        cyl: prescription['og_cyl'] != null
                            ? 'Cyl: ${prescription['og_cyl']}'
                            : null,
                        axe: prescription['og_axe'] != null
                            ? 'Axe: ${prescription['og_axe']}'
                            : null),
                  if (prescription['ecart_pupillaire'] != null)
                    _buildInfoRow('Ecart Pupillaire',
                        '${prescription['ecart_pupillaire']} mm'),
                ]),
                const SizedBox(height: 20),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: Colors.orange),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Aucune ordonnance scannee pour cette commande.',
                          style: GoogleFonts.inter(
                              fontSize: 13, color: Colors.orange[800]),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Assurance
              if (insurance.isNotEmpty &&
                  insurance['company'] != null &&
                  insurance['company'].toString().isNotEmpty) ...[
                _buildSection('ASSURANCE', [
                  _buildInfoRow(
                      'Mutuelle', insurance['company'] ?? '-'),
                  if (insurance['coverage'] != null)
                    _buildInfoRow('Couverture',
                        '${((insurance['coverage'] as num) * 100).toStringAsFixed(0)}%'),
                ]),
                const SizedBox(height: 20),
              ],

              // Boutons action
              if (order['status'] == 'pending') ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _updateStatus(order['id'], 'validated');
                        },
                        icon: const Icon(Icons.check_circle_rounded,
                            size: 18),
                        label: Text('VALIDER',
                            style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _updateStatus(order['id'], 'rejected');
                        },
                        icon: const Icon(Icons.cancel_rounded, size: 18),
                        label: Text('REJETER',
                            style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text('FERMER',
                        style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            color: Colors.white)),
                  ),
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Colors.grey,
                  letterSpacing: 1.5)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  color: Colors.grey, fontWeight: FontWeight.w500)),
          Text(value,
              style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildVisionRow(String eye, String sph,
      {String? cyl, String? axe}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(eye,
              style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF6366F1),
                  letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildVisionChip(sph),
              if (cyl != null) ...[
                const SizedBox(width: 8),
                _buildVisionChip(cyl),
              ],
              if (axe != null) ...[
                const SizedBox(width: 8),
                _buildVisionChip(axe),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVisionChip(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
          color: const Color(0xFF6366F1).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8)),
      child: Text(value,
          style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF6366F1))),
    );
  }
}