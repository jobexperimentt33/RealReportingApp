import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'login_page.dart';
import 'package:brightpath/excise_report.dart';

class ExciseProfilePage extends StatefulWidget {
  const ExciseProfilePage({super.key});

  @override
  State<ExciseProfilePage> createState() => _ExciseProfilePageState();
}

class _ExciseProfilePageState extends State<ExciseProfilePage> {
  int? _hoveredIndex;
  int _selectedIndex = 4; // Profile tab
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  
  // User data
  String? _officerName;
  String? _designation;
  String? _badgeNumber;
  String? _district;
  String? _profileImageUrl;
  List<Map<String, dynamic>> _posts = [];

  @override
  void initState() {
    super.initState();
    _loadOfficerData();
    _loadPosts();
  }

  Future<void> _loadOfficerData() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('exciseOfficers')
          .doc(_auth.currentUser?.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          _officerName = userDoc.data()?['name'];
          _designation = userDoc.data()?['designation'];
          _badgeNumber = userDoc.data()?['badgeNumber'];
          _district = userDoc.data()?['district'];
          _profileImageUrl = userDoc.data()?['profileImageUrl'];
        });
      }
    } catch (e) {
      print('Error loading officer data: $e');
    }
  }

  Future<void> _loadPosts() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('excisePosts')
          .where('officerId', isEqualTo: _auth.currentUser!.uid)
          .orderBy('timestamp', descending: true)
          .get();

      setState(() {
        _posts = snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList();
      });
    } catch (e) {
      print('Error loading posts: $e');
    }
  }

  Future<void> _updateProfileImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
      );

      if (image == null) return;

      setState(() => _isLoading = true);

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('exciseOfficerProfiles')
          .child('${_auth.currentUser!.uid}.jpg');

      await storageRef.putFile(File(image.path));
      final downloadUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('exciseOfficers')
          .doc(_auth.currentUser!.uid)
          .update({'profileImageUrl': downloadUrl});

      setState(() {
        _profileImageUrl = downloadUrl;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[100]),
                const SizedBox(width: 12),
                const Text('Profile picture updated successfully'),
              ],
            ),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile picture: $e'),
            backgroundColor: Colors.red[600],
          ),
        );
      }
    }
  }

  Future<void> _showLogoutDialog() async {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          elevation: 20,
          content: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    size: 32,
                    color: Colors.blue[600],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Are you sure you want to logout?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await _auth.signOut();
                          if (mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                              (route) => false,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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
              'Officer Profile',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            offset: const Offset(0, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.2),
              ),
              child: const Icon(
                Icons.more_vert,
                color: Colors.white,
              ),
            ),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined, color: Colors.blue[600], size: 20),
                    const SizedBox(width: 12),
                    const Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout_rounded, color: Colors.blue[600], size: 20),
                    const SizedBox(width: 12),
                    const Text('Logout'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutDialog();
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue[50]!,
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile Header
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: _profileImageUrl != null
                              ? Image.network(
                                  _profileImageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(Icons.person, size: 60, color: Colors.blue[200]),
                                )
                              : Icon(Icons.person, size: 60, color: Colors.blue[200]),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _updateProfileImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue[600],
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Officer Info Card
                _buildInfoCard(),
                const SizedBox(height: 24),

                // Action Buttons from Excise Home
                _buildActionButton(
                  'View Reported Regions',
                  Icons.location_on_outlined,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ExciseReportPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildActionButton(
                  'Hotspot Regions',
                  Icons.warning_amber_outlined,
                  () {
                    // Navigate to hotspot regions page
                  },
                ),
                const SizedBox(height: 24),

                // Statistics Section
                _buildStatisticsSection(),
                const SizedBox(height: 24),

                // Recent Activity
                _buildRecentActivitySection(),

                // Posts Section
                _buildPostsGrid(),
                const SizedBox(height: 24),

                // Manage Posts Button
                _buildManagePostsButton(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Name', _officerName ?? 'Not Set'),
          const Divider(height: 20),
          _buildInfoRow('Designation', _designation ?? 'Not Set'),
          const Divider(height: 20),
          _buildInfoRow('Badge Number', _badgeNumber ?? 'Not Set'),
          const Divider(height: 20),
          _buildInfoRow('District', _district ?? 'Not Set'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statistics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Posts',
                '24',
                Icons.article_outlined,
                Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Active Cases',
                '12',
                Icons.gavel_outlined,
                Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Reports',
                '48',
                Icons.report_outlined,
                Colors.red,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Resolved',
                '36',
                Icons.check_circle_outline,
                Colors.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildActivityItem(
            'Case Report Filed',
            'Palakkad District',
            '2 hours ago',
            Icons.description_outlined,
          ),
          const Divider(height: 20),
          _buildActivityItem(
            'Investigation Updated',
            'Case #2024-03',
            '1 day ago',
            Icons.update,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String subtitle, String time, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.blue[600], size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Text(
          time,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildPostsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        final post = _posts[index];
        return GestureDetector(
          onLongPress: () => _deletePost(post['id']),
          child: Image.network(
            post['imageUrl'],
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                Container(
                  color: Colors.grey[200],
                  child: Icon(Icons.error, color: Colors.grey[400]),
                ),
          ),
        );
      },
    );
  }

  Widget _buildManagePostsButton() {
    return ElevatedButton.icon(
      onPressed: _addNewPost,
      icon: const Icon(Icons.add_photo_alternate),
      label: const Text('Add New Post'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[600],
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<void> _addNewPost() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      setState(() => _isLoading = true);

      // Upload image to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('excisePosts')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      await storageRef.putFile(File(image.path));
      final downloadUrl = await storageRef.getDownloadURL();

      // Add post to Firestore
      await FirebaseFirestore.instance.collection('excisePosts').add({
        'officerId': _auth.currentUser!.uid,
        'officerName': _officerName,
        'imageUrl': downloadUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'description': '', // You can add a description input if needed
      });

      await _loadPosts(); // Reload posts

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[100]),
                const SizedBox(width: 12),
                const Text('Post added successfully'),
              ],
            ),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add post: $e'),
            backgroundColor: Colors.red[600],
          ),
        );
      }
    }
  }

  Future<void> _deletePost(String postId) async {
    try {
      await FirebaseFirestore.instance
          .collection('excisePosts')
          .doc(postId)
          .delete();

      await _loadPosts(); // Reload posts

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[100]),
                const SizedBox(width: 12),
                const Text('Post deleted successfully'),
              ],
            ),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete post: $e'),
            backgroundColor: Colors.red[600],
          ),
        );
      }
    }
  }

  Widget _buildBottomNavBar() {
    return Container(
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
                final index = (position.dx / (width / 5)).floor();
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
                selectedItemColor: Colors.blue[600],
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
    );
  }

  List<BottomNavigationBarItem> _buildNavItems() {
    final items = [
      NavItem(Icons.home_rounded, Icons.home_outlined, 'Home'),
      NavItem(Icons.report_outlined, Icons.report, 'Report'),
      NavItem(Icons.post_add_rounded, Icons.post_add_outlined, 'Post'),
      NavItem(Icons.notifications_rounded, Icons.notifications_outlined, 'Alerts'),
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
                ? Colors.blue[600] 
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
                    ? Colors.blue[600] 
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
          MaterialPageRoute(builder: (context) => const ExciseReportPage()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ExciseReportPage()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ExciseReportPage()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ExciseReportPage()),
        );
        break;
      case 4:
        // Already on profile page
        break;
    }
  }

  Widget _buildActionButton(String title, IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
            child: Row(
              children: [
                Icon(icon, color: Colors.blue[600], size: 24),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[600],
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.blue[600],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NavItem {
  final IconData selectedIcon;
  final IconData icon;
  final String label;

  NavItem(this.selectedIcon, this.icon, this.label);
}

class UpdateProfileDialog extends StatefulWidget {
  final String currentName;
  final String currentDesignation;
  final String currentBadgeNumber;
  final String currentDistrict;

  const UpdateProfileDialog({
    super.key,
    required this.currentName,
    required this.currentDesignation,
    required this.currentBadgeNumber,
    required this.currentDistrict,
  });

  @override
  State<UpdateProfileDialog> createState() => _UpdateProfileDialogState();
}

class _UpdateProfileDialogState extends State<UpdateProfileDialog> {
  late TextEditingController _nameController;
  late TextEditingController _designationController;
  late TextEditingController _badgeNumberController;
  late TextEditingController _districtController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _designationController = TextEditingController(text: widget.currentDesignation);
    _badgeNumberController = TextEditingController(text: widget.currentBadgeNumber);
    _districtController = TextEditingController(text: widget.currentDistrict);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Profile'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _designationController,
              decoration: const InputDecoration(labelText: 'Designation'),
            ),
            TextField(
              controller: _badgeNumberController,
              decoration: const InputDecoration(labelText: 'Badge Number'),
            ),
            TextField(
              controller: _districtController,
              decoration: const InputDecoration(labelText: 'District'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, {
            'name': _nameController.text,
            'designation': _designationController.text,
            'badgeNumber': _badgeNumberController.text,
            'district': _districtController.text,
          }),
          child: const Text('Update'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _designationController.dispose();
    _badgeNumberController.dispose();
    _districtController.dispose();
    super.dispose();
  }
}
