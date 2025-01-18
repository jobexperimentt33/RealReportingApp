import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class CommentsSheet extends StatefulWidget {
  final String postId;
  final String postUserName;

  const CommentsSheet({
    Key? key,
    required this.postId,
    required this.postUserName,
  }) : super(key: key);

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final TextEditingController _commentController = TextEditingController();
  bool _isLoading = false;
  List<Map<String, dynamic>> _comments = [];

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .orderBy('timestamp', descending: true)
          .get();

      final comments = await Future.wait(snapshot.docs.map((doc) async {
        final data = doc.data();
        
        // Fetch user data for each comment
        if (data['userId'] != null) {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(data['userId'])
              .get();
              
          if (userDoc.exists) {
            // Get the commenter's name from Firestore
            final userData = userDoc.data();
            data['userName'] = userData?['name'] ?? 'Anonymous';
            data['userProfileImage'] = userData?['profilePicturePath'];
          }
        }

        return {
          ...data,
          'id': doc.id,
        };
      }));

      setState(() {
        _comments = comments;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading comments: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Get user data from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final userName = userDoc.data()?['name'] ?? 'Anonymous';

      // Add comment with user's name
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .add({
        'userId': user.uid,
        'userName': userName,
        'text': _commentController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'userProfileImage': userDoc.data()?['profilePicturePath'],
      });

      _commentController.clear();
      await _loadComments();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add comment: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Add this method to format timestamps
  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    
    final now = DateTime.now();
    final date = timestamp.toDate();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      // Format as date if older than a week
      return DateFormat.yMMMd().format(date);
    } else if (difference.inDays > 0) {
      // Show days ago if within a week
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      // Show hours ago
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      // Show minutes ago
      return '${difference.inMinutes}m ago';
    } else {
      // Show just now for very recent comments
      return 'just now';
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Add a handle for the bottom sheet
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.blue[200],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _comments.length,
                    itemBuilder: (context, index) {
                      final comment = _comments[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: comment['userProfileImage'] != null
                              ? NetworkImage(comment['userProfileImage'])
                              : null,
                          child: comment['userProfileImage'] == null
                              ? Icon(Icons.person, color: Colors.blue[700])
                              : null,
                        ),
                        title: Text(
                          comment['userName'] ?? 'Anonymous',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(comment['text']),
                            const SizedBox(height: 4),
                            Text(
                              _formatTimestamp(comment['timestamp']),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      hintStyle: TextStyle(color: Colors.blue[300]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.blue[200]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.blue[200]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.blue[400]!),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      filled: true,
                      fillColor: Colors.blue[50],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue[400],
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _addComment,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 