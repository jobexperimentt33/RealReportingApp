import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ViewReportsPage extends StatefulWidget {
  const ViewReportsPage({super.key});

  @override
  State<ViewReportsPage> createState() => _ViewReportsPageState();
}

class _ViewReportsPageState extends State<ViewReportsPage> {
  String _selectedFilter = 'pending';
  String? _selectedDistrict;

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
        title: const Text('User Reports'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'pending',
                child: Text('Pending Reports'),
              ),
              const PopupMenuItem(
                value: 'accepted',
                child: Text('Accepted Reports'),
              ),
              const PopupMenuItem(
                value: 'rejected',
                child: Text('Rejected Reports'),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('userReports')  // Make sure this matches your collection name
            .where('status', isEqualTo: _selectedFilter)
            .where('district', isEqualTo: _selectedDistrict)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.report_off_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No ${_selectedFilter} reports found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
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
              final report = snapshot.data!.docs[index];
              final data = report.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(data['status'] ?? 'pending'),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              (data['status'] ?? 'pending').toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _formatTimestamp(data['timestamp'] as Timestamp),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Location: ${data['location'] ?? 'Unknown'}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Description: ${data['description'] ?? 'No description provided'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      if (data['imageUrls'] != null && (data['imageUrls'] as List).isNotEmpty) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: (data['imageUrls'] as List).length,
                            itemBuilder: (context, imgIndex) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: GestureDetector(
                                  onTap: () => _showFullImage(context, data['imageUrls'][imgIndex]),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      data['imageUrls'][imgIndex],
                                      height: 100,
                                      width: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                      if (_selectedFilter == 'pending')
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => _handleReportAction(
                                  context,
                                  report.id,
                                  'rejected',
                                  data['location'],
                                ),
                                child: const Text('Reject'),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton(
                                onPressed: () => _handleReportAction(
                                  context,
                                  report.id,
                                  'accepted',
                                  data['location'],
                                ),
                                child: const Text('Accept'),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Image.network(imageUrl),
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('MMM d, y HH:mm').format(date);
  }

  Future<void> _handleReportAction(
    BuildContext context,
    String reportId,
    String action,
    String location,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('userReports')
          .doc(reportId)
          .update({
        'status': action,
        'actionTimestamp': FieldValue.serverTimestamp(),
        'actionBy': FirebaseAuth.instance.currentUser?.uid,
      });

      if (action == 'accepted') {
        // Check if this location should be marked as a hotspot
        final acceptedReports = await FirebaseFirestore.instance
            .collection('userReports')
            .where('location', isEqualTo: location)
            .where('status', isEqualTo: 'accepted')
            .get();

        if (acceptedReports.docs.length >= 3) {
          // Create hotspot record
          await FirebaseFirestore.instance.collection('hotspots').add({
            'location': location,
            'district': _selectedDistrict,
            'createdAt': FieldValue.serverTimestamp(),
            'status': 'active',
            'reportCount': acceptedReports.docs.length,
          });
        }
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report ${action.toUpperCase()}'),
            backgroundColor: action == 'accepted' ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
} 