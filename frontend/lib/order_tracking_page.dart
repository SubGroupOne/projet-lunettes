import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderTrackingPage extends StatefulWidget {
  final String accessToken;
  final int? orderId;

  const OrderTrackingPage({
    super.key,
    required this.accessToken,
    this.orderId,
  });

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  List<dynamic> _orders = [];
  Map<String, dynamic>? _selectedOrder;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Simuler appel API - Remplacer par vraie API
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _orders = _getMockOrders();
        if (widget.orderId != null) {
          _selectedOrder = _orders.firstWhere(
            (order) => order['id'] == widget.orderId,
            orElse: () => _orders.isNotEmpty ? _orders[0] : null,
          );
        } else if (_orders.isNotEmpty) {
          _selectedOrder = _orders[0];
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _getMockOrders() {
    return [
      {
        'id': 12345,
        'frame_name': 'Ray-Ban Aviator Classic',
        'total_price': 299.99,
        'status': 'processing',
        'created_at': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'updated_at': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
        'tracking_history': [
          {
            'status': 'pending',
            'message': 'Commande reçue',
            'date': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
          },
          {
            'status': 'confirmed',
            'message': 'Commande confirmée par l\'opticien',
            'date': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
          },
          {
            'status': 'processing',
            'message': 'Lunettes en cours de préparation',
            'date': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
          },
        ],
      },
      {
        'id': 12344,
        'frame_name': 'Oakley Holbrook',
        'total_price': 189.99,
        'status': 'delivered',
        'created_at': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
        'updated_at': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'tracking_history': [
          {
            'status': 'pending',
            'message': 'Commande reçue',
            'date': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
          },
          {
            'status': 'confirmed',
            'message': 'Commande confirmée',
            'date': DateTime.now().subtract(const Duration(days: 9)).toIso8601String(),
          },
          {
            'status': 'processing',
            'message': 'En préparation',
            'date': DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
          },
          {
            'status': 'shipped',
            'message': 'Expédiée',
            'date': DateTime.now().subtract(const Duration(days: 4)).toIso8601String(),
          },
          {
            'status': 'delivered',
            'message': 'Livrée avec succès',
            'date': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
          },
        ],
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suivi de commandes'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Erreur: $_error'))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_orders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              'Aucune commande',
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        // Liste des commandes
        if (_orders.length > 1)
          SizedBox(
            width: 250,
            child: _buildOrderList(),
          ),
        
        // Détails de la commande sélectionnée
        Expanded(
          child: _selectedOrder != null
              ? _buildOrderDetails()
              : const Center(child: Text('Sélectionnez une commande')),
        ),
      ],
    );
  }

  Widget _buildOrderList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(right: BorderSide(color: Colors.grey.shade300)),
      ),
      child: ListView.builder(
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          final isSelected = _selectedOrder?['id'] == order['id'];
          
          return Container(
            decoration: BoxDecoration(
              color: isSelected ? Colors.deepPurple.shade50 : Colors.transparent,
              border: Border(
                left: BorderSide(
                  color: isSelected ? Colors.deepPurple : Colors.transparent,
                  width: 4,
                ),
              ),
            ),
            child: ListTile(
              selected: isSelected,
              title: Text('#${order['id']}'),
              subtitle: Text(order['frame_name']),
              trailing: _buildStatusBadge(order['status']),
              onTap: () {
                setState(() {
                  _selectedOrder = order;
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête commande
          _buildOrderHeader(),
          const SizedBox(height: 30),

          // Timeline de suivi
          _buildTrackingTimeline(),
          const SizedBox(height: 30),

          // Informations détaillées
          _buildOrderInfo(),
        ],
      ),
    );
  }

  Widget _buildOrderHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple, Colors.deepPurple.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Commande #${_selectedOrder!['id']}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              _buildStatusBadge(_selectedOrder!['status'], isLarge: true),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _selectedOrder!['frame_name'],
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              const Icon(Icons.euro, color: Colors.white, size: 20),
              const SizedBox(width: 5),
              Text(
                '${_selectedOrder!['total_price']} €',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingTimeline() {
    final List trackingHistory = _selectedOrder!['tracking_history'] ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Historique de suivi',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: trackingHistory.length,
          itemBuilder: (context, index) {
            final event = trackingHistory[index];
            final isLast = index == trackingHistory.length - 1;
            
            return _buildTimelineItem(
              status: event['status'],
              message: event['message'],
              date: event['date'],
              isLast: isLast,
              isActive: index == trackingHistory.length - 1,
            );
          },
        ),
      ],
    );
  }

  Widget _buildTimelineItem({
    required String status,
    required String message,
    required String date,
    required bool isLast,
    required bool isActive,
  }) {
    final statusColor = _getStatusColor(status);
    final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(date));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isActive ? statusColor : Colors.grey.shade300,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive ? statusColor : Colors.grey.shade400,
                  width: 3,
                ),
              ),
              child: Icon(
                _getStatusIcon(status),
                color: isActive ? Colors.white : Colors.grey.shade600,
                size: 20,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                color: Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 15),
        
        // Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    color: isActive ? Colors.black87 : Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderInfo() {
    final createdAt = DateFormat('dd/MM/yyyy').format(
      DateTime.parse(_selectedOrder!['created_at']),
    );
    final updatedAt = DateFormat('dd/MM/yyyy HH:mm').format(
      DateTime.parse(_selectedOrder!['updated_at']),
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informations détaillées',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          _buildInfoRow('Date de commande', createdAt),
          _buildInfoRow('Dernière mise à jour', updatedAt),
          _buildInfoRow('Montant total', '${_selectedOrder!['total_price']} €'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, {bool isLarge = false}) {
    final color = _getStatusColor(status);
    final label = _getStatusLabel(status);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? 15 : 10,
        vertical: isLarge ? 8 : 5,
      ),
      decoration: BoxDecoration(
        color: isLarge ? Colors.white : color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: isLarge ? 2 : 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: isLarge ? 14 : 12,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'processing':
        return Colors.purple;
      case 'shipped':
        return Colors.indigo;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'En attente';
      case 'confirmed':
        return 'Confirmée';
      case 'processing':
        return 'En préparation';
      case 'shipped':
        return 'Expédiée';
      case 'delivered':
        return 'Livrée';
      case 'cancelled':
        return 'Annulée';
      default:
        return status;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'processing':
        return Icons.settings;
      case 'shipped':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }
}
