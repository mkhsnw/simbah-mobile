import 'package:flutter/material.dart';
import 'package:simbah/config/routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Simbah',
      theme: ThemeData(primarySwatch: Colors.green, fontFamily: 'Roboto'),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
