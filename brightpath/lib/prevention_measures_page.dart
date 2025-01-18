import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:brightpath/home_page.dart';
import 'package:brightpath/community_page.dart';
import 'package:brightpath/profile_page.dart';
import 'package:brightpath/report_page.dart';
import 'package:brightpath/notification_page.dart';
import 'package:brightpath/post_page.dart';

class PreventionMeasuresPage extends StatefulWidget {
  const PreventionMeasuresPage({super.key});

  @override
  State<PreventionMeasuresPage> createState() => _PreventionMeasuresPageState();
}

class _PreventionMeasuresPageState extends State<PreventionMeasuresPage> {
  int _selectedIndex = 4; // Prevention tab
  int? _hoveredIndex;
  String? selectedDrug;
  bool isLoading = false;
  String? preventionMeasures;
  String? sideEffects;
  String? activeTab; // Add this line to track which tab is active

  final List<String> drugs = [
    'Alcohol',
    'Marijuana',
    'Cocaine',
    'Heroin',
    'Methamphetamine',
    'MDMA (Ecstasy)',
    'LSD',
    'Prescription Opioids',
    'Benzodiazepines',
    'Tobacco/Nicotine',
    'Ketamine',
    'Synthetic Cannabinoids',
    'Inhalants',
    'Steroids',
  ];

  Future<void> _getPreventionMeasures() async {
    if (selectedDrug == null) {
      _showError('Please select a substance first.');
      return;
    }

    setState(() {
      isLoading = true;
      preventionMeasures = null;
      activeTab = 'prevention';
    });

    try {
      final model = GenerativeModel(
        model: 'gemini-pro',
        apiKey: 'AIzaSyBHZAHzL6aaux-UBiMFM7cSjNMgiB33fCI',
      );

      final preventionContent = Content.text('''
        Provide prevention measures and recovery strategies for $selectedDrug.
        Format the response with clear headers and bullet points.
        Include these sections:
        - Prevention Strategies:
        - Early Warning Signs:
        - Recovery Support:
        Keep each bullet point concise and actionable.
      ''');

      final response = await model.generateContent([preventionContent]);
      
      setState(() {
        preventionMeasures = response.text ?? 'No prevention measures available.';
        isLoading = false;
      });
    } catch (e) {
      _showError('Failed to fetch information: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _getSideEffects() async {
    if (selectedDrug == null) {
      _showError('Please select a substance first.');
      return;
    }

    setState(() {
      isLoading = true;
      sideEffects = null;
      activeTab = 'sideEffects';
    });

    try {
      final model = GenerativeModel(
        model: 'gemini-pro',
        apiKey: 'AIzaSyBHZAHzL6aaux-UBiMFM7cSjNMgiB33fCI',
      );

      final sideEffectsContent = Content.text('''
        Provide educational information about $selectedDrug from a healthcare perspective.
        Format the response as an educational resource with these sections:
        - General Health Information:
        - Important Safety Awareness:
        - Healthcare Considerations:
        Keep the information factual and educational, focusing on public health awareness.
        Present the information in a way that would be appropriate for a medical education context.
      ''');

      final response = await model.generateContent([sideEffectsContent]);

      setState(() {
        sideEffects = response.text ?? 'No health information available.';
        isLoading = false;
      });
    } catch (e) {
      _showError('Unable to retrieve health information at this time. Please try again later.');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Image.asset(
              'assets/brightpath_logo.png',
              height: 32,
              errorBuilder: (context, error, stackTrace) => 
                  const SizedBox(width: 32),
            ),
            const SizedBox(width: 12),
            const Text(
              'Prevention Measures',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDropdown(),
              const SizedBox(height: 24),
              _buildButtons(),
              const SizedBox(height: 24),
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (activeTab == 'prevention' && preventionMeasures != null)
                Expanded(
                  child: SingleChildScrollView(
                    child: _buildInfoCard(
                      'Prevention Measures',
                      preventionMeasures!,
                      Icons.healing,
                      Colors.green
                    ),
                  ),
                )
              else if (activeTab == 'sideEffects' && sideEffects != null)
                Expanded(
                  child: SingleChildScrollView(
                    child: _buildInfoCard(
                      'Health Information',
                      sideEffects!,
                      Icons.medical_information,
                      Colors.blue,
                    ),
                  ),
                ),
            ],
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PostPage(initialPostIndex: 0)),
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
        // Already on prevention page
        break;
      case 5:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
        break;
    }
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Substance',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.blue[700],
            ),
          ),
          const SizedBox(height: 12),
          DropdownButton<String>(
            value: selectedDrug,
            hint: const Text('Select a substance'),
            isExpanded: true,
            items: drugs.map((drug) {
              return DropdownMenuItem<String>(
                value: drug,
                child: Text(drug),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedDrug = value;
                // Clear previous results when selecting new drug
                preventionMeasures = null;
                sideEffects = null;
                activeTab = null;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String content, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildStructuredContent(content),
          ),
        ],
      ),
    );
  }

  Widget _buildStructuredContent(String content) {
    final lines = content.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        final trimmedLine = line.trim();
        if (trimmedLine.isEmpty) return const SizedBox(height: 8);
        
        final isBulletPoint = trimmedLine.startsWith('•') || 
                            trimmedLine.startsWith('-') || 
                            trimmedLine.startsWith('*');
        
        final isHeader = trimmedLine.endsWith(':');

        if (isHeader) {
          return Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Text(
              trimmedLine,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
          );
        } else if (isBulletPoint) {
          return Padding(
            padding: const EdgeInsets.only(left: 8, top: 4, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '•  ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3498DB),
                  ),
                ),
                Expanded(
                  child: Text(
                    trimmedLine.replaceFirst(RegExp(r'^[•\-*]\s*'), ''),
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Color(0xFF34495E),
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              trimmedLine,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Color(0xFF34495E),
              ),
            ),
          );
        }
      }).toList(),
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: selectedDrug == null || isLoading ? null : _getPreventionMeasures,
            icon: const Icon(Icons.healing),
            label: const Text('Prevention Measures'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: selectedDrug == null || isLoading ? null : _getSideEffects,
            icon: const Icon(Icons.medical_information),
            label: const Text('Health Information'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class NavItem {
  final IconData selectedIcon;
  final IconData icon;
  final String label;

  NavItem(this.selectedIcon, this.icon, this.label);
}
