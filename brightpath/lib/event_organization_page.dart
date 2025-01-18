import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class EventOrganizationPage extends StatefulWidget {
  const EventOrganizationPage({super.key});

  @override
  State<EventOrganizationPage> createState() => _EventOrganizationPageState();
}

class _EventOrganizationPageState extends State<EventOrganizationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedCollaborator;
  String? _thumbnailUrl;
  String? _username;
  List<String> _collaborators = ['Collaborator 1', 'Collaborator 2', 'Collaborator 3']; // Example collaborators
  List<String> _selectedCollaborators = []; // Store selected collaborators

  @override
  void initState() {
    super.initState();
    _username = _username;
  }

  Future<String?> uploadImage(XFile file) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('thumbnails/${file.name}');
      await storageRef.putFile(File(file.path));
      return await storageRef.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Event Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an event name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
                readOnly: true,
                controller: TextEditingController(
                  text: _selectedDate != null 
                      ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                      : '',
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() {
                      _selectedDate = date;
                    });
                  }
                },
                validator: (value) {
                  if (_selectedDate == null) {
                    return 'Please select a date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('Choose Collaborators (optional):'),
              ..._collaborators.map((collaborator) {
                return CheckboxListTile(
                  title: Text(collaborator),
                  value: _selectedCollaborators.contains(collaborator),
                  onChanged: (bool? selected) {
                    setState(() {
                      if (selected == true) {
                        _selectedCollaborators.add(collaborator);
                      } else {
                        _selectedCollaborators.remove(collaborator);
                      }
                    });
                  },
                );
              }).toList(),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  // Code to pick an image and upload it
                  final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    // Upload the image and get the URL
                    _thumbnailUrl = await uploadImage(pickedFile);
                  }
                },
                child: const Text('Upload Thumbnail'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    try {
                      await FirebaseFirestore.instance.collection('events').add({
                        'name': _nameController.text,
                        'description': _descriptionController.text,
                        'date': DateFormat('yyyy-MM-dd').format(_selectedDate!),
                        'collaborator': _selectedCollaborators.isNotEmpty ? _selectedCollaborators : null, // Save collaborators
                        'thumbnail': _thumbnailUrl,
                        'createdAt': FieldValue.serverTimestamp(),
                        'createdBy': _username,
                      });

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Event created successfully')),
                        );
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error creating event: $e')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Create',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 