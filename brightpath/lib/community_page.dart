import 'package:brightpath/profile_page.dart';
import 'package:brightpath/report_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:brightpath/prevention_measures_page.dart';
import 'event_list_page.dart';
import 'event_organization_page.dart';
import 'institution_listing_page.dart';
import 'package:brightpath/notification_page.dart';
import 'package:brightpath/post_page.dart';
import 'package:intl/intl.dart';

class CommunityPage extends StatefulWidget {
  final String? communityId;
  
  const CommunityPage({super.key, this.communityId});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  int _selectedIndex = 1;
  int? _hoveredIndex;
  String? _selectedLocation;

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
              'assets/brightpath_logo.png',
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Location Selector
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Location',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[700],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedLocation,
                            hint: const Text('Select District'),
                            isExpanded: true,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            borderRadius: BorderRadius.circular(12),
                            items: <String>[
                              'Alappuzha', 'Ernakulam', 'Idukki', 'Kannur', 'Kasaragod',
                              'Kollam', 'Kottayam', 'Kozhikode', 'Malappuram', 'Palakkad',
                              'Pathanamthitta', 'Thiruvananthapuram', 'Thrissur', 'Wayanad'
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedLocation = newValue;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Events Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Events',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildActionButton(
                        'View Events',
                        Icons.event,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const EventsListPage()),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildActionButton(
                        'Organize Event',
                        Icons.add_circle_outline,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const EventOrganizationPage()),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Community Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _buildGridItem(
                      'Collaborations',
                      Icons.people_outline,
                      () => _showListFromFirebase('collaborations'),
                    ),
                    _buildGridItem(
                      'Institutions',
                      Icons.school_outlined,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const InstitutionListingPage()),
                      ),
                    ),
                    _buildGridItem(
                      'Community',
                      Icons.groups_outlined,
                      () => _showListFromFirebase('communities'),
                    ),
                    _buildGridItem(
                      'Rehabs',
                      Icons.local_hospital_outlined,
                      () => _showListFromFirebase('rehabs'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 10,
            ),
          ],
        ),
        child: MouseRegion(
          onEnter: (event) {
            setState(() {
              _hoveredIndex = null;
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
    );
  }

  Widget _buildActionButton(String title, IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          backgroundColor: Colors.white,
          foregroundColor: Colors.blue[700],
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue[700]),
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: Colors.blue[700],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blue[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showListFromFirebase(String type) {
    if (type == 'collaborations' && widget.communityId != null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                ),
                child: const Text(
                  'Collaborators',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(child: _buildCollaboratorsList()),
            ],
          ),
        ),
      );
    }
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
        // Already on community page
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ReportPage()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NotificationPage()),
        );
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

  Future<List<Map<String, dynamic>>> _fetchCollaborators(String communityId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('communities')
        .doc(communityId)
        .collection('collaborators')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        ...data,
      };
    }).toList();
  }

  Widget _buildCollaboratorsList() {
    if (widget.communityId == null) {
      return const Center(child: Text('No community selected'));
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchCollaborators(widget.communityId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final collaborators = snapshot.data ?? [];

        if (collaborators.isEmpty) {
          return const Center(child: Text('No collaborators yet'));
        }

        return ListView.builder(
          itemCount: collaborators.length,
          itemBuilder: (context, index) {
            final collaborator = collaborators[index];
            return ListTile(
              leading: CircleAvatar(
                child: Text(collaborator['userName'][0].toUpperCase()),
              ),
              title: Text(collaborator['userName']),
              subtitle: Text('Joined ${_formatTimestamp(collaborator['joinedAt'])}'),
            );
          },
        );
      },
    );
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    
    final now = DateTime.now();
    final date = timestamp.toDate();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return DateFormat.yMMMd().format(date);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }
}

class NavItem {
  final IconData selectedIcon;
  final IconData icon;
  final String label;

  NavItem(this.selectedIcon, this.icon, this.label);
} 