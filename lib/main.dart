import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/film_provider.dart';
import 'provider/commentaire_provider.dart';
import 'screens/accueil.dart';


void main()  {
 
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FilmProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion de Films',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}
