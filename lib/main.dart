import 'package:flutter/material.dart';
import 'package:cattle_disease_app/app.dart';

void main() {
  // Ensure that plugin services are initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(const CattleDiseaseApp());
}
