import 'dart:async';

import 'package:brightpath/community_page.dart';
import 'package:brightpath/login_page.dart';
import 'package:brightpath/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import 'comments_sheet.dart';
import 'package:brightpath/prevention_measures_page.dart';
import 'package:brightpath/notification_page.dart';
import 'package:brightpath/report_page.dart';

class PostPage extends StatefulWidget {
  final int initialPostIndex;

  const PostPage({super.key, required this.initialPostIndex});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = true;
  final Map<String, StreamSubscription> _commentCountListeners = {};
  int? _hoveredIndex;
  int _selectedIndex = 0; // Community tab

  @override
  void dispose() {
    for (var subscription in _commentCountListeners.values) {
      subscription.cancel();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .get();

      final posts = await Future.wait(snapshot.docs.map((doc) async {
        final data = doc.data();
        
        // Fetch user data if userId exists
        if (data['userId'] != null) {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(data['userId'])
              .get();
            
          if (userDoc.exists) {
            // Get the user's name from Firestore
            final userData = userDoc.data();
            data['userName'] = userData?['name'] ?? 'Anonymous';
            data['userProfileImage'] = userData?['profileImage'];
          }
        }

        // Initial comment count
        final commentsSnapshot = await FirebaseFirestore.instance
            .collection('posts')
            .doc(doc.id)
            .collection('comments')
            .count()
            .get();

        _setupCommentCountListener(doc.id);

        return {
          ...data,
          'id': doc.id,
          'liked': false,
          'commentCount': commentsSnapshot.count,
        };
      }));

      setState(() {
        _posts = posts;
        _checkLikedPosts();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading posts: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _setupCommentCountListener(String postId) {
    // Cancel existing listener if any
    _commentCountListeners[postId]?.cancel();

    // Set up new listener
    final subscription = FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .snapshots()
        .listen((snapshot) {
      setState(() {
        final postIndex = _posts.indexWhere((post) => post['id'] == postId);
        if (postIndex != -1) {
          _posts[postIndex]['commentCount'] = snapshot.docs.length;
        }
      });
    });

    _commentCountListeners[postId] = subscription;
  }

  Future<void> _toggleLike(String postId, int index) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);
    final likesRef = postRef.collection('likes');

    try {
      final likeDoc = await likesRef.doc(user.uid).get();
      
      // Initialize likes if null
      if (_posts[index]['likes'] == null) {
        _posts[index]['likes'] = 0;
      }
      
      if (likeDoc.exists) {
        // Unlike
        await likesRef.doc(user.uid).delete();
        await postRef.update({'likes': FieldValue.increment(-1)});
        setState(() {
          _posts[index]['liked'] = false;
          _posts[index]['likes']--;
        });
      } else {
        // Like
        await likesRef.doc(user.uid).set({'timestamp': FieldValue.serverTimestamp()});
        await postRef.update({'likes': FieldValue.increment(1)});
        setState(() {
          _posts[index]['liked'] = true;
          _posts[index]['likes']++;
        });
      }
    } catch (e) {
      print('Error toggling like: $e');
    }
  }

  Future<void> _checkLikedPosts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    for (int i = 0; i < _posts.length; i++) {
      final likeDoc = await FirebaseFirestore.instance
          .collection('posts')
          .doc(_posts[i]['id'])
          .collection('likes')
          .doc(user.uid)
          .get();
      
      setState(() {
        _posts[i]['liked'] = likeDoc.exists;
      });
    }
  }

  void _showComments(String postId, String postUserName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CommentsSheet(postId: postId, postUserName: postUserName),
    );
  }

  Future<void> _showLogoutDialog() async {
    return showDialog(
      context: context,
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
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
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
                          await _handleLogout();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
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

  Future<void> _handleLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        // Show success snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.green[100]),
                const SizedBox(width: 12),
                const Text('Successfully logged out'),
              ],
            ),
            backgroundColor: Colors.green[800],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
        
        // Navigate to login page
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red[100]),
                const SizedBox(width: 12),
                const Text('Failed to logout'),
              ],
            ),
            backgroundColor: Colors.red[800],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    switch (index) {
      case 0:
        // Already on post/home page
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.blue[700]),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Image.asset(
              'assets/brightpath_logo.png',
              height: 32,
              errorBuilder: (context, error, stackTrace) => const SizedBox(width: 32),
            ),
            const SizedBox(width: 12),
            Text(
              'BrightPath',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.blue[700],
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.blue[700]),
            onPressed: () {
              // Handle search
            },
          ),
          PopupMenuButton<String>(
            offset: const Offset(0, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue[50],
              ),
              child: Icon(
                Icons.more_vert,
                color: Colors.blue[700],
              ),
            ),
            itemBuilder: (BuildContext context) => [
              _buildPopupMenuItem('settings', Icons.settings_outlined, 'Settings'),
              _buildPopupMenuItem('logout', Icons.logout_rounded, 'Logout'),
            ],
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutDialog();
              } else if (value == 'settings') {
                // Handle settings
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
              Colors.blue[50]!,
            ],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadPosts,
                child: ListView.builder(
                  itemCount: _posts.length,
                  itemBuilder: (context, index) {
                    final post = _posts[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              leading: CircleAvatar(
                                backgroundImage: post['userProfileImage'] != null
                                    ? NetworkImage(post['userProfileImage'])
                                    : null,
                                child: post['userProfileImage'] == null
                                    ? Icon(Icons.person, color: Colors.blue[700])
                                    : null,
                              ),
                              title: Text(
                                post['userName'] ?? 'Anonymous',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                _formatTimestamp(post['timestamp']),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            // Post Image with enhanced styling
                            if (post['imageUrl'] != null)
                              Container(
                                constraints: const BoxConstraints(
                                  maxHeight: 400,
                                ),
                                width: double.infinity,
                                child: ClipRRect(
                                  child: Image.network(
                                    post['imageUrl'],
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        height: 400,
                                        color: Colors.grey[100],
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded /
                                                    loadingProgress.expectedTotalBytes!
                                                : null,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            // Post Actions with enhanced styling
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: Colors.grey[100]!,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  _buildEnhancedActionButton(
                                    icon: Icons.favorite_outline,
                                    label: 'Like',
                                    color: Colors.red[400]!,
                                    onPressed: () {
                                      // Handle like
                                    },
                                  ),
                                  const SizedBox(width: 20),
                                  _buildEnhancedActionButton(
                                    icon: Icons.comment_outlined,
                                    label: 'Comment',
                                    count: post['commentCount'],
                                    color: Colors.blue[600]!,
                                    onPressed: () => _showComments(
                                      post['id'],
                                      post['userName'] ?? post['userId'] ?? 'Anonymous',
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  _buildEnhancedActionButton(
                                    icon: Icons.share_outlined,
                                    label: 'Share',
                                    color: Colors.green[600]!,
                                    onPressed: () => _sharePost(post),
                                  ),
                                ],
                              ),
                            ),
                            // Post Caption with enhanced styling
                            if (post['caption'] != null)
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '${post['userName']} ',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                      TextSpan(
                                        text: post['caption'],
                                        style: const TextStyle(
                                          height: 1.4,
                                          letterSpacing: 0.1,
                                        ),
                                      ),
                                    ],
                                  ),
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
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

  Widget _buildEnhancedActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    int? count,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 4),
              Text(
                count != null ? '$count' : label,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
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

  void _sharePost(Map<String, dynamic> post) {
    final userName = post['userName'] ?? post['userId'] ?? 'Anonymous';
    final caption = post['caption'] ?? '';
    final imageUrl = post['imageUrl'] ?? '';
    
    Share.share(
      'Check out this post by $userName!\n\n'
      '${caption.isNotEmpty ? '$caption\n\n' : ''}'
      '$imageUrl',
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(String value, IconData icon, String text) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: Colors.blue[700], size: 20),
          const SizedBox(width: 12),
          Text(text),
        ],
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat.yMMMd().format(date);
  }
}

class NavItem {
  final IconData selectedIcon;
  final IconData icon;
  final String label;

  NavItem(this.selectedIcon, this.icon, this.label);
} 