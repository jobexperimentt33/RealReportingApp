import 'dart:async';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        backgroundColor: Colors.blue[100],
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.blue[900]),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Posts', 
          style: TextStyle(color: Colors.blue[900]),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                final post = _posts[index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User info header
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: ListTile(
                          dense: true,
                          leading: CircleAvatar(
                            radius: 16,
                            backgroundImage: post['userProfileImage'] != null
                                ? NetworkImage(post['userProfileImage'])
                                : null,
                            child: post['userProfileImage'] == null
                                ? const Icon(Icons.person, size: 20)
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
                      // Post image
                      AspectRatio(
                        aspectRatio: 1,
                        child: Image.network(
                          post['imageUrl'],
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Action buttons
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    post['liked'] ? Icons.favorite : Icons.favorite_border,
                                    color: post['liked'] ? Colors.red : Colors.blue[900],
                                  ),
                                  onPressed: () => _toggleLike(post['id'], index),
                                ),
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.comment_outlined, color: Colors.blue[900]),
                                      onPressed: () => _showComments(
                                        post['id'],
                                        post['userName'] ?? post['userId'] ?? 'Anonymous',
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 16,
                                          minHeight: 16,
                                        ),
                                        child: Text(
                                          '${post['commentCount'] ?? 0}',
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
                                ),
                                IconButton(
                                  icon: Icon(Icons.share_outlined, color: Colors.blue[900]),
                                  onPressed: () {
                                    final userName = post['userName'] ?? post['userId'] ?? 'Anonymous';
                                    final caption = post['caption'] ?? '';
                                    final imageUrl = post['imageUrl'] ?? '';
                                    
                                    Share.share(
                                      'Check out this post by $userName!\n\n'
                                      '${caption.isNotEmpty ? '$caption\n\n' : ''}'
                                      '$imageUrl',
                                    );
                                  },
                                ),
                              ],
                            ),
                            // Likes count and caption section
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                '${post['likes'] ?? 0} likes',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[900],
                                ),
                              ),
                            ),
                            // Caption
                            if (post['caption'] != null &&
                                post['caption'].toString().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: RichText(
                                  text: TextSpan(
                                    style: const TextStyle(color: Colors.black),
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
                );
              },
            ),
    );
  }
} 