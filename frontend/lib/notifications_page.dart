import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationsPage extends StatefulWidget {
  final String accessToken;
  const NotificationsPage({super.key, required this.accessToken});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<dynamic> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/notifications'),
        headers: {'Authorization': 'Bearer ${widget.accessToken}'},
      );
      if (response.statusCode == 200) {
        setState(() {
          _notifications = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsRead(int id) async {
    try {
      await http.patch(
        Uri.parse('http://localhost:3000/notifications/$id/read'),
        headers: {'Authorization': 'Bearer ${widget.accessToken}'},
      );
      setState(() {
        final index = _notifications.indexWhere((n) => n['id'] == id);
        if (index != -1) _notifications[index]['is_read'] = 1;
      });
    } catch (e) {
      debugPrint('Error marking as read: $e');
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await http.patch(
        Uri.parse('http://localhost:3000/notifications/mark-all-read'),
        headers: {'Authorization': 'Bearer ${widget.accessToken}'},
      );
      setState(() {
        for (var n in _notifications) {
          n['is_read'] = 1;
        }
      });
    } catch (e) {
      debugPrint('Error marking all as read: $e');
    }
  }

  int get _unreadCount =>
      _notifications.where((n) => n['is_read'] == 0).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Row(
          children: [
            Text('Notifications',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                    color: const Color(0xFF6366F1),
                    borderRadius: BorderRadius.circular(10)),
                child: Text('$_unreadCount',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ),
            ]
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF0F172A),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text('Tout lire',
                  style: GoogleFonts.inter(
                      color: const Color(0xFF6366F1),
                      fontWeight: FontWeight.bold)),
            ),
          IconButton(
              icon: const Icon(Icons.refresh), onPressed: _fetchNotifications),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6366F1)))
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none_rounded,
                          size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text('Aucune notification',
                          style: GoogleFonts.outfit(
                              fontSize: 18, color: Colors.grey[400])),
                      const SizedBox(height: 8),
                      Text('Vous serez notifié ici des mises à jour.',
                          style: GoogleFonts.inter(
                              fontSize: 14, color: Colors.grey[400])),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchNotifications,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notif = _notifications[index];
                      final isRead = notif['is_read'] == 1;
                      return GestureDetector(
                        onTap: () {
                          if (!isRead) _markAsRead(notif['id']);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isRead
                                ? Colors.white
                                : const Color(0xFF6366F1)
                                    .withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isRead
                                  ? Colors.grey.shade100
                                  : const Color(0xFF6366F1)
                                      .withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: _getNotifColor(notif['type'])
                                      .withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _getNotifIcon(notif['type']),
                                  color: _getNotifColor(notif['type']),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            notif['title'] ?? '',
                                            style: GoogleFonts.outfit(
                                              fontWeight: isRead
                                                  ? FontWeight.w500
                                                  : FontWeight.bold,
                                              fontSize: 14,
                                              color:
                                                  const Color(0xFF0F172A),
                                            ),
                                          ),
                                        ),
                                        if (!isRead)
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                                color: Color(0xFF6366F1),
                                                shape: BoxShape.circle),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      notif['message'] ?? '',
                                      style: GoogleFonts.inter(
                                          fontSize: 13,
                                          color: Colors.grey[600],
                                          height: 1.4),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _formatDate(
                                          notif['created_at'].toString()),
                                      style: GoogleFonts.inter(
                                          fontSize: 11,
                                          color: Colors.grey[400]),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Color _getNotifColor(String? type) {
    switch (type) {
      case 'order':
        return const Color(0xFF6366F1);
      case 'promo':
        return Colors.orange;
      default:
        return Colors.teal;
    }
  }

  IconData _getNotifIcon(String? type) {
    switch (type) {
      case 'order':
        return Icons.shopping_bag_rounded;
      case 'promo':
        return Icons.local_offer_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
      if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
      if (diff.inDays == 1) return 'Hier';
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return dateStr;
    }
  }
}