import 'package:flutter/material.dart';
import 'package:groceries_app/widgets/grocery_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Groceries',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          surface: const Color.fromARGB(218, 13, 12, 12),
          brightness: Brightness.dark,),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color.fromARGB(221, 50, 42, 42),
      ),
      home: const GroceryList(),
    );
  }
}