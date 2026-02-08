import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class InsuranceManagementPage extends StatefulWidget {
  final String accessToken;

  const InsuranceManagementPage({Key? key, required this.accessToken}) : super(key: key);

  @override
  State<InsuranceManagementPage> createState() => _InsuranceManagementPageState();
}

class _InsuranceManagementPageState extends State<InsuranceManagementPage> {
  List<dynamic> _insurances = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInsurances();
  }

  Future<void> _loadInsurances() async {
    try {
      setState(() => _isLoading = true);

      final response = await http.get(
        Uri.parse('http://localhost:3000/insurances/admin/all'),
        headers: {
          'Authorization': 'Bearer ${widget.accessToken}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _insurances = json.decode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading insurances: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createInsurance() async {
    await _showInsuranceDialog();
  }

  Future<void> _editInsurance(Map<String, dynamic> insurance) async {
    await _showInsuranceDialog(insurance: insurance);
  }

  Future<void> _showInsuranceDialog({Map<String, dynamic>? insurance}) async {
    final nameController = TextEditingController(text: insurance?['name'] ?? '');
    final coverageController = TextEditingController(
      text: insurance != null ? (insurance['coverage_rate'] * 100).toString() : '',
    );
    final conditionsController = TextEditingController(text: insurance?['conditions'] ?? '');
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(insurance == null ? 'Nouvelle Assurance' : 'Modifier Assurance'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom de l\'assurance',
                    hintText: 'Ex: Harmonie Mutuelle',
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Nom requis' : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: coverageController,
                  decoration: const InputDecoration(
                    labelText: 'Taux de couverture (%)',
                    hintText: 'Ex: 70',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Taux requis';
                    final rate = double.tryParse(v);
                    if (rate == null || rate < 0 || rate > 100) {
                      return 'Taux entre 0 et 100';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: conditionsController,
                  decoration: const InputDecoration(
                    labelText: 'Conditions',
                    hintText: 'Conditions d\'application...',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                await _saveInsurance(
                  insurance?['id'],
                  nameController.text,
                  double.parse(coverageController.text) / 100,
                  conditionsController.text,
                );
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveInsurance(int? id, String name, double coverageRate, String conditions) async {
    try {
      final url = id == null
          ? 'http://localhost:3000/insurances'
          : 'http://localhost:3000/insurances/$id';

      final response = await (id == null ? http.post : http.put)(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${widget.accessToken}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': name,
          'coverage_rate': coverageRate,
          'conditions': conditions,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(id == null ? 'Assurance créée ✅' : 'Assurance mise à jour ✅')),
        );
        _loadInsurances();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _toggleStatus(int id, bool isActive) async {
    try {
      final response = await http.patch(
        Uri.parse('http://localhost:3000/insurances/$id/status'),
        headers: {
          'Authorization': 'Bearer ${widget.accessToken}',
          'Content-Type': 'application/json',
        },
        body: json.encode({'is_active': !isActive}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isActive ? 'Assurance désactivée ❌' : 'Assurance activée ✅')),
        );
        _loadInsurances();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deleteInsurance(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette assurance ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final response = await http.delete(
        Uri.parse('http://localhost:3000/insurances/$id'),
        headers: {
          'Authorization': 'Bearer ${widget.accessToken}',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Assurance supprimée ✅')),
        );
        _loadInsurances();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Assurances'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInsurances,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createInsurance,
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle Assurance'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _insurances.isEmpty
              ? const Center(child: Text('Aucune assurance'))
              : ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: _insurances.length,
                  itemBuilder: (context, index) {
                    return _buildInsuranceCard(_insurances[index]);
                  },
                ),
    );
  }

  Widget _buildInsuranceCard(Map<String, dynamic> insurance) {
    final isActive = insurance['is_active'] == 1 || insurance['is_active'] == true;
    final coverageRate = ((double.tryParse(insurance['coverage_rate']?.toString() ?? '0') ?? 0.0) * 100).toStringAsFixed(0);

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
                Icon(
                  Icons.health_and_safety,
                  color: Colors.teal,
                  size: 30,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        insurance['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Couverture: $coverageRate%',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                        ),
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
                    isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: isActive ? Colors.green.shade900 : Colors.red.shade900,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            if (insurance['conditions'] != null && insurance['conditions'].toString().isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                insurance['conditions'],
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _editInsurance(insurance),
                    icon: const Icon(Icons.edit),
                    label: const Text('Modifier'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _toggleStatus(insurance['id'], isActive),
                    icon: Icon(isActive ? Icons.block : Icons.check_circle),
                    label: Text(isActive ? 'Désactiver' : 'Activer'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isActive ? Colors.orange : Colors.green,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: () => _deleteInsurance(insurance['id']),
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
