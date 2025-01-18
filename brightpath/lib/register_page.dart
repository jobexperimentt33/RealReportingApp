// brightpath/lib/register_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _institutionNameController = TextEditingController();
  final TextEditingController _rehabCenterNameController = TextEditingController();
  final TextEditingController _communityNameController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final bool _isVerified = false;
  int currentIndex = 2;
  String _selectedCategory = 'Excise Department';
  final List<String> _categories = [
    'Excise Department',
    'institution',
    'Community',
    'Rehab Center',
    'User',
  ];
  final _formKey = GlobalKey<FormState>();
  String? _selectedDistrict;
  final List<String> _districts = [
    'Thiruvananthapuram',
    'Kollam',
    'Pathanamthitta',
    'Alappuzha',
    'Kottayam',
    'Idukki',
    'Ernakulam',
    'Thrissur',
    'Palakkad',
    'Malappuram',
    'Kozhikode',
    'Wayanad',
    'Kannur',
    'Kasaragod',
  ];
  int? _hoveredIndex;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    try {
      // Check if username is already in use
      if (await isUsernameTaken(_usernameController.text)) {
        // Show a dialog or snackbar if the username is taken
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Username Taken'),
            content: const Text('Please choose a different username.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Send email verification
      await userCredential.user?.sendEmailVerification();

      // Set user verification status to false by default
      await saveUserData(userCredential.user?.uid, false); // Set verified to false

      // Navigate to login page with a message
      Navigator.pop(context, 'Please verify your email before logging in.');
    } catch (e) {
      // Handle error (e.g., show a dialog)
      print(e);
    }
  }

  Future<bool> isUsernameTaken(String username) async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    return result.docs.isNotEmpty; // Return true if username exists
  }

  Future<void> saveUserData(String? userId, bool isVerified) async {
    String? name;
    switch (_selectedCategory) {
      case 'Rehab Center':
        name = _rehabCenterNameController.text.trim();
        break;
      case 'Community':
        name = _communityNameController.text.trim();
        break;
      case 'institution':
        name = _institutionNameController.text.trim();
        break;
      case 'User':
        name = _fullNameController.text.trim();
        break;
    }

    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'verified': isVerified,
      'username': _usernameController.text.trim(),
      'category': _selectedCategory,
      'name': name,
      'email': _emailController.text.trim(),
      'district': _selectedDistrict,
      // Add other user data fields as necessary
    });
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('Please log in to use this feature.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _generateUserId() {
    final random = Random();
    final number = random.nextInt(9000) + 1000; // generates number between 1000-9999
    
    switch (_selectedCategory) {
      case 'institution':
        return 'INT$number';
      case 'Community':
        return 'COM$number';
      case 'Rehab Center':
        return 'RC$number';
      case 'User':
        return 'USR$number';
      default:
        return '';
    }
  }

  void _handleCategoryChange(String? newValue) {
    setState(() {
      _selectedCategory = newValue!;
      // Auto-generate and set username when category changes
      if (_selectedCategory != 'Excise Department') {
        _usernameController.text = _generateUserId();
      }
    });
  }

  List<Widget> _getCategorySpecificFields() {
    List<Widget> fields = [];
    
    // Add styled fields based on category
    // ... (keep existing logic but update the styling of TextFormFields)
    
    // Example of styled TextFormField:
    Widget buildStyledField({
      required TextEditingController controller,
      required String label,
      required IconData icon,
      String? Function(String?)? validator,
      bool obscureText = false,
      bool enabled = true,
    }) {
      return TextFormField(
        controller: controller,
        obscureText: obscureText,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: Icon(icon, color: Colors.blue[600]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
          ),
          filled: true,
          fillColor: enabled ? Colors.grey[50] : Colors.grey[200],
        ),
        validator: validator,
      );
    }

    switch (_selectedCategory) {
      case 'Excise Department':
        fields.add(
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Registration for Excise Department is currently disabled.',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
        break;

      case 'institution':
        fields.add(
          buildStyledField(
            controller: _institutionNameController,
            label: 'institution Name',
            icon: Icons.home,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter institution name';
              }
              return null;
            },
          ),
        );
        break;

      case 'Community':
        fields.add(
          buildStyledField(
            controller: _communityNameController,
            label: 'Community Name',
            icon: Icons.location_on,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter community name';
              }
              return null;
            },
          ),
        );
        break;

      case 'Rehab Center':
        fields.add(
          buildStyledField(
            controller: _rehabCenterNameController,
            label: 'Rehab Center Name',
            icon: Icons.healing,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter rehab center name';
              }
              return null;
            },
          ),
        );
        break;

      default: // User category
        fields.add(
          buildStyledField(
            controller: _fullNameController,
            label: 'Full Name',
            icon: Icons.person,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your full name';
              }
              return null;
            },
          ),
        );
        break;
    }

    // Add the district dropdown for all categories
    fields.add(
      _buildStyledDropdown(
        value: _selectedDistrict,
        items: _districts,
        onChanged: (String? newValue) {
          setState(() {
            _selectedDistrict = newValue;
          });
        },
        hint: 'Select Your Location',
        icon: Icons.location_on,
        validator: (value) {
          if (value == null) {
            return 'Please select your location';
          }
          return null;
        },
      ),
    );

    // Add common fields for all categories except Excise Department
    if (_selectedCategory != 'Excise Department') {
      fields.add(const SizedBox(height: 16));
      fields.add(
        buildStyledField(
          controller: _usernameController,
          label: 'User ID',
          icon: Icons.person,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your username';
            }
            return null;
          },
        ),
      );
      fields.add(const SizedBox(height: 16));
      fields.add(
        buildStyledField(
          controller: _emailController,
          label: 'Email ID',
          icon: Icons.email,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
      );
      fields.add(const SizedBox(height: 16));
      fields.add(
        buildStyledField(
          controller: _passwordController,
          label: 'Password',
          icon: Icons.lock,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a password';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
          obscureText: true,
        ),
      );
    }

    return fields;
  }

  Widget _buildStyledDropdown({
    String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required String hint,
    String? Function(String?)? validator,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blue[600]),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          border: InputBorder.none,
          filled: true,
          fillColor: Colors.grey[50],
        ),
        items: items.map((String item) {
          return DropdownMenuItem(
            value: item,
            child: Text(
              item,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 15,
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        hint: Text(
          hint,
          style: TextStyle(color: Colors.grey[600]),
        ),
        validator: validator,
        icon: Icon(Icons.arrow_drop_down, color: Colors.blue[600]),
        dropdownColor: Colors.white,
        style: TextStyle(
          color: Colors.grey[800],
          fontSize: 15,
        ),
      ),
    );
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
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Welcome Container
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Join our community today',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Registration Form Container
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Account Type',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Category Dropdown with enhanced styling
                          _buildStyledDropdown(
                            value: _selectedCategory,
                            items: _categories,
                            onChanged: _handleCategoryChange,
                            hint: 'Select Account Type',
                            icon: Icons.account_circle,
                            validator: (value) {
                              if (value == null) {
                                return 'Please select an account type';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          // Dynamic form fields with spacing
                          ..._getCategorySpecificFields().map((widget) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: widget,
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Register Button
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Login Link Container
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Sign In',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
                  currentIndex: 2,
                  selectedItemColor: Colors.blue[700],
                  unselectedItemColor: Colors.grey[400],
                  showUnselectedLabels: true,
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  selectedFontSize: 12,
                  unselectedFontSize: 12,
                  onTap: (index) => _showLoginRequiredDialog(),
                ),
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
      NavItem(Icons.group_rounded, Icons.group_outlined, 'Community'),
      NavItem(Icons.add_circle_rounded, Icons.add_circle_outlined, 'Report'),
      NavItem(Icons.notifications_rounded, Icons.notifications_outlined, 'Alerts'),
      NavItem(Icons.person_rounded, Icons.person_outlined, 'Profile'),
    ];

    return items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isHovered = _hoveredIndex == index;
      final isSelected = 2 == index;

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
}

class NavItem {
  final IconData selectedIcon;
  final IconData icon;
  final String label;

  NavItem(this.selectedIcon, this.icon, this.label);
}