import 'package:flutter/material.dart';
import '../models/partner_status.dart';

class StatusCard extends StatelessWidget {
  final PartnerStatus partnerStatus;

  const StatusCard({
    super.key, // Using super parameter
    required this.partnerStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: _getStatusColor(),
              child: const Icon(Icons.favorite, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text(
              'Partner Status',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: _getStatusColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                partnerStatus.statusText,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(),
                ),
              ),
            ),
            if (partnerStatus.lastSeen != null) ...[
              const SizedBox(height: 20),
              Text(
                'Last seen: ${_formatDate(partnerStatus.lastSeen!)}',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
            const SizedBox(height: 20),
            Icon(
              partnerStatus.isOnline ? Icons.wifi : Icons.wifi_off,
              color: _getStatusColor(),
              size: 40,
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    if (partnerStatus.isOnline) return Colors.green;
    if (partnerStatus.isAway) return Colors.orange;
    return Colors.grey;
  }

  String _formatDate(DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
