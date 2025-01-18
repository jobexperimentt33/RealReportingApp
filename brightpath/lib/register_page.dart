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
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Check if username is already in use
      if (await isUsernameTaken(_usernameController.text)) {
        _showErrorDialog('Username Taken', 'Please choose a different username.');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Show loading dialog with initial message
      _showLoadingDialog('Creating your account...');

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Update loading message
      _updateLoadingMessage('Setting up your profile...');

      // Send email verification
      await userCredential.user?.sendEmailVerification();

      // Set user verification status to false by default
      await saveUserData(userCredential.user?.uid, false);

      // Dismiss loading dialog
      Navigator.of(context).pop();

      // Show success dialog
      await _showSuccessDialog();

      // Navigate to login page
      Navigator.pop(context);
    } catch (e) {
      // Dismiss loading dialog if showing
      if (_isLoading) {
        Navigator.of(context).pop();
      }
      
      // Show error dialog with appropriate message
      _showErrorDialog(
        'Registration Error',
        _getReadableErrorMessage(e.toString()),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                Text(message),
              ],
            ),
          ),
        );
      },
    );
  }

  void _updateLoadingMessage(String message) {
    Navigator.of(context).pop(); // Dismiss current dialog
    _showLoadingDialog(message); // Show new dialog with updated message
  }

  Future<void> _showSuccessDialog() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green[600]),
              const SizedBox(width: 8),
              const Text('Success'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your account has been created successfully!'),
              const SizedBox(height: 12),
              Text(
                'A verification email has been sent to ${_emailController.text}',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red[600]),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _getReadableErrorMessage(String error) {
    if (error.contains('email-already-in-use')) {
      return 'This email is already registered. Please use a different email or try logging in.';
    } else if (error.contains('weak-password')) {
      return 'The password provided is too weak. Please choose a stronger password.';
    } else if (error.contains('invalid-email')) {
      return 'The email address is invalid. Please check and try again.';
    }
    return 'An unexpected error occurred. Please try again later.';
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    if (value.length < 4) {
      return 'Username must be at least 4 characters';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Name can only contain letters and spaces';
    }
    return null;
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
    );
  }
}

class NavItem {
  final IconData selectedIcon;
  final IconData icon;
  final String label;

  NavItem(this.selectedIcon, this.icon, this.label);
}