import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';

class StatisticsPage extends StatefulWidget {
  final String accessToken;

  const StatisticsPage({Key? key, required this.accessToken}) : super(key: key);

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  Map<String, dynamic>? _orderStats;
  List<dynamic>? _topFrames;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      setState(() => _isLoading = true);

      // Charger stats commandes
      final orderResponse = await http.get(
        Uri.parse('http://localhost:3000/admin/orders/statistics'),
        headers: {'Authorization': 'Bearer ${widget.accessToken}'},
      );

      // Charger top montures
      final framesResponse = await http.get(
        Uri.parse('http://localhost:3000/admin/frames/top'),
        headers: {'Authorization': 'Bearer ${widget.accessToken}'},
      );

      if (orderResponse.statusCode == 200 && framesResponse.statusCode == 200) {
        setState(() {
          _orderStats = json.decode(orderResponse.body);
          _topFrames = json.decode(framesResponse.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading stats: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques Détaillées'),
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOrderStats(),
                  const SizedBox(height: 30),
                  _buildTopFrames(),
                ],
              ),
            ),
    );
  }

  Widget _buildOrderStats() {
    if (_orderStats == null) return const SizedBox();

    final total = _orderStats!['total'] ?? 0;
    final pending = _orderStats!['pending'] ?? 0;
    final confirmed = _orderStats!['confirmed'] ?? 0;
    final delivered = _orderStats!['delivered'] ?? 0;
    final cancelled = _orderStats!['cancelled'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statistiques des Commandes',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        // Graphique circulaire
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  value: pending.toDouble(),
                  title: 'En attente\n$pending',
                  color: Colors.orange,
                  radius: 80,
                  titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                PieChartSectionData(
                  value: confirmed.toDouble(),
                  title: 'Confirmées\n$confirmed',
                  color: Colors.blue,
                  radius: 80,
                  titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                PieChartSectionData(
                  value: delivered.toDouble(),
                  title: 'Livrées\n$delivered',
                  color: Colors.green,
                  radius: 80,
                  titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                PieChartSectionData(
                  value: cancelled.toDouble(),
                  title: 'Annulées\n$cancelled',
                  color: Colors.red,
                  radius: 80,
                  titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Cartes de stats
        Row(
          children: [
            Expanded(
              child: _buildStatCard('Total', total.toString(), Colors.purple),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(
                'Revenus',
                '${(double.tryParse(_orderStats!['totalRevenue']?.toString() ?? '0') ?? 0.0).toStringAsFixed(0)} €',
                Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopFrames() {
    if (_topFrames == null || _topFrames!.isEmpty) {
      return const Text('Aucune donnée disponible');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Top Montures Vendues',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _topFrames!.length > 10 ? 10 : _topFrames!.length,
          itemBuilder: (context, index) {
            final frame = _topFrames![index];
            return _buildFrameCard(frame, index + 1);
          },
        ),
      ],
    );
  }

  Widget _buildFrameCard(Map<String, dynamic> frame, int rank) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: rank <= 3 ? Colors.amber : Colors.grey,
          child: Text(
            '#$rank',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          frame['name'] ?? 'Inconnu',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${frame['brand'] ?? 'Marque inconnue'} - ${frame['price']} €'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${frame['sales'] ?? 0} ventes',
            style: TextStyle(
              color: Colors.green.shade900,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
