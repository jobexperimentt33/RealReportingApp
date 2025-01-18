import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collaboration Requests'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('collaborationRequests')
            .where('receiverId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No collaboration requests found.'));
          }

          final requests = snapshot.data!.docs;

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.all(8),
                color: Colors.blue.shade100,
                child: ListTile(
                  title: Text(request['senderName']),
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                          request['profilePicturePath'] ?? 'https://example.com/default_profile_picture.png'
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  subtitle: Text('Request from ${request['receiverName']} - ${request['status'] == 'accepted' ? 'Accepted' : 'Rejected'}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                     IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () async {
                          try {
                            // Accept collaboration request
                            final senderId = request['senderId'];
                            final receiverId = request['receiverId'];
                            final senderName = request['senderName'];
                            final receiverName = request['receiverName'];

                            // Directly access the collaboration request document
                            final docRef = FirebaseFirestore.instance
                                .collection('collaborationRequests')
                                .doc(request['id']); // Use the document ID

                            final docSnapshot = await docRef.get();

                            print('Request ID: ${request['id']}'); // Debug print
                            print('Document exists: ${docSnapshot.exists}'); // Debug print

                            if (!docSnapshot.exists) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Collaboration request not found.')),
                                );
                                return; // Exit if the document does not exist
                            }

                            // Update the collaboration request status
                            await docRef.update({'status': 'accepted'});

                            // Update sender's collaborator list
                            await FirebaseFirestore.instance
                             .collection('users')
                                .doc(senderId)
                                .set({
                                    'collaboratorList': FieldValue.arrayUnion([receiverName])
                                }, SetOptions(merge: true)); // Merge to create if not exists

                            // Update receiver's collaborator list
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(receiverId)
                                .set({
                                    'collaboratorList': FieldValue.arrayUnion([senderName])
                                }, SetOptions(merge: true)); // Merge to create if not exists

                            // Optionally show a success message
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Request accepted successfully!')),
                            );
                          } catch (e) {
                            // Handle errors
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Unable to accept request: $e')),
                            );
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () async {
                          try {
                            // Reject collaboration request
                            await FirebaseFirestore.instance
                                .collection('collaborationRequests')
                                .doc(request['id'])
                                .update({'status': 'rejected'});

                            // Optionally show a success message
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Request rejected successfully!')),
                            );
                          } catch (e) {
                            // Handle errors
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Unable to reject request: $e')),
                            );
                          }
                        },
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
} 