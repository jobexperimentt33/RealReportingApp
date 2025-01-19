import 'package:flutter/material.dart';
import 'excise_view_reports_page.dart';
import 'excise_hotspots_page.dart';
import 'package:brightpath/excise_profile_page.dart';
import 'package:brightpath/excise_home_page.dart';
import 'package:brightpath/notification_page.dart';

class ExciseReportPage extends StatefulWidget {
  const ExciseReportPage({super.key});

  @override
  State<ExciseReportPage> createState() => _ExciseReportPageState();
}

class _ExciseReportPageState extends State<ExciseReportPage> {
  int _selectedIndex = 1; // Report tab
  int? _hoveredIndex;

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
              'assets/logo.png',
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildOptionCard(
                'View Reports',
                Icons.report_outlined,
                'Review user reports and take action',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ViewReportsPage(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildOptionCard(
                'Hotspot Regions',
                Icons.location_on_outlined,
                'View and manage hotspot regions',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HotspotRegionsPage(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
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
    if (index == _selectedIndex) return;
    
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ExciseHomePage()),
        );
        break;
      case 1:
        // Already on report page
        return;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NotificationPage()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NotificationPage()),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ExciseProfilePage()),
        );
        break;
      default:
        return;
    }
  }

  Widget _buildOptionCard(
    String title,
    IconData icon,
    String description,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 32, color: Colors.blue[700]),
                  const SizedBox(width: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
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
