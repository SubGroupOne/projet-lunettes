import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OpticianManagementPage extends StatefulWidget {
  final String accessToken;

  const OpticianManagementPage({Key? key, required this.accessToken}) : super(key: key);

  @override
  State<OpticianManagementPage> createState() => _OpticianManagementPageState();
}

class _OpticianManagementPageState extends State<OpticianManagementPage> {
  List<dynamic> _opticians = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOpticians();
  }

  Future<void> _loadOpticians() async {
    try {
      setState(() => _isLoading = true);

      // Charger tous les utilisateurs avec rôle opticien
      final response = await http.get(
        Uri.parse('http://localhost:3000/admin/users'),
        headers: {
          'Authorization': 'Bearer ${widget.accessToken}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List users = json.decode(response.body);
        setState(() {
          _opticians = users.where((u) => u['role'] == 'opticien').toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading opticians: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleOpticianStatus(int userId, bool isActive) async {
    try {
      final response = await http.put(
        Uri.parse('http://localhost:3000/admin/users/$userId/status'),
        headers: {
          'Authorization': 'Bearer ${widget.accessToken}',
          'Content-Type': 'application/json',
        },
        body: json.encode({'is_active': !isActive}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isActive ? 'Opticien désactivé ❌' : 'Opticien activé ✅'),
          ),
        );
        _loadOpticians();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _viewOpticianStats(Map<String, dynamic> optician) async {
    // Afficher les statistiques de l'opticien
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Statistiques - ${optician['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatRow('Email', optician['email']),
            _buildStatRow('Rôle', optician['role'].toUpperCase()),
            _buildStatRow('Statut', optician['is_active'] == 1 ? 'Actif' : 'Inactif'),
            const Divider(),
            const Text(
              'Statistiques détaillées bientôt disponibles',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Opticiens'),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOpticians,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _opticians.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.medical_services_outlined, size: 80, color: Colors.grey),
                      SizedBox(height: 20),
                      Text('Aucun opticien enregistré'),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: _opticians.length,
                  itemBuilder: (context, index) {
                    return _buildOpticianCard(_opticians[index]);
                  },
                ),
    );
  }

  Widget _buildOpticianCard(Map<String, dynamic> optician) {
    final isActive = optician['is_active'] == 1 || optician['is_active'] == true;

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.indigo,
                  radius: 30,
                  child: Text(
                    optician['name'][0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        optician['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(Icons.email, size: 14, color: Colors.grey),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              optician['email'],
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.green.shade100 : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isActive ? 'Actif' : 'Inactif',
                    style: TextStyle(
                      color: isActive ? Colors.green.shade900 : Colors.red.shade900,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            const Divider(),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewOpticianStats(optician),
                    icon: const Icon(Icons.bar_chart),
                    label: const Text('Statistiques'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.indigo,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _toggleOpticianStatus(optician['id'], isActive),
                    icon: Icon(isActive ? Icons.block : Icons.check_circle),
                    label: Text(isActive ? 'Désactiver' : 'Activer'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isActive ? Colors.orange : Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
