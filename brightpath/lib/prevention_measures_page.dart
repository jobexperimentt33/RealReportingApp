import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:brightpath/home_page.dart';
import 'package:brightpath/community_page.dart';
import 'package:brightpath/profile_page.dart';
import 'package:brightpath/report_page.dart';

class PreventionMeasuresPage extends StatefulWidget {
  const PreventionMeasuresPage({super.key});

  @override
  State<PreventionMeasuresPage> createState() => _PreventionMeasuresPageState();
}

class _PreventionMeasuresPageState extends State<PreventionMeasuresPage> {
  int _selectedIndex = 5; // New index for Prevention tab
  int? _hoveredIndex;
  String? selectedDrug;
  bool isLoading = false;
  String? preventionMeasures;
  String? sideEffects;

  // List of commonly abused drugs
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

  Future<void> _getDrugInfo() async {
    if (selectedDrug == null) {
      _showError('Please select a substance first');
      return;
    }

    setState(() {
      isLoading = true;
      preventionMeasures = null;
      sideEffects = null;
    });

    try {
      final model = GenerativeModel(
        model: 'gemini-pro',
        apiKey: 'AIzaSyAF6DBQUXz3nievlZR0Poz5Rfnu2erzwZU', // Replace with your API key
      );

      final content = Content.text('''
        Provide information about ${selectedDrug} in two sections:
        1. Prevention measures and recovery strategies
        2. Side effects and health risks
        
        Keep the response concise and well-structured.
      ''');

      final response = await model.generateContent([content]);
      final text = response.text ?? 'No information available';

      // Split the response into prevention measures and side effects
      final sections = text.split('\n\n');
      
      setState(() {
        preventionMeasures = sections.isNotEmpty ? sections[0].replaceAll('1. ', '') : 'No prevention measures available';
        sideEffects = sections.length > 1 ? sections[1].replaceAll('2. ', '') : 'No side effects information available';
        isLoading = false;
      });
    } catch (e) {
      _showError('Failed to fetch information: ${e.toString()}');
      setState(() {
        isLoading = false;
        preventionMeasures = null;
        sideEffects = null;
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
  void dispose() {
    // Add any controllers to dispose here if needed
    super.dispose();
  }

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
              'assets/brightpath_logo.png',
              height: 32,
              errorBuilder: (context, error, stackTrace) => const SizedBox(width: 32),
            ),
            const SizedBox(width: 12),
            const Text(
              'Prevention Measures',
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
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
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedDrug,
                            hint: const Text('Select a substance'),
                            isExpanded: true,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            borderRadius: BorderRadius.circular(12),
                            items: drugs.map((String drug) {
                              return DropdownMenuItem<String>(
                                value: drug,
                                child: Text(drug),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedDrug = newValue;
                              });
                              _getDrugInfo();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  )
                else if (preventionMeasures != null)
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildInfoCard(
                            'Prevention Measures',
                            preventionMeasures!,
                            Icons.healing,
                            Colors.green,
                          ),
                          const SizedBox(height: 16),
                          if (sideEffects != null)
                            _buildInfoCard(
                              'Side Effects',
                              sideEffects!,
                              Icons.warning_amber_rounded,
                              Colors.red,
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 65, // Fixed height to prevent overflow
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
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _buildNavItems().asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return GestureDetector(
                      onTap: () => _onItemTapped(index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: item,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String content, IconData icon, Color color) {
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
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildNavItems() {
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

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(isHovered || isSelected ? 8.0 : 6.0),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue[700] : isHovered ? Colors.blue[50] : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              boxShadow: isSelected || isHovered
                  ? [BoxShadow(color: Colors.blue.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))]
                  : null,
            ),
            child: Icon(
              isSelected || isHovered ? item.selectedIcon : item.icon,
              size: isHovered || isSelected ? 28 : 24,
              color: isSelected ? Colors.white : isHovered ? Colors.blue[700] : Colors.grey[400],
            ),
          ),
          const SizedBox(height: 4),
          Text(item.label, style: TextStyle(fontSize: 12, color: isSelected ? Colors.blue[700] : Colors.grey[600])),
        ],
      );
    }).toList();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
        break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CommunityPage()));
        break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ReportPage()));
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/notifications');
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
  }
}

class NavItem {
  final IconData selectedIcon;
  final IconData icon;
  final String label;

  NavItem(this.selectedIcon, this.icon, this.label);
} 