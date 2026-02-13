// lib/screens/admin/opticiens_management_screen.dart

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';

class OpticiensManagementScreen extends StatefulWidget {
  const OpticiensManagementScreen({super.key});

  @override
  State<OpticiensManagementScreen> createState() => _OpticiensManagementScreenState();
}

class _OpticiensManagementScreenState extends State<OpticiensManagementScreen> {
  bool _isLoading = true;
  List<OpticienModel> _opticiens = [];
  String _searchQuery = '';
  bool _showOnlyVerified = false;

  @override
  void initState() {
    super.initState();
    _loadOpticiens();
  }

  Future<void> _loadOpticiens() async {
    setState(() => _isLoading = true);

    try {
      final opticiens = await ApiService.getOpticiens();
      setState(() {
        _opticiens = opticiens;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _opticiens = _generateMockOpticiens();
        _isLoading = false;
      });
    }
  }

  List<OpticienModel> _generateMockOpticiens() {
    final cities = ['Ouagadougou', 'Bobo-Dioulasso', 'Koudougou', 'Ouahigouya'];
    return List.generate(15, (index) {
      return OpticienModel(
        id: 'opticien_$index',
        name: 'Optique ${index + 1}',
        email: 'optique${index + 1}@example.com',
        phone: '+226 70 00 00 ${index.toString().padLeft(2, '0')}',
        address: 'Avenue ${index + 1}',
        city: cities[index % cities.length],
        isVerified: index % 3 != 0,
        rating: 3.5 + (index % 15) * 0.1,
        totalOrders: 50 + index * 10,
        joinedDate: DateTime.now().subtract(Duration(days: index * 30)),
      );
    });
  }

  List<OpticienModel> get _filteredOpticiens {
    return _opticiens.where((opticien) {
      final matchesSearch = opticien.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          opticien.city.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesVerified = !_showOnlyVerified || opticien.isVerified;
      return matchesSearch && matchesVerified;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Gestion des opticiens',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        children: [
          // Barre de recherche et filtres
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Barre de recherche
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Rechercher un opticien...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                const SizedBox(height: 12),

                // Filtre "Vérifiés uniquement"
                Row(
                  children: [
                    FilterChip(
                      label: const Text('Vérifiés uniquement'),
                      selected: _showOnlyVerified,
                      onSelected: (selected) {
                        setState(() => _showOnlyVerified = selected);
                      },
                      selectedColor: Theme.of(context).primaryColor,
                      labelStyle: TextStyle(
                        color: _showOnlyVerified ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Liste des opticiens
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
              onRefresh: _loadOpticiens,
              child: _filteredOpticiens.isEmpty
                  ? const Center(
                child: Text(
                  'Aucun opticien trouvé',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredOpticiens.length,
                itemBuilder: (context, index) {
                  return FadeInUp(
                    delay: Duration(milliseconds: index * 50),
                    child: _buildOpticienCard(_filteredOpticiens[index]),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpticienCard(OpticienModel opticien) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.withValues(alpha: 0.1),
          child: const Icon(Icons.store, color: Colors.green),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                opticien.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (opticien.isVerified)
              const Icon(Icons.verified, color: Colors.blue, size: 20),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${opticien.city} • ${opticien.totalOrders} commandes'),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star, size: 14, color: Colors.amber),
                Text(' ${opticien.rating.toStringAsFixed(1)}'),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Informations détaillées
                _buildInfoRow(Icons.email, opticien.email),
                _buildInfoRow(Icons.phone, opticien.phone),
                _buildInfoRow(Icons.location_on, opticien.address),

                const SizedBox(height: 16),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _toggleVerification(opticien),
                        icon: Icon(
                          opticien.isVerified ? Icons.block : Icons.check_circle,
                        ),
                        label: Text(opticien.isVerified ? 'Révoquer' : 'Vérifier'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: opticien.isVerified
                              ? Colors.orange
                              : Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _deleteOpticien(opticien),
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Supprimer',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleVerification(OpticienModel opticien) async {
    final success = await ApiService.verifyOpticien(
      opticien.id,
      !opticien.isVerified,
    );

    if (success) {
      setState(() {
        final index = _opticiens.indexWhere((o) => o.id == opticien.id);
        if (index != -1) {
          _opticiens[index] = OpticienModel(
            id: opticien.id,
            name: opticien.name,
            email: opticien.email,
            phone: opticien.phone,
            address: opticien.address,
            city: opticien.city,
            isVerified: !opticien.isVerified,
            rating: opticien.rating,
            totalOrders: opticien.totalOrders,
            joinedDate: opticien.joinedDate,
          );
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              opticien.isVerified
                  ? 'Vérification révoquée avec succès'
                  : 'Opticien vérifié avec succès',
            ),
            backgroundColor: opticien.isVerified ? Colors.orange : Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la modification du statut'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteOpticien(OpticienModel opticien) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Voulez-vous vraiment supprimer ${opticien.name} ?\n\n'
              'Cette action est irréversible et supprimera également toutes les données associées.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ApiService.deleteOpticien(opticien.id);

      if (success) {
        setState(() {
          _opticiens.removeWhere((o) => o.id == opticien.id);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Opticien supprimé avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur lors de la suppression'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
