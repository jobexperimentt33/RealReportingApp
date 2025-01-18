import 'package:flutter/material.dart';
import 'welcome_page.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    print('Flutter binding initialized');
    
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAcof48_Ku8JNW3EIo1v9wfEECKKASpgcw",
        appId: "1:30360132423:android:812a65f5093e513607ca62",
        messagingSenderId: "30360132423",
        projectId: "brightpath-3b9e3",
        storageBucket: "brightpath-3b9e3.firebasestorage.app",
      ),
    );
    print('Firebase initialized successfully');
    
    runApp(const MyApp());
  } catch (e) {
    print('Error during initialization: $e');
    // Still run the app even if Firebase fails
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
       
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const WelcomePage(),
    );
  }
}



