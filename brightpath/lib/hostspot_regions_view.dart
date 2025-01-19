import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class HotspotRegionsViewPage extends StatelessWidget {
  const HotspotRegionsViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: Row(
          children: [
            Image.asset(
              'assets/logo.png',
              height: 32,
              errorBuilder: (context, error, stackTrace) => const SizedBox(width: 32),
            ),
            const SizedBox(width: 12),
            const Text(
              'BrightPath',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue[50]!,
              Colors.white,
              Colors.blue[50]!,
            ],
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('hotspots')
              .orderBy('reportCount', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading hotspots',
                      style: TextStyle(fontSize: 18, color: Colors.grey[800]),
                    ),
                  ],
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_off, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No hotspot regions found',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final doc = snapshot.data!.docs[index];
                final data = doc.data() as Map<String, dynamic>;
                return _buildHotspotCard(context, data);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildHotspotCard(BuildContext context, Map<String, dynamic> data) {
    final createdAt = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    final lastUpdated = (data['lastUpdated'] as Timestamp?)?.toDate() ?? createdAt;
    final location = data['location'] as String? ?? 'Unknown Location';
    final reportCount = data['reportCount'] as int? ?? 0;

    // Split location into latitude and longitude for display
    final coordinates = location.split(',');
    final lat = coordinates.isNotEmpty ? coordinates[0].trim() : '';
    final lng = coordinates.length > 1 ? coordinates[1].trim() : '';

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Report Count
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getHeaderColor(reportCount)[0],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_rounded, color: _getHeaderColor(reportCount)[1]),
                const SizedBox(width: 8),
                Text(
                  'High Risk Area',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _getHeaderColor(reportCount)[1],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getHeaderColor(reportCount)[1],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$reportCount Reports',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Coordinates
                _buildInfoRow(
                  'Coordinates',
                  'Lat: $lat\nLng: $lng',
                  icon: Icons.location_on,
                  isLocation: true,
                ),
                const SizedBox(height: 12),

                // Timestamps
                _buildInfoRow(
                  'First Reported',
                  DateFormat('MMM d, yyyy - h:mm a').format(createdAt),
                  icon: Icons.calendar_today,
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  'Last Activity',
                  DateFormat('MMM d, yyyy - h:mm a').format(lastUpdated),
                  icon: Icons.update,
                ),
                const SizedBox(height: 16),

                // View on Map Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _openInMaps(location),
                    icon: const Icon(Icons.map_outlined),
                    label: const Text('View on Map'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getHeaderColor(int reportCount) {
    if (reportCount >= 10) {
      return [Colors.red[100]!, Colors.red[700]!];
    } else if (reportCount >= 5) {
      return [Colors.orange[100]!, Colors.orange[700]!];
    }
    return [Colors.yellow[100]!, Colors.orange[800]!];
  }

  Widget _buildInfoRow(String label, String value, {IconData? icon, bool isLocation = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: isLocation ? Colors.blue[700] : Colors.grey[800],
                  fontWeight: isLocation ? FontWeight.w600 : FontWeight.normal,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _openInMaps(String location) async {
    try {
      final coordinates = location.split(',');
      if (coordinates.length == 2) {
        final lat = coordinates[0].trim();
        final lng = coordinates[1].trim();
        final Uri url = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$lat,$lng'
        );
        
        if (!await launchUrl(url)) {
          throw Exception('Could not launch maps');
        }
      }
    } catch (e) {
      debugPrint('Error opening maps: $e');
    }
  }
}
