import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart' as rx;

class ViewReportsPage extends StatefulWidget {
  const ViewReportsPage({super.key});

  @override
  State<ViewReportsPage> createState() => _ViewReportsPageState();
}

class _ViewReportsPageState extends State<ViewReportsPage> {
  String _selectedFilter = 'pending';
  String? _selectedDistrict;
  String _selectedReportType = 'all'; // 'all', 'location', 'known_person'

  @override
  void initState() {
    super.initState();
    _loadOfficerDistrict();
  }

  Future<void> _loadOfficerDistrict() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('exciseOfficers')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get();
      
      if (userDoc.exists) {
        setState(() {
          _selectedDistrict = userDoc.data()?['district'];
        });
      }
    } catch (e) {
      print('Error loading officer district: $e');
    }
  }

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
              'Reports Overview',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          // Report Type Filter
          DropdownButton<String>(
            value: _selectedReportType,
            items: [
              DropdownMenuItem(value: 'all', child: Text('All Reports')),
              DropdownMenuItem(value: 'location', child: Text('Location Reports')),
              DropdownMenuItem(value: 'known_person', child: Text('Known Person Reports')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedReportType = value!;
              });
            },
          ),
          // Status Filter
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'pending', child: Text('Pending')),
              const PopupMenuItem(value: 'accepted', child: Text('Accepted')),
              const PopupMenuItem(value: 'rejected', child: Text('Rejected')),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<QuerySnapshot>>(
        stream: _getReportsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildErrorWidget(snapshot.error.toString());
          }

          final reports = _processReports(snapshot.data);
          
          if (reports.isEmpty) {
            return _buildEmptyStateWidget();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return _buildReportCard(report);
            },
          );
        },
      ),
    );
  }

  Stream<List<QuerySnapshot>> _getReportsStream() {
    List<Future<QuerySnapshot>> futures = [];

    if (_selectedReportType == 'all' || _selectedReportType == 'location') {
      futures.add(
        FirebaseFirestore.instance
            .collection('location_reports')
            .where('status', isEqualTo: _selectedFilter)
            .orderBy('timestamp', descending: true)
            .get()
      );
    }

    if (_selectedReportType == 'all' || _selectedReportType == 'known_person') {
      futures.add(
        FirebaseFirestore.instance
            .collection('known_person_report')
            .where('status', isEqualTo: _selectedFilter)
            .orderBy('incidentDate', descending: true)
            .get()
      );
    }

    return Stream.fromFuture(Future.wait(futures));
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    final isLocationReport = report['type'] == 'location';
    final status = report['status'] ?? 'pending';

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Report Header with Status
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isLocationReport ? Colors.blue[100] : Colors.purple[100],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(
                  isLocationReport ? Icons.location_on : Icons.person,
                  color: isLocationReport ? Colors.blue[700] : Colors.purple[700],
                ),
                const SizedBox(width: 8),
                Text(
                  isLocationReport ? 'Location Report' : 'Known Person Report',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isLocationReport ? Colors.blue[700] : Colors.purple[700],
                  ),
                ),
                const Spacer(),
                _buildStatusChip(status),
              ],
            ),
          ),

          // Report Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isLocationReport) ...[
                  _buildInfoRow('Location', report['location']),
                ] else ...[
                  _buildInfoRow('Name', report['name']),
                  _buildInfoRow('Phone', report['phone']),
                  _buildInfoRow('Address', report['address']),
                  _buildInfoRow('Location', report['incidentLocation']),
                  _buildInfoRow('Time', report['incidentTime']),
                ],
                _buildInfoRow('Description', isLocationReport ? report['description'] : report['incidentDetails']),
                _buildInfoRow('Date', _formatTimestamp(report['timestamp'])),

                // Action Buttons
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => _handleReportAction(
                          report['id'],
                          'rejected',
                          report['location'],
                          report['type'],
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Reject'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () => _handleReportAction(
                          report['id'],
                          'accepted',
                          report['location'],
                          report['type'],
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: const Text('Accept'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery(List<dynamic> imageUrls) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => _showFullImage(context, imageUrls[index]),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrls[index],
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    switch (status.toLowerCase()) {
      case 'accepted':
        chipColor = Colors.green;
        break;
      case 'rejected':
        chipColor = Colors.red;
        break;
      default:
        chipColor = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Stack(
          children: [
            Image.network(imageUrl),
            Positioned(
              right: 8,
              top: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _handleReportAction(
    String reportId,
    String action,
    String location,
    String reportType,
  ) async {
    try {
      final collectionName = reportType == 'location' ? 'location_reports' : 'known_person_report';
      
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // Update status in Firebase
      await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(reportId)
          .update({
        'status': action,
        'actionTimestamp': FieldValue.serverTimestamp(),
        'actionBy': FirebaseAuth.instance.currentUser?.uid,
      });

      // Handle hotspot creation for accepted location reports
      if (action == 'accepted' && reportType == 'location') {
        await _checkAndCreateHotspot(location);
      }

      // Dismiss loading indicator
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report ${action.toUpperCase()}'),
            backgroundColor: action == 'accepted' ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      // Dismiss loading indicator
      Navigator.of(context).pop();
      
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Error loading reports',
            style: TextStyle(fontSize: 18, color: Colors.grey[800]),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No reports found',
            style: TextStyle(fontSize: 18, color: Colors.grey[800]),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new reports',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _processReports(List<QuerySnapshot>? snapshots) {
    if (snapshots == null) return [];

    List<Map<String, dynamic>> allReports = [];
    
    for (var snapshot in snapshots) {
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final isLocationReport = doc.reference.parent.id == 'location_reports';
        
        // Get status from Firebase or set as pending if not set
        String status = 'pending';
        if (data.containsKey('status')) {
          status = data['status'];
        }
        
        // Create a standardized report object
        final report = {
          ...data,
          'id': doc.id,
          'type': isLocationReport ? 'location' : 'known_person',
          'timestamp': isLocationReport ? data['timestamp'] : data['incidentDate'],
          'description': isLocationReport ? data['description'] : data['incidentDetails'],
          'location': isLocationReport ? '${data['latitude']}, ${data['longitude']}' : data['incidentLocation'],
          'status': status,
        };

        allReports.add(report);
      }
    }

    return allReports;
  }

  Future<void> _checkAndCreateHotspot(String location) async {
    try {
      // Check if hotspot already exists
      final hotspotQuery = await FirebaseFirestore.instance
          .collection('hotspots')
          .where('location', isEqualTo: location)
          .get();

      if (hotspotQuery.docs.isEmpty) {
        // Create new hotspot
        await FirebaseFirestore.instance.collection('hotspots').add({
          'location': location,
          'createdAt': FieldValue.serverTimestamp(),
          'reportCount': 1,
        });
      } else {
        // Update existing hotspot
        await FirebaseFirestore.instance
            .collection('hotspots')
            .doc(hotspotQuery.docs.first.id)
            .update({
          'reportCount': FieldValue.increment(1),
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error creating/updating hotspot: $e');
    }
  }
} 