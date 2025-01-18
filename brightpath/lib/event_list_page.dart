// brightpath/lib/events_list_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventsListPage extends StatelessWidget {
  const EventsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events List'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('events').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          final events = snapshot.data?.docs ?? [];

          if (events.isEmpty) {
            return const Center(child: Text('No events available'));
          }

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index].data() as Map<String, dynamic>;
              return ListTile(
                leading: event['thumbnail'] != null 
                    ? Image.network(event['thumbnail'], width: 50, height: 50, fit: BoxFit.cover) 
                    : null, // Display thumbnail if available
                title: Text(event['name'] ?? 'Unnamed Event'),
                subtitle: Text(event['description'] ?? 'No Description Available'),
                trailing: Text(event['date'] as String),
                onTap: () {
                  // Handle event detail navigation if needed
                },
              );
            },
          );
        },
      ),
    );
  }

  String? _formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      return dateTime.toLocal().toString(); // Format as needed
    } catch (e) {
      return null; // Handle parsing error
    }
  }
}