import 'package:flutter/material.dart';

class BookshelfApp extends StatelessWidget {
  const BookshelfApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bookshelf',
      home: Scaffold(body: Center(child: Text('BookShelf'))),
    );
  }
}
