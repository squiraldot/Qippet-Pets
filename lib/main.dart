import 'package:flutter/material.dart';

void main() {
  runApp(const QippetPetsApp());
}

class QippetPetsApp extends StatelessWidget {
  const QippetPetsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Qippet Pets',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF79C94B),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const PetHomePage(),
    );
  }
}

class PetHomePage extends StatelessWidget {
  const PetHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Qippet Pets')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.pets, size: 72),
              SizedBox(height: 16),
              Text(
                'Your little companion is coming soon.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text(
                'Choose a pet and bring it to your Android home screen.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
