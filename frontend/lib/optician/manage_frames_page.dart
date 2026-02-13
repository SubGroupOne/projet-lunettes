import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

class ManageFramesPage extends StatefulWidget {
  final String? accessToken;

  const ManageFramesPage({super.key, this.accessToken});

  @override
  State<ManageFramesPage> createState() => _ManageFramesPageState();
}

class _ManageFramesPageState extends State<ManageFramesPage> {
  List<dynamic> _frames = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFrames();
  }

  Future<void> _fetchFrames() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/frames'),
        headers: {'Authorization': 'Bearer ${widget.accessToken}'},
      );
      if (response.statusCode == 200) {
        setState(() {
          _frames = json.decode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching frames: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteFrame(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:3000/frames/$id'),
        headers: {'Authorization': 'Bearer ${widget.accessToken}'},
      );
      if (response.statusCode == 200) {
        _fetchFrames();
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Monture supprimée')));
      }
    } catch (e) {
      debugPrint('Error deleting frame: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Gestion des Montures', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchFrames),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFrameDialog(),
        label: Text('AJOUTER', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 1)),
        icon: const Icon(Icons.add),
        backgroundColor: const Color(0xFF0F172A),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
          : RefreshIndicator(
              onRefresh: _fetchFrames,
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _frames.length,
                itemBuilder: (context, index) {
                  final frame = _frames[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 10))],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(16)),
                          child: const Icon(Icons.remove_red_eye_outlined, color: Color(0xFF6366F1), size: 32),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(frame['name'], style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text(frame['brand'], style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 13)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text('${frame['price']} €', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF6366F1))),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: (frame['stock'] ?? 0) < 5 ? Colors.red.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Stock: ${frame['stock'] ?? 0}',
                                      style: GoogleFonts.inter(
                                        fontSize: 11, fontWeight: FontWeight.bold,
                                        color: (frame['stock'] ?? 0) < 5 ? Colors.red : Colors.green,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20), onPressed: () => _showFrameDialog(frame: frame)),
                            IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20), onPressed: () => _deleteFrame(frame['id'])),
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

  void _showFrameDialog({Map<String, dynamic>? frame}) {
    final nameController = TextEditingController(text: frame?['name'] ?? '');
    final brandController = TextEditingController(text: frame?['brand'] ?? '');
    final priceController = TextEditingController(text: frame?['price']?.toString() ?? '');
    final stockController = TextEditingController(text: frame?['stock']?.toString() ?? '');
    final descController = TextEditingController(text: frame?['description'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(frame == null ? 'Nouvelle Monture' : 'Modifier Monture', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildField(nameController, 'Nom'),
              _buildField(brandController, 'Marque'),
              _buildField(priceController, 'Prix (€)', keyboardType: TextInputType.number),
              _buildField(stockController, 'Stock', keyboardType: TextInputType.number),
              _buildField(descController, 'Description', maxLines: 3),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('ANNULER', style: GoogleFonts.inter(color: Colors.grey))),
          ElevatedButton(
            onPressed: () async {
              final data = {
                'name': nameController.text,
                'brand': brandController.text,
                'price': double.tryParse(priceController.text) ?? 0.0,
                'stock': int.tryParse(stockController.text) ?? 0,
                'description': descController.text,
                'imageUrl': 'assets/glasses.png',
              };

              final url = frame == null 
                ? 'http://localhost:3000/frames' 
                : 'http://localhost:3000/frames/${frame['id']}';
              
              final response = await (frame == null 
                ? http.post(Uri.parse(url), headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${widget.accessToken}'}, body: json.encode(data))
                : http.put(Uri.parse(url), headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${widget.accessToken}'}, body: json.encode(data)));

              if (response.statusCode == 201 || response.statusCode == 200) {
                _fetchFrames();
                if (context.mounted) {
                  Navigator.pop(context);
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text('ENREGISTRER', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, {TextInputType? keyboardType, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(fontSize: 14),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}
