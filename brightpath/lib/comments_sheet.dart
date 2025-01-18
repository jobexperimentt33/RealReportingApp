import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  final _commentController = TextEditingController();

  Future<void> _addComment() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _commentController.text.trim().isEmpty) return;

    try {
      // Start a batch write
      final batch = FirebaseFirestore.instance.batch();
      
      // Reference to the post document
      final postRef = FirebaseFirestore.instance.collection('posts').doc(widget.postId);
      
      // Add the comment
      final commentRef = postRef.collection('comments').doc();
      batch.set(commentRef, {
        'text': _commentController.text.trim(),
        'username': user.displayName ?? 'Anonymous',
        'userId': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Increment the comment count
      batch.update(postRef, {
        'commentCount': FieldValue.increment(1),
      });

      // Commit the batch
      await batch.commit();
      _commentController.clear();
    } catch (e) {
      print('Error adding comment: $e');
    }
  }

  Future<void> _deleteComment(String commentId) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      
      // Reference to the post and comment documents
      final postRef = FirebaseFirestore.instance.collection('posts').doc(widget.postId);
      final commentRef = postRef.collection('comments').doc(commentId);
      
      // Delete the comment
      batch.delete(commentRef);
      
      // Decrement the comment count
      batch.update(postRef, {
        'commentCount': FieldValue.increment(-1),
      });
      
      await batch.commit();
    } catch (e) {
      print('Error deleting comment: $e');
    }
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
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .doc(widget.postId)
                  .collection('comments')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  );
                }

                final comments = snapshot.data!.docs;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index].data() as Map<String, dynamic>;
                    return Card(
                      elevation: 0,
                      color: Colors.blue[100],
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    comment['username'] ?? 'Anonymous',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[900],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    comment['text'],
                                    style: TextStyle(color: Colors.blue[800]),
                                  ),
                                ],
                              ),
                            ),
                            // Show delete button only for post owner or comment owner
                            if (FirebaseAuth.instance.currentUser?.uid == comment['userId'] ||
                                FirebaseAuth.instance.currentUser?.displayName == widget.postUserName)
                              IconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: Colors.blue[900],
                                  size: 20,
                                ),
                                onPressed: () => _deleteComment(comments[index].id),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
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