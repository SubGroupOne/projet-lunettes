// lib/screens/admin/users_management_screen.dart

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';

class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({Key? key}) : super(key: key);

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  bool _isLoading = true;
  List<UserModel> _users = [];
  String _searchQuery = '';
  String _selectedRole = 'Tous';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);

    try {
      final users = await ApiService.getUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _users = _generateMockUsers();
        _isLoading = false;
      });
    }
  }

  List<UserModel> _generateMockUsers() {
    return List.generate(20, (index) {
      final roles = ['client', 'opticien', 'admin'];
      return UserModel(
        id: 'user_$index',
        name: 'Utilisateur ${index + 1}',
        email: 'user${index + 1}@example.com',
        phone: '+226 70 00 00 ${index.toString().padLeft(2, '0')}',
        role: roles[index % roles.length],
        isActive: index % 5 != 0,
        createdAt: DateTime.now().subtract(Duration(days: index * 10)),
      );
    });
  }

  List<UserModel> get _filteredUsers {
    return _users.where((user) {
      final matchesSearch = user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesRole = _selectedRole == 'Tous' || user.role == _selectedRole.toLowerCase();
      return matchesSearch && matchesRole;
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
          'Gestion des utilisateurs',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
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
                    hintText: 'Rechercher un utilisateur...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),

                const SizedBox(height: 12),

                // Filtres de rôles
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['Tous', 'Client', 'Opticien', 'Admin'].map((role) {
                      final isSelected = _selectedRole == role;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(role),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedRole = role;
                            });
                          },
                          selectedColor: Theme.of(context).primaryColor,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Liste des utilisateurs
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
              onRefresh: _loadUsers,
              child: _filteredUsers.isEmpty
                  ? const Center(child: Text('Aucun utilisateur trouvé'))
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = _filteredUsers[index];
                  return FadeInUp(
                    delay: Duration(milliseconds: index * 50),
                    child: _buildUserCard(user),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(UserModel user) {
    final roleColors = {
      'client': Colors.blue,
      'opticien': Colors.green,
      'admin': Colors.purple,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: roleColors[user.role]?.withOpacity(0.1),
          child: Text(
            user.name.substring(0, 1).toUpperCase(),
            style: TextStyle(
              color: roleColors[user.role],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          user.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(user.email),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: roleColors[user.role]?.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user.role.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      color: roleColors[user.role],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: user.isActive
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user.isActive ? 'ACTIF' : 'INACTIF',
                    style: TextStyle(
                      fontSize: 10,
                      color: user.isActive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            PopupMenuItem(
              child: ListTile(
                leading: Icon(
                  user.isActive ? Icons.block : Icons.check_circle,
                  size: 20,
                ),
                title: Text(user.isActive ? 'Désactiver' : 'Activer'),
                contentPadding: EdgeInsets.zero,
              ),
              onTap: () => _toggleUserStatus(user),
            ),
            const PopupMenuItem(
              child: ListTile(
                leading: Icon(Icons.edit, size: 20),
                title: Text('Modifier'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              child: const ListTile(
                leading: Icon(Icons.delete, size: 20, color: Colors.red),
                title: Text('Supprimer', style: TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
              ),
              onTap: () => _deleteUser(user),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleUserStatus(UserModel user) async {
    final success = await ApiService.updateUserStatus(user.id, !user.isActive);

    if (success) {
      setState(() {
        final index = _users.indexWhere((u) => u.id == user.id);
        if (index != -1) {
          _users[index] = UserModel(
            id: user.id,
            name: user.name,
            email: user.email,
            phone: user.phone,
            role: user.role,
            isActive: !user.isActive,
            createdAt: user.createdAt,
          );
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              user.isActive
                  ? 'Utilisateur désactivé avec succès'
                  : 'Utilisateur activé avec succès',
            ),
          ),
        );
      }
    }
  }

  Future<void> _deleteUser(UserModel user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer ${user.name} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ApiService.deleteUser(user.id);

      if (success) {
        setState(() {
          _users.removeWhere((u) => u.id == user.id);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Utilisateur supprimé avec succès')),
          );
        }
      }
    }
  }
}