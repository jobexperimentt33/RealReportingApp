import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:brightpath/prevention_measures_page.dart';
import 'community_page.dart';
import 'home_page.dart';
import 'notification_page.dart';
import 'report_page.dart';
import 'post_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  String? _bio;
  String? _name;
  String? _phoneNumber;
  
  // Add image picker
  final ImagePicker _picker = ImagePicker();

  int _selectedIndex = 4; // Since we're on Profile page, index 4

  // Add these new variables
  List<String> _posts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _loadUserData();
    _loadPosts();
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _uploadProfilePicture() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
      );

      if (image == null) return;

      setState(() {
        _isLoading = true; // Add loading state while uploading
      });

      // Get Firebase Storage reference
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child('${_auth.currentUser!.uid}.jpg');

      // Upload image
      await storageRef.putFile(File(image.path));

      // Get download URL
      final downloadUrl = await storageRef.getDownloadURL();

      // Update user profile
      await _auth.currentUser?.updatePhotoURL(downloadUrl);

      // Store profile picture path in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .set({
        'profilePicturePath': downloadUrl,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Update UI
      setState(() {
        _user = _auth.currentUser;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    }
  }

  Future<void> _addNewPost() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      // Navigate to post creation screen
      final bool? posted = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreatePostScreen(imageFile: image),
        ),
      );

      // Refresh posts if new post was created
      if (posted == true) {
        await _loadPosts();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to select image: $e')),
      );
    }
  }

  Future<void> _loadPosts() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where('userId', isEqualTo: _auth.currentUser!.uid)
          .orderBy('timestamp', descending: true)
          .get();

      setState(() {
        _posts = snapshot.docs
            .map((doc) => doc.data()['imageUrl'] as String)
            .toList();
      });
    } catch (e) {
      print('Error loading posts: $e');
    }
  }

  Future<void> _loadUserData() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data();
        if (userData != null && userData['profilePicturePath'] != null) {
          await _auth.currentUser?.updatePhotoURL(userData['profilePicturePath']);
          setState(() {
            _user = _auth.currentUser;
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.blue),
            onPressed: _addNewPost,
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () {
              // Settings functionality
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Picture Section
                GestureDetector(
                  onTap: _uploadProfilePicture,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.blue.shade100,
                        backgroundImage: _user?.photoURL != null
                            ? NetworkImage(_user!.photoURL!)
                            : null,
                        child: _user?.photoURL == null
                            ? const Icon(Icons.person, size: 45, color: Colors.blue)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                // Stats Section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatColumn('Posts', _posts.length.toString()),
                          _buildStatColumn('Collaborators', '0'),
                        ],
                      ),
                      const SizedBox(height: 15),
                      // Bio Section
                      Text(
                        _bio ?? 'Add a bio...',
                        style: TextStyle(
                          fontSize: 14,
                          color: _bio == null ? Colors.grey : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Buttons Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      _showEditProfileDialog();
                    },
                    child: const Text('Edit Profile'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text('Share Profile'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Grid view for posts
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    padding: const EdgeInsets.all(2),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2,
                    ),
                    itemCount: _posts.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PostPage(initialPostIndex: index),
                            ),
                          );
                        },
                        child: Image.network(
                          _posts[index],
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
          ),
        ],
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
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_outlined, 'Home'),
              _buildNavItem(1, Icons.people_outline, 'Community'),
              _buildNavItem(2, Icons.report_outlined, 'Report'),
              _buildNavItem(3, Icons.notifications_outlined, 'Notifications'),
              _buildNavItem(5, Icons.medical_services_outlined,'Prevention'),
              _buildNavItem(4, Icons.person_outline, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showEditProfileDialog() async {
    String? newBio = _bio;
    String? newName = _name ?? _user?.displayName;
    String? newPhone = _phoneNumber;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: newName),
                onChanged: (value) => newName = value,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: newPhone),
                keyboardType: TextInputType.phone,
                onChanged: (value) => newPhone = value,
              ),
              const SizedBox(height: 16),
              TextField(
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  border: OutlineInputBorder(),
                  hintText: 'Tell us about yourself...',
                ),
                controller: TextEditingController(text: newBio),
                onChanged: (value) => newBio = value,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _bio = newBio;
                _name = newName;
                _phoneNumber = newPhone;
                // TODO: Update user profile in Firebase
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String count) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _selectedIndex == index;
    Color itemColor = isSelected ? Colors.blue : Colors.grey;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        
        // Handle navigation
        switch (index) {
          case 0:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
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
           Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const NotificationPage()),
            );
            break;
          case 4:
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
            break;
          case 5:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const PreventionMeasuresPage()),
            );      
  break;
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: itemColor,
            size: 24,
          ),
          Text(
            label,
            style: TextStyle(
              color: itemColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// Add this new class for the post creation screen
class CreatePostScreen extends StatefulWidget {
  final XFile imageFile;
  
  const CreatePostScreen({super.key, required this.imageFile});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('New Post', style: TextStyle(color: Colors.black)),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : () => _createPost(context),
            child: const Text('Share', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image preview
            AspectRatio(
              aspectRatio: 1,
              child: Image.file(
                File(widget.imageFile.path),
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Caption field
                  TextField(
                    controller: _captionController,
                    decoration: const InputDecoration(
                      hintText: 'Write a caption...',
                      border: InputBorder.none,
                    ),
                    maxLines: 3,
                  ),
                  const Divider(),
                  // Location field
                  TextField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      hintText: 'Add location',
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),
                  const Divider(),
                ],
              ),
            ),
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  Future<void> _createPost(BuildContext context) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Upload image to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('posts')
          .child(user.uid)
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      await storageRef.putFile(File(widget.imageFile.path));
      final downloadUrl = await storageRef.getDownloadURL();

      // Add post to Firestore
      await FirebaseFirestore.instance.collection('posts').add({
        'userId': user.uid,
        'imageUrl': downloadUrl,
        'caption': _captionController.text,
        'location': _locationController.text,
        'timestamp': FieldValue.serverTimestamp(),
        'likes': 0,
        'userName': user.displayName ?? 'Anonymous',
        'userProfileImage': user.photoURL,
      });

      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create post: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
} 