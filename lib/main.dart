import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_single_instance/flutter_single_instance.dart';
import 'package:app_desktop/rotas/rotas.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Crie uma instância antes de usar
  final instance = FlutterSingleInstance();

  if (await instance.isFirstInstance()) {
    runApp(const MainApp());
  } else {
    
    exit(0);
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: rotasApp,
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.tealAccent[400],
        scaffoldBackgroundColor: const Color(0xFF121212),
    ));
  }
}