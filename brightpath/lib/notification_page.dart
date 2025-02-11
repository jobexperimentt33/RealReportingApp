import 'package:brightpath/community_page.dart';
import 'package:brightpath/home_page.dart';
import 'package:brightpath/report_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'excise_home_page.dart';
<<<<<<< Updated upstream
import 'package:intl/intl.dart';
import 'package:brightpath/post_page.dart';
import 'package:brightpath/prevention_measures_page.dart';
import 'package:brightpath/profile_page.dart';
=======
import 'excise_report.dart';
import 'excise_profile_page.dart';
>>>>>>> Stashed changes

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  int? _hoveredIndex;
  int _selectedIndex = 3; // Notifications tab

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[600],
        elevation: 2,
        title: Row(
          children: [
            Image.asset(
              'assets/logo.png',
              height: 32,
              errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
            ),
            const SizedBox(width: 12),
            const Text(
              'Notifications',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue[50]!,
              Colors.white,
              Colors.blue[50]!,
            ],
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('notifications')
              .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
              .where('type', whereIn: ['collaboration_request', 'collaboration_accepted'])
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_none_rounded, size: 80, color: Colors.blue[200]),
                    const SizedBox(height: 16),
                    Text(
                      'No notifications',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[600],
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
                final notification = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                final notificationId = snapshot.data!.docs[index].id;
                
                if (notification['type'] == 'collaboration_accepted') {
                  return _buildNotificationCard(
                    title: notification['title'],
                    message: notification['message'],
                    timestamp: notification['timestamp'] as Timestamp,
                    icon: Icons.check_circle,
                    color: Colors.green[700]!,
                    onDismiss: () => _markNotificationAsRead(notificationId),
                  );
                } else if (notification['type'] == 'collaboration_request') {
                  return _buildCollaborationRequestCard(
                    {...notification, 'notificationId': notificationId}
                  );
                }
                
                return const SizedBox.shrink();
              },
            );
          },
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: MouseRegion(
                onHover: (event) {
                  final RenderBox box = context.findRenderObject() as RenderBox;
                  final position = box.globalToLocal(event.position);
                  final width = box.size.width;
                  final index = (position.dx / (width / 6)).floor();
                  setState(() {
                    _hoveredIndex = index;
                  });
                },
                onExit: (event) {
                  setState(() {
                    _hoveredIndex = null;
                  });
                },
                child: BottomNavigationBar(
                  items: _buildNavItems(),
                  currentIndex: _selectedIndex,
                  selectedItemColor: Colors.blue[700],
                  unselectedItemColor: Colors.grey[400],
                  showUnselectedLabels: true,
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  selectedFontSize: 12,
                  unselectedFontSize: 12,
                  onTap: _onItemTapped,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<BottomNavigationBarItem> _buildNavItems() {
    final items = [
      NavItem(Icons.home_rounded, Icons.home_outlined, 'Home'),
      NavItem(Icons.group_rounded, Icons.group_outlined, 'Community'),
      NavItem(Icons.add_circle_rounded, Icons.add_circle_outlined, 'Report'),
      NavItem(Icons.notifications_rounded, Icons.notifications_outlined, 'Alerts'),
      NavItem(Icons.medical_services_rounded, Icons.medical_services_outlined, 'Prevention'),
      NavItem(Icons.person_rounded, Icons.person_outlined, 'Profile'),
    ];

    return items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isHovered = _hoveredIndex == index;
      final isSelected = _selectedIndex == index;

      return BottomNavigationBarItem(
        icon: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.all(isHovered || isSelected ? 8.0 : 6.0),
          decoration: BoxDecoration(
            color: isSelected 
                ? Colors.blue[700] 
                : isHovered 
                    ? Colors.blue[50] 
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected || isHovered
                ? [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            isSelected || isHovered ? item.selectedIcon : item.icon,
            size: isHovered || isSelected ? 28 : 24,
            color: isSelected 
                ? Colors.white 
                : isHovered 
                    ? Colors.blue[700] 
                    : Colors.grey[400],
          ),
        ),
        label: item.label,
      );
    }).toList();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PostPage(initialPostIndex: 0)),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CommunityPage()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ReportPage()),
        );
        break;
      case 3:
        // Already on notifications page
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PreventionMeasuresPage()),
        );
        break;
      case 5:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
        break;
    }
  }

  Future<void> _handleAccept(Map<String, dynamic> request) async {
    try {
      // Get the request document reference
      final requestQuery = await FirebaseFirestore.instance
          .collection('collaborationRequests')
          .where('senderId', isEqualTo: request['senderId'])
          .where('receiverId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .where('status', isEqualTo: 'pending')
          .get();

      if (requestQuery.docs.isEmpty) {
        throw Exception('Request not found');
      }

      final requestDoc = requestQuery.docs.first;

      // Update request status to accepted
      await requestDoc.reference.update({
        'status': 'accepted',
        'acceptedAt': FieldValue.serverTimestamp(),
      });

      // Create collaboration record
      await FirebaseFirestore.instance.collection('collaborations').add({
        'user1Id': request['senderId'],
        'user1Name': request['senderName'],
        'user2Id': FirebaseAuth.instance.currentUser?.uid,
        'user2Name': request['receiverName'],
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'active'
      });

      // Create notification for sender
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': request['senderId'],
        'title': 'Collaboration Request Accepted',
        'message': '${request['receiverName']} has accepted your collaboration request',
        'type': 'collaboration_accepted',
        'status': 'unread',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Mark the request notification as read
      if (request['notificationId'] != null) {
        await _markNotificationAsRead(request['notificationId']);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green[100]),
              const SizedBox(width: 12),
              const Text('Request accepted successfully'),
            ],
          ),
          backgroundColor: Colors.green[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.red[100]),
              const SizedBox(width: 12),
              const Text('Failed to accept request'),
            ],
          ),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  Future<void> _handleReject(Map<String, dynamic> request) async {
    try {
      // ... existing reject logic ...
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.blue[100]),
              const SizedBox(width: 12),
              const Text('Request declined'),
            ],
          ),
          backgroundColor: Colors.blue[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.red[100]),
              const SizedBox(width: 12),
              const Text('Failed to decline request'),
            ],
          ),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  Widget _buildNotificationCard({
    required String title,
    required String message,
    required Timestamp timestamp,
    required IconData icon,
    required Color color,
    required VoidCallback onDismiss,
  }) {
    return Dismissible(
      key: Key(timestamp.toString()),
      onDismissed: (_) => onDismiss(),
      background: Container(
        color: Colors.red[100],
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Icon(Icons.delete, color: Colors.red[700]),
      ),
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 16),
        child: ListTile(
          leading: Icon(icon, color: color),
          title: Text(title),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message),
              Text(
                _formatTimestamp(timestamp),
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final date = timestamp.toDate();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return DateFormat('MMM d, yyyy').format(date);
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildCollaborationRequestCard(Map<String, dynamic> request) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue[100]!.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.blue[50],
                          backgroundImage: request['profilePicturePath'] != null
                              ? NetworkImage(request['profilePicturePath'])
                              : null,
                          child: request['profilePicturePath'] == null
                              ? Icon(Icons.person, color: Colors.blue[600])
                              : null,
                        ),
                        title: Text(
                          request['senderName'] ?? 'Unknown User',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              'Sent you a collaboration request',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tap to respond',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextButton.icon(
                                onPressed: () => _handleAccept(request),
                                icon: const Icon(Icons.check_circle_outline),
                                label: const Text('Accept'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.green[700],
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(16),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 32,
                              color: Colors.blue[100],
                            ),
                            Expanded(
                              child: TextButton.icon(
                                onPressed: () => _handleReject(request),
                                icon: const Icon(Icons.cancel_outlined),
                                label: const Text('Decline'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red[700],
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(16),
                                    ),
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

  Future<void> _markNotificationAsRead(String notificationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .update({
        'status': 'read',
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }
}

class NavItem {
  final IconData selectedIcon;
  final IconData icon;
  final String label;

  NavItem(this.selectedIcon, this.icon, this.label);
} 