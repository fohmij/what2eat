import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:what2eat/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const What2EatApp());
}