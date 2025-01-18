import 'dart:async';

import 'package:brightpath/login_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import 'comments_sheet.dart';

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
            data['userName'] = userDoc.data()?['username'] ?? data['userId'];
          }
        }

        // Initial comment count
        final commentsSnapshot = await FirebaseFirestore.instance
            .collection('posts')
            .doc(doc.id)
            .collection('comments')
            .count()
            .get();

        // Set up real-time listener for comment count
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        backgroundColor: Colors.blue[600],
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Image.asset(
              'assets/logo.png',
              height: 32,
              errorBuilder: (context, error, stackTrace) => const SizedBox(width: 32),
            ),
            const SizedBox(width: 12),
            const Text(
              'Community Posts',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.5,
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
                color: Colors.white.withOpacity(0.1),
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
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: _posts.length,
                itemBuilder: (context, index) {
                  final post = _posts[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue[100]!.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User info header with gradient
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.blue[600]!.withOpacity(0.1),
                                Colors.blue[100]!.withOpacity(0.1),
                              ],
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.blue[100],
                              backgroundImage: post['userProfileImage'] != null
                                  ? NetworkImage(post['userProfileImage'])
                                  : null,
                              child: post['userProfileImage'] == null
                                  ? Icon(Icons.person, size: 24, color: Colors.blue[600])
                                  : null,
                            ),
                            title: Text(
                              post['userName'] ?? 'Anonymous',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (post['location'] != null)
                                  Text(
                                    post['location'],
                                    style: TextStyle(fontSize: 12),
                                  ),
                                Text(
                                  DateFormat.yMMMd().format(
                                    (post['timestamp'] as Timestamp).toDate(),
                                  ),
                                  style: TextStyle(fontSize: 12),
                                ),
                                if (post['caption'] != null && 
                                    post['caption'].toString().isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      post['caption'],
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ),
                              ],
                            ),
                            trailing: Container(
                              padding: EdgeInsets.only(right: 10),
                              child: PopupMenuButton<String>(
                                icon: Icon(Icons.more_vert, 
                                  color: Colors.blue[900],
                                  size: 20,
                                ),
                                onSelected: (value) async {
                                  if (value == 'edit') {
                                    // Show edit caption dialog
                                    final newCaption = await showDialog<String>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Edit Caption'),
                                        content: TextField(
                                          controller: TextEditingController(text: post['caption']),
                                          decoration: const InputDecoration(
                                            hintText: 'Enter new caption',
                                          ),
                                          maxLines: 3,
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(
                                              context,
                                              (context.findAncestorWidgetOfExactType<TextField>())
                                                  ?.controller?.text,
                                            ),
                                            child: const Text('Save'),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (newCaption != null) {
                                      try {
                                        await FirebaseFirestore.instance
                                            .collection('posts')
                                            .doc(post['id'])
                                            .update({'caption': newCaption});
                                        
                                        setState(() {
                                          post['caption'] = newCaption;
                                        });
                                      } catch (e) {
                                        print('Error updating caption: $e');
                                      }
                                    }
                                  } else if (value == 'delete') {
                                    // Show delete confirmation dialog
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete Post'),
                                        content: const Text('Are you sure you want to delete this post?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            child: const Text('Delete',
                                              style: TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true) {
                                      try {
                                        await FirebaseFirestore.instance
                                            .collection('posts')
                                            .doc(post['id'])
                                            .delete();
                                        
                                        setState(() {
                                          _posts.removeAt(index);
                                        });
                                      } catch (e) {
                                        print('Error deleting post: $e');
                                      }
                                    }
                                  } else if (value == 'save') {
                                    // Implement save functionality here
                                    // You can add the post to a user's saved posts collection
                                    try {
                                      final user = FirebaseAuth.instance.currentUser;
                                      if (user != null) {
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(user.uid)
                                            .collection('saved_posts')
                                            .doc(post['id'])
                                            .set({
                                              'savedAt': FieldValue.serverTimestamp(),
                                              'postId': post['id'],
                                            });
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Post saved successfully')),
                                        );
                                      }
                                    } catch (e) {
                                      print('Error saving post: $e');
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Failed to save post')),
                                      );
                                    }
                                  }
                                },
                                itemBuilder: (context) {
                                  final currentUser = FirebaseAuth.instance.currentUser;
                                  final isAuthor = currentUser?.uid == post['userId'];
                                  
                                  return [
                                    if (isAuthor) ...[
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit),
                                            SizedBox(width: 8),
                                            Text('Edit Caption'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete, color: Colors.red),
                                            SizedBox(width: 8),
                                            Text('Delete Post', style: TextStyle(color: Colors.red)),
                                          ],
                                        ),
                                      ),
                                    ] else
                                      const PopupMenuItem(
                                        value: 'save',
                                        child: Row(
                                          children: [
                                            Icon(Icons.bookmark_border),
                                            SizedBox(width: 8),
                                            Text('Save Post'),
                                          ],
                                        ),
                                      ),
                                  ];
                                },
                              ),
                            ),
                          ),
                        ),
                        // Image with rounded corners
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            post['imageUrl'],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: MediaQuery.of(context).size.width - 32,
                          ),
                        ),
                        // Action buttons with enhanced styling
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.blue[600]!.withOpacity(0.1),
                                Colors.blue[100]!.withOpacity(0.1),
                              ],
                            ),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  _buildActionButton(
                                    icon: post['liked'] ? Icons.favorite : Icons.favorite_border,
                                    color: post['liked'] ? Colors.red : Colors.blue[600]!,
                                    onPressed: () => _toggleLike(post['id'], index),
                                  ),
                                  _buildCommentButton(post),
                                  _buildActionButton(
                                    icon: Icons.share_outlined,
                                    color: Colors.blue[600]!,
                                    onPressed: () => _sharePost(post),
                                  ),
                                ],
                              ),
                              // Enhanced likes and caption section
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${post['likes'] ?? 0} likes',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[600],
                                        fontSize: 16,
                                      ),
                                    ),
                                    if (post['caption'] != null && 
                                        post['caption'].toString().isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: RichText(
                                          text: TextSpan(
                                            style: TextStyle(
                                              color: Colors.blue[900],
                                              fontSize: 15,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: '${post['userName']} ',
                                                style: const TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                              TextSpan(text: post['caption']),
                                            ],
                                          ),
                                        ),
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
                  currentIndex: 1, // Community tab
                  selectedItemColor: Colors.blue[600],
                  unselectedItemColor: Colors.grey[400],
                  showUnselectedLabels: true,
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  selectedFontSize: 12,
                  unselectedFontSize: 12,
                  onTap: (index) {
                    // Handle navigation
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: color, size: 28),
        ),
      ),
    );
  }

  Widget _buildCommentButton(Map<String, dynamic> post) {
    return Stack(
      children: [
        _buildActionButton(
          icon: Icons.comment_outlined,
          color: Colors.blue[600]!,
          onPressed: () => _showComments(
            post['id'],
            post['userName'] ?? post['userId'] ?? 'Anonymous',
          ),
        ),
        if ((post['commentCount'] ?? 0) > 0)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Text(
                '${post['commentCount']}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  List<BottomNavigationBarItem> _buildNavItems() {
    final items = [
      NavItem(Icons.home_rounded, Icons.home_outlined, 'Home'),
      NavItem(Icons.group_rounded, Icons.group_outlined, 'Community'),
      NavItem(Icons.add_circle_rounded, Icons.add_circle_outlined, 'Report'),
      NavItem(Icons.notifications_rounded, Icons.notifications_outlined, 'Alerts'),
      NavItem(Icons.person_rounded, Icons.person_outlined, 'Profile'),
    ];

    return items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isHovered = _hoveredIndex == index;
      final isSelected = 1 == index; // Community tab

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
}

class NavItem {
  final IconData selectedIcon;
  final IconData icon;
  final String label;

  NavItem(this.selectedIcon, this.icon, this.label);
} 