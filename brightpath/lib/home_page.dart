import 'package:brightpath/post_page.dart';
import 'package:brightpath/profile_page.dart';
import 'package:flutter/material.dart';

import 'report_page.dart';



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // Since we're on Home page, index 0

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/brightpath_logo.png', // Make sure to add this asset
              height: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              'BrightPath',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildHomeButton(
              'View Reported Regions',
              () {
                // Handle view reported regions
              },
            ),
            const SizedBox(height: 16),
            _buildHomeButton(
              'Hotspot Regions',
              () {
                // Handle hotspot regions
              },
            ),
          ],
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
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_outlined, 'Home'),
              _buildNavItem(1, Icons.report_outlined, 'Report'),
              _buildNavItem(2, Icons.post_add_outlined, 'Post'),
              _buildNavItem(3, Icons.person_outline, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeButton(String title, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
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
            // Already on home page
            break;
          case 1:
            Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const ReportPage()),
            );
            break;
          case 2:
            Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const PostPage(initialPostIndex: 0,)),
            );
            break;
          case 3:
            Navigator.pushReplacement(context,
             MaterialPageRoute(builder: (context) => const ProfilePage()),
            
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