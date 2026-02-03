import 'package:flutter/material.dart';

class ManageFramesPage extends StatefulWidget {
  const ManageFramesPage({super.key});

  @override
  State<ManageFramesPage> createState() => _ManageFramesPageState();
}

class _ManageFramesPageState extends State<ManageFramesPage> {
  final List<Map<String, dynamic>> _frames = [
    {
      'name': 'Classic Ray',
      'brand': 'RayBan',
      'price': '120.00',
      'stock': 15,
      'imageUrl': 'assets/glasses.png',
    },
    {
      'name': 'Blue Horizon',
      'brand': 'Oakley',
      'price': '150.00',
      'stock': 8,
      'imageUrl': 'assets/blue_sunglasses.png',
    },
    {
      'name': 'Orange Sunset',
      'brand': 'Gucci',
      'price': '250.00',
      'stock': 5,
      'imageUrl': 'assets/orange_sunglasses.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Gestion des Montures'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFrameDialog(context),
        label: const Text('Ajouter une monture'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.black,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _frames.length,
        itemBuilder: (context, index) {
          final frame = _frames[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((0.03 * 255).round()),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Image.asset(frame['imageUrl'], fit: BoxFit.contain),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        frame['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        frame['brand'],
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${frame['price']} €',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          Text(
                            'Stock: ${frame['stock']}',
                            style: TextStyle(
                              color: (frame['stock'] as int) < 10
                                  ? Colors.red
                                  : Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showFrameDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvelle Monture'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TextField(
                decoration: InputDecoration(labelText: 'Nom de la monture'),
              ),
              const TextField(decoration: InputDecoration(labelText: 'Marque')),
              const TextField(
                decoration: InputDecoration(labelText: 'Prix (€)'),
                keyboardType: TextInputType.number,
              ),
              const TextField(
                decoration: InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number,
              ),
              const TextField(
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}
